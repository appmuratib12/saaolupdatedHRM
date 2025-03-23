import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:saaolhrmapp/constant/ConstantValues.dart';
import 'package:saaolhrmapp/data/responsedata/AttendanceReportResponse.dart';
import 'package:saaolhrmapp/data/responsedata/AutoCheckoutResponse.dart';
import 'package:saaolhrmapp/data/responsedata/CheckInActivityResponse.dart';
import 'package:saaolhrmapp/data/responsedata/CheckInResponse.dart';
import 'package:saaolhrmapp/data/responsedata/CheckOutResponse.dart';
import 'package:saaolhrmapp/data/responsedata/RefreshTokenResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/requestdata/LiveTrackingRequest.dart';
import '../../data/responsedata/LoginResponse.dart';
import 'package:http/http.dart' as http;
import '../../data/responsedata/UserProfileResponse.dart';
import '../../main.dart';
import '../app_colors.dart';


class ApiService {

  final String baseUrl = 'https://hrm.saaol.com/api/v1';


  Future<LoginResponse?> login(String username, String password, String deviceName, String deviceID) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final body = {
      'user_name': username,
      'password': password,
      'device_id': deviceID,
      'device_name': deviceName,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );


      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonResponse);

        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.setString('UserToken', loginResponse.accessToken.toString());
        await preferences.setInt('expireTokenTime', DateTime.now().millisecondsSinceEpoch + (loginResponse.expiresIn! * 1000));
        await preferences.setString('long_lived_token', loginResponse.longLivedToken.toString());
        await preferences.setString('device_id', deviceID);
        await preferences.setString('center_lat', loginResponse.centerLat.toString());
        await preferences.setString('center_long', loginResponse.centerLong.toString());
        print('CenterLong:${loginResponse.centerLong}');
        print('DeviceID:$deviceID');

        print('AccessToken: ${loginResponse.accessToken}');
        return loginResponse;
      } else {
        final jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse.containsKey('error')
            ? jsonResponse['error']
            : 'Failed to login');
      }
    } catch (error) {
      print('Error during login: $error');
      throw Exception(error.toString());
    }
  }

  Future<bool> isTokenExpired() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int? expiryTime = preferences.getInt('expireTokenTime');

    if (expiryTime == null) {
      return true; // Consider token expired if no expiry time is found
    }
    return DateTime.now().millisecondsSinceEpoch >= expiryTime;
  }

  Future<void> refreshToken() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? longLivedToken = preferences.getString('long_lived_token');
    String? deviceId =
    preferences.getString('device_id'); // Retrieve stored device ID
    print('getDeviceID:$deviceId');

    if (longLivedToken == null || deviceId == null) {
      print('No long-lived token found. Please log in again.');
      return;
    }

    final url = Uri.parse('$baseUrl/auth/refresh');
    final body = {
      'long_lived_token': longLivedToken,
      'device_id': deviceId,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final refreshTokenResponse =
        RefreshTokenResponse.fromJson(jsonResponse);

        await preferences.setString(
            'UserToken', refreshTokenResponse.accessToken.toString());
        await preferences.setInt(
            'expireTokenTime',
            DateTime.now().millisecondsSinceEpoch +
                (refreshTokenResponse.expiresIn! * 1000));

        print('Token refreshed successfully: ${refreshTokenResponse.accessToken}');
      } else {
        print('Failed to refresh token. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during token refresh: $error');
    }
  }

  Future<CheckInActivityResponse?> checkInActivity(BuildContext context, String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? validToken = prefs.getString('UserToken');

    // Step 1: Ensure token is valid before making an API request
    if (validToken == null || await isTokenExpired()) {
      print('Token expired, refreshing...');
      await refreshToken();
      validToken = prefs.getString('UserToken'); // Get updated token
    }

    if (validToken != null) {
      String apiUrl = '$baseUrl/user-activity?date=$date';

      try {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $validToken',
            'Content-Type': 'application/json',
          },
        ).timeout(const Duration(seconds: 10)); // Timeout after 10 seconds

        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          return CheckInActivityResponse.fromJson(result);
        } else if (response.statusCode == 401) {
          _showSnackBar(context, 'Session expired. Please log in again.');
          print('Token expired. Please log in again.');
          return null;
        } else {
          print('Failed to load data: ${response.statusCode}');
          return null;
        }
      } on SocketException {
        _showSnackBar(context, 'No internet connection. Please check your network.');
        return null;
      } on TimeoutException {
        _showSnackBar(context, 'Request timed out. Please try again.');
        return null;
      } catch (e) {
        _showSnackBar(context, 'Unexpected error: $e');
        return null;
      }
    }
    return null;
  }


  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }


  Future<bool> checkIn(String lat, String long, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? validToken = prefs.getString('UserToken');
    print('Check In valid token: $validToken');

    if (validToken == null || await isTokenExpired()) {
      print('Token expired, refreshing...');
      await refreshToken();
      validToken = prefs.getString('UserToken'); // Get updated token
    }

    if (validToken != null) {
      String apiUrl = '$baseUrl/check-in';
      Map<String, dynamic> requestBody = {"lat": lat, "long": long};

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $validToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );
        print('CheckIn-Api-Response: ${response.body}');
        final data = jsonDecode(response.body);
        if (response.statusCode == 200) {
          CheckInResponse checkInResponse = CheckInResponse.fromJson(data);
          print('Message: ${checkInResponse.message}');
          print('Only Distance: ${checkInResponse.distance}');
          print('Center lat: ${checkInResponse.distance}');
          print('Center lat: ${checkInResponse.centerLat}');
          print('Center long: ${checkInResponse.centerLong}');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('TotalWorking Time', checkInResponse.totalWorkingTime ?? '');
          print('Total working time:${checkInResponse.totalWorkingTime}');
          print('TotalWorking Time response:${checkInResponse.totalWorkingTime}');
          //await prefs.setString('Auto checkOut Time', checkInResponse.sessionEndTime ?? '');
          await prefs.setString('Auto checkOut Time','15:00:00');
          print('SessionTime:${checkInResponse.sessionEndTime}');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                  const SizedBox(
                      width: 12), // Add spacing between icon and text
                  Expanded(
                    child: Text(
                      checkInResponse.message ?? 'Punch-in successful!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'FontPoppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.primaryColor,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              duration: const Duration(seconds: 3),
              // Adjust duration
              elevation: 6, // Adds shadow for a better look
            ),);
          return true;
        } else if (response.statusCode == 403) {
          String errorMessage = data['message'] ?? 'You are not in range';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:Text(errorMessage,style:
              const TextStyle(fontWeight:FontWeight.w500,
                  fontFamily:'FontPoppins',fontSize:15,color:Colors.white),),
              backgroundColor: Colors.red,
            ),
          );
          print('Error: $errorMessage');
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token expired. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
          print('Token expired. Please log in again.');
        } else {
          String errorMessage = data['error'] ?? 'Failed to check In';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
          print('Failed: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid token available'),
          backgroundColor: Colors.red,
        ),
      );
      print('No valid token available');
    }
    return false;
  }

  Future<bool> checkOut(String lat, String long, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? validToken = prefs.getString('UserToken');
    print('Check Out Token: $validToken');

    if (validToken == null || await isTokenExpired()) {
      print('Token expired, refreshing...');
      await refreshToken();
      validToken = prefs.getString('UserToken'); // Get updated token
    }
    if (validToken != null) {
      String apiUrl = '$baseUrl/check-out';
      Map<String, dynamic> requestBody = {"lat": lat, "long": long};

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $validToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        print('Check-Out API Response: ${response.body}');
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          CheckOutResponse checkOutResponse = CheckOutResponse.fromJson(data);
          print('Check out Message: ${checkOutResponse.message}');
          print('Check out Distance: ${checkOutResponse.distance}');
          print('check out lat: ${checkOutResponse.centerLat}');
          print('check out long: ${checkOutResponse.centerLong}');

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('TotalWorking Time checkOut',checkOutResponse.totalWorkingTime ?? '');
          print('TotalWorking Time checkOut:${checkOutResponse.totalWorkingTime}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  // Add spacing between icon and text
                  Expanded(
                    child: Text(
                      checkOutResponse.message ?? 'Punch-Out successfully!',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'FontPoppins',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.gradientBG,
              behavior: SnackBarBehavior.floating,
              // Makes the SnackBar float
              margin: const EdgeInsets.all(16),
              // Adds margin around the SnackBar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners
              ),
              duration: const Duration(seconds: 3),
              // Adjust duration
              elevation: 6, // Adds shadow for a better look
            ),
          );

          return true;
        } else if (response.statusCode == 403) {
          String errorMessage = data['message'] ?? 'You are not in range';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage,style:
              const TextStyle(fontWeight:FontWeight.w500,
                  fontFamily:'FontPoppins',fontSize:15,color:Colors.white),),
              backgroundColor: Colors.red,
            ),
          );
          print('Error: $errorMessage');

        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token expired. Please log in again.'),
              backgroundColor: Colors.red,
            ),
          );
          print('Token expired. Please log in again.');
        }
        else {
          String errorMessage = data['error'] ?? 'Failed to check Out ';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage,
                style:const TextStyle(fontWeight:FontWeight.w500,
                  fontFamily:'FontPoppins',
                  fontSize:15,color:Colors.white),),
              backgroundColor: Colors.red,
            ),
          );
          print('Failed: ${response.statusCode} - ${response.body}');

        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No valid token available'),
          backgroundColor: Colors.red,
        ),
      );
      print('No valid token available');
    }
    return false;
  }

  Future<AttendanceReportResponse?> getReportData(BuildContext context, String date) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('UserToken');
      if (token == null || await isTokenExpired()) {
        print('Token expired, attempting refresh...');
        await refreshToken();
        token = prefs.getString('UserToken'); // Fetch updated token
        if (token == null) {
          _showSnackBar(context, 'Session expired. Please log in again.');
          return null;
        }
      }
      final String apiUrl = '$baseUrl/user-report/$date';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      // Step 3: Handle API Response
      if (response.statusCode == 200) {
        return AttendanceReportResponse.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        _showSnackBar(context, 'Token expired. Please log in again.');
        return null;
      } else {
        print("Error ${response.statusCode}: ${response.body}");
        return null;
      }
    } catch (e) {
      _showSnackBar(context, 'An error occurred. Please try again.');
      print('Error: $e');
      return null;
    }
  }

  Future<void> getUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? validToken = prefs.getString('UserToken');

    if (validToken == null || await isTokenExpired()) {
      print('Token expired, refreshing...');
      await refreshToken();
      validToken = prefs.getString('UserToken'); // Get updated token
    }
    if (validToken != null) {
      const String apiUrl = 'https://hrm.saaol.com/api/v1/auth/me';
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $validToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          UserProfileResponse userProfile = UserProfileResponse.fromJson(data);
          print('User Details Retrieved Successfully:$userProfile');
          print(
              'Name: ${userProfile.user?.firstName} ${userProfile.user?.lastName}');
          print('Email: ${userProfile.user?.email}');
          print('Mobile: ${userProfile.user?.mobileNo}');
          print('Designation ID: ${userProfile.user?.designation}');
          print('Joining Date: ${userProfile.user?.dateOfJoin}');
          // Store user details in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(ApiConstant.NAME,
              '${userProfile.user?.firstName} ${userProfile.user?.lastName}');
          await prefs.setString(
              ApiConstant.EMAIL, userProfile.user?.email ?? '');
          await prefs.setString(
              ApiConstant.MOBILE, userProfile.user?.mobileNo ?? '');
          await prefs.setString(
              ApiConstant.DATEOFJOIN, userProfile.user?.dateOfJoin ?? '');
          await prefs.setString(
              ApiConstant.DESIGNATION, userProfile.user?.designation ?? '');
          await prefs.setString(
              ApiConstant.DEPARTMENT, userProfile.user?.department ?? '');
          await prefs.setString(ApiConstant.TEAM, userProfile.user?.team ?? '');
          await prefs.setString('Image', userProfile.user?.umImage ?? '');
        } else if (response.statusCode == 401) {
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          );
          print('Token expired. Please log in again.');
        } else {
          print(
              'Failed to fetch user details: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('No valid token available');
    }
  }


  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? validToken = prefs.getString('UserToken');

    if (validToken == null || await isTokenExpired()) {
      print('Token expired, refreshing...');
      await refreshToken();
      validToken = prefs.getString('UserToken'); // Get updated token
    }
    if (validToken != null) {
      String apiUrl = 'https://hrm.saaol.com/api/v1/auth/logout';
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $validToken',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Successfully logged out',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'FontPoppins',
                    fontSize: 15,
                    color: Colors.white),
              ),
              backgroundColor: AppColors.gradientBG,
              duration: Duration(seconds: 3),
            ),
          );
          print('Status:Check-Out successfully!');
        } else if (response.statusCode == 401) {
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          );
          print('Token expired. Please log in again.');

        } else {
          final jsonResponse = jsonDecode(response.body);
          throw Exception(jsonResponse.containsKey('error')
              ? jsonResponse['error']
              : 'Failed to logOut');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('No valid token available');
    }
  }

  Future<void> autoCheckOut(String lat, String long,String sessionEndTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? validToken = prefs.getString('UserToken');

    if (validToken == null || await isTokenExpired()) {
      print('Token expired, refreshing...');
      await refreshToken();
      validToken = prefs.getString('UserToken'); // Get updated token
    }

    if (validToken != null) {
      String apiUrl = 'https://hrm.saaol.com/api/v1/auto-check-out';
      Map<String, dynamic> requestBody = {
        "lat": lat,
        "long": long,
         "session_end_time":sessionEndTime};
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $validToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );
        print("🔄 Raw API Response: ${response.body}"); // Print raw response
        Map<String, dynamic> jsonResponse;
        try {
          jsonResponse = jsonDecode(response.body);
        } catch (e) {
          print("❌ Error decoding API response: $e");
          jsonResponse = {}; // Assign an empty map to prevent reference errors
        }
        print("📌 Decoded API Response: $jsonResponse"); // Print decoded response

        if (response.statusCode == 200) {
          AutoCheckoutResponse autoCheckoutResponse = AutoCheckoutResponse.fromJson(jsonResponse);
          String message = jsonResponse['message'] ?? 'Auto Checkout Successfully';
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('AutoCheckOutTime',autoCheckoutResponse.totalWorkingTime ?? '');
          print('✅ AutoCheckout Success Message: $message');
          print('✅ AutoCheckout Full Response: $jsonResponse');
          print('AutoCheckOutTimeResponse:${autoCheckoutResponse.totalWorkingTime}');


        } else if (response.statusCode == 401) {
          String errorMessage = jsonResponse['error'] ?? 'Session expired. Please log in again.';
          print('⚠️ Token expired: $errorMessage');
          print('⚠️ Token expired. Please log in again.');
          scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(errorMessage,
                style: const TextStyle(fontWeight: FontWeight.w500,
                    fontFamily: 'FontPoppins',
                    fontSize: 16,color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );

        } else {
          String errorMessage = jsonResponse.containsKey('error')
              ? jsonResponse['error']
              : 'Auto check-out failed';
          print('❌ API Error ${response.statusCode}: $errorMessage');
        }
      } catch (e) {
        print('❌ Error in autoCheckOut: $e');
      }
    } else {
      print('⚠️ No valid token available');
    }
  }



  /*Future<void> autoCheckOut(String lat, String long) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? validToken = prefs.getString('UserToken');

    if (validToken == null || await isTokenExpired()) {
      print('Token expired, refreshing...');
      await refreshToken();
      validToken = prefs.getString('UserToken'); // Get updated token
    }

    if (validToken != null) {
      String apiUrl = 'https://hrm.saaol.com/api/v1/auto-check-out';
      Map<String, dynamic> requestBody = {"lat": lat, "long": long};
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $validToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        print('Response Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          AutoCheckoutResponse autoCheckoutResponse = AutoCheckoutResponse.fromJson(data);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('AutoCheckOutTime',autoCheckoutResponse.totalWorkingTime ?? '');
          final jsonResponse = jsonDecode(response.body);
          String message = jsonResponse['message'] ?? 'Auto Checkout Successfully';
          ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(
              content: Text(
                'Auto Checkout Successfully',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontFamily: 'FontPoppins',
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              backgroundColor: AppColors.gradientBG,
              duration: Duration(seconds: 3),
            ),);
          print('Message AutoCheckout:$message');
          print('AutoLogoutResponse:$jsonResponse');
          print('Status: $message');


        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context!).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );

          print('Token expired. Please log in again.');
        } else {
          final jsonResponse = jsonDecode(response.body);
          throw Exception(jsonResponse.containsKey('error')
              ? jsonResponse['error']
              : 'Auto checkOut failed');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('No valid token available');
    }
  }*/



  Future<void> feedback(String reason, List<File> images, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? validToken = prefs.getString('UserToken');

    if (validToken == null || await isTokenExpired()) {
      print('Token expired, refreshing...');
      await refreshToken();
      validToken = prefs.getString('UserToken'); // Get updated token
    }

    if (validToken != null) {
      String apiUrl = 'https://hrm.saaol.com/api/v1/feedback';
      try {
        var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
        request.headers.addAll({
          'Authorization': 'Bearer $validToken',
          'Content-Type': 'multipart/form-data',
          'Accept': 'application/json',
        });
        request.fields['reason'] = reason;
        for (var image in images) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'image[]',
              image.path,
              filename: basename(image.path),
            ),
          );
        }

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();
        print("Response Body: $responseBody"); // Debugging log

        if (response.statusCode == 201) {
          final jsonResponse = jsonDecode(responseBody);
          String message =
              jsonResponse['message'] ?? 'Feedback submitted successfully';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
        } else if (response.statusCode == 400) {
          final jsonResponse = jsonDecode(responseBody);
          String errorMessage = jsonResponse['error'] ??
              'Invalid request. Please check your input.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(errorMessage), backgroundColor: Colors.orange),
          );
        } else if (response.statusCode == 401) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session expired. Please log in again.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (response.statusCode == 500) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Server error. Please try again later.'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Unexpected error: ${response.statusCode}'),
                backgroundColor: Colors.red),
          );
        }
      } on SocketException {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Please check your network.'),
            backgroundColor: Colors.red,
          ),
        );
      } on HttpException {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not reach the server. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } on FormatException {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
            Text('Invalid response from server. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      } catch (e) {
        print("Exception: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('An unexpected error occurred: $e'),
              backgroundColor: Colors.red),
        );
      }
    } else {
      print('No valid token available');
    }
  }

  Future<void> liveTracking(List<TrackingData> trackingList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? validToken = prefs.getString('UserToken');

    if (validToken == null || await isTokenExpired()) {
      print('Token expired, refreshing...');
      await refreshToken();
      validToken = prefs.getString('UserToken'); // Get updated token
    }

    if (validToken != null) {
      String apiUrl = 'https://hrm.saaol.com/api/v1/livetracking';
      // ✅ Correct request format
      Map<String, dynamic> requestBody = {
        "tracking_data": trackingList.map((data) => data.toJson()).toList(),
      };

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $validToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          String message = jsonResponse['message'] ?? 'Live tracking data sent';
          print('✅ GotLatLongResponse: $jsonResponse');
          print('✅ Status: $message');
        } else if (response.statusCode == 401) {
          print('⚠️ Token expired. Please log in again.');
        } else {
          final jsonResponse = jsonDecode(response.body);
          throw Exception(jsonResponse.containsKey('error') ? jsonResponse['error'] : 'Live tracking failed');
        }
      } catch (e) {
        print('⚠️ Error sending live tracking data: $e');
      }
    } else {
      print('⚠️ No valid token available');
    }
  }



}

