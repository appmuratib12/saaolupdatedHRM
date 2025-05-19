import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'AllCheckInActivity.dart';
import 'MyProfileScreen.dart';
import 'NotificationScreen.dart';
import 'constant/ConstantValues.dart';
import 'constant/app_colors.dart';
import 'constant/network/ApiService.dart';
import 'data/requestdata/LiveTrackingRequest.dart';
import 'data/responsedata/CheckInActivityResponse.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isCheckedIn = false;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    _loadSavedTime();
    _loadSavedTime1();
    _fetchCheckInActivity();
    _loadLatLong().then((_) {
      _startAutoCheckOutListener();
    });
  }

  Future<CheckInActivityResponse?>? _checkInActivityFuture;

  Future<void> _fetchCheckInActivity() async {
    setState(() {
      _checkInActivityFuture = ApiService().checkInActivity(
          context, DateFormat('yyyy-MM-dd').format(DateTime.now()));
    });
  }


  late SharedPreferences sharedPreferences;
  String subLocality = '';
  String street = '';
  String userName = '';
  String locality = '';
  String department = '';
  String? image;
  String? getAutoCheckOutTime;
  String? totalWorkingTiming;

  Future<void> fetchUserDetails() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      userName = sharedPreferences.getString(ApiConstant.NAME) ?? 'N/A';
      department = sharedPreferences.getString(ApiConstant.DEPARTMENT) ?? 'N/A';
      image = sharedPreferences.getString('Image') ?? 'N/A';
      locality = sharedPreferences.getString('locality') ?? '';
      subLocality = sharedPreferences.getString('sublocality') ?? 'N/A';
      print('Name:$userName');
      print('Locality:$locality');
    });
  }
  Future<void> _loadSavedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTime = prefs.getString('TotalTiming');  // Manual checkout time
    String? savedWorkTime = prefs.getString('workingTime');
    String? autoCheckOutTime = prefs.getString('AutoCheckOutTime'); // Auto checkout time
    String? savedDate = prefs.getString('savedDate'); // Fetch the stored date

    // Get current date
    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (savedDate == currentDate) {
      // If saved date is today, determine which time to display
      if (savedTime != null && savedTime.isNotEmpty) {
        _totalTime = savedTime; // Prioritize manual checkout time
      } else if (autoCheckOutTime != null && autoCheckOutTime.isNotEmpty) {
        _totalTime = autoCheckOutTime; // Otherwise, use auto checkout time
        workingTime = savedWorkTime.toString();
      } else {
        _totalTime = "";
         workingTime = "";
      }
      setState(() {
        workingTime = savedWorkTime ?? "No time";
        print("✅ Loaded TotalTiming: $_totalTime, AutoCheckOutTime: $autoCheckOutTime");
      });

    } else {
      // If the date is different (next day), clear stored time
      await prefs.remove('TotalTiming');
      await prefs.remove('AutoCheckOutTime');
      await prefs.remove('workingTime');
      await prefs.remove('savedDate');

      setState(() {
        _totalTime = "";
        workingTime = "No time";
        print("✅ Cleared old TotalTiming & AutoCheckOutTime as the date changed.");
      });
    }
  }


  String? centerLat;
  String? centerLong;
  double? centerLatDouble;
  double? centerLongDouble;
  String? TotalTiming;

  Future<void> _loadLatLong() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      centerLat = prefs.getString('center_lat');
      centerLong = prefs.getString('center_long');
      getAutoCheckOutTime = prefs.getString('Auto checkOut Time');
      //totalWorkingTiming = prefs.getString('AutoCheckOutTime') ??'';
      //TotalTiming = prefs.getString('TotalTiming') ??'';
      print('TotalTiming:$TotalTiming');
      print('totalWorkingTiming:$totalWorkingTiming');
      print('getAutoCheckOutTime: $getAutoCheckOutTime');
      print('AutoCheckOutTime: $_totalTime');
      if (centerLat != null && centerLong != null) {
        centerLatDouble = double.tryParse(centerLat!);
        centerLongDouble = double.tryParse(centerLong!);
      }
      print('Center Latitude (String): $centerLat');
      print('Center Longitude (String): $centerLong');
      print('Center Latitude (Double): $centerLatDouble');
      print('Center Longitude (Double): $centerLongDouble');

    });
  }
  void showThankYouDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -10,
                top: -10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.primaryColor),
                  // Replace AppColors.primaryColor
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Confirmation!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors
                            .gradientBG, // Replace AppColors.primaryColor
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Are you sure you want to check out?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'FontPoppins'),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cancel Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: AppColors.primaryColor, width: 2),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontFamily: 'FontPoppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gradientBG,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Check Out Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onConfirm(); // Call the function passed from the parent
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gradientBG,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Check out',
                            style: TextStyle(
                              fontFamily: 'FontPoppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  void _handleCheckOut() {
    _checkOut();
  }
  void _stopTimerWithConfirmation() {
    showThankYouDialog(context, _handleCheckOut);
  }

  Timer? _timer;
  int _hours = 0, _minutes = 0, _seconds = 0;
  bool _isRunning = false;
  bool _isCheckOutVisible = false;
  bool _isLoading = false;
  String? _totalTime;
  String workingTime = "No time";
  Position? _currentPosition;
  String _address = "Fetching location...";
  Timer? _foregroundLocationTimer;
  String? checkOutTiming;


  final ApiService _apiService = ApiService();
  void _startForegroundLocationTracking() {
    _foregroundLocationTimer?.cancel(); // Cancel existing timer
    _foregroundLocationTimer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      print("Foreground location tracking triggered");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isCheckedIn = prefs.getBool("is_checked_in") ?? false;

      if (!isCheckedIn) {
        print("User is not checked in, stopping foreground tracking.");
        timer.cancel();
        return;
      }

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds:30),
        );
        print("Foreground Tracking Location: ${position.latitude}, ${position.longitude}");
        String timestamp = DateTime.now().toIso8601String();
        TrackingData trackingData = TrackingData(
          lat: position.latitude,
          long: position.longitude,
          dateTime: timestamp,
        );
        await ApiService().liveTracking([trackingData]);
        print("Foreground tracking data sent to API successfully.");
      } catch (e) {
        print("Foreground location fetch failed: $e");
      }
    });
  }
  void _stopForegroundLocationTracking() {
    _foregroundLocationTimer?.cancel();
  }

  Future<void> _loadSavedTime1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isCheckedIn = prefs.getBool("is_checked_in") ?? false;
    if (!isCheckedIn) {
      _resetTimer(); // Reset timer if not checked in
      setState(() {
        _isCheckOutVisible = false;
      });
      return;
    }
    String? checkInTimeStr = prefs.getString("check_in_time");
    if (checkInTimeStr == null) {
      _resetTimer();
      return; // No check-in time found, reset timer and exit
    }

    DateTime checkInTime = DateTime.parse(checkInTimeStr);
    DateTime now = DateTime.now();
    Duration elapsedTime = now.difference(checkInTime);
    String? totalWorkingTime = prefs.getString("TotalWorking Time");
    int storedHours = 0, storedMinutes = 0, storedSeconds = 0;
    if (totalWorkingTime != null && totalWorkingTime.isNotEmpty) {
      List<String> timeParts = totalWorkingTime.split(':');
      storedHours = int.parse(timeParts[0]);
      storedMinutes = int.parse(timeParts[1]);
      storedSeconds = int.parse(timeParts[2]);
    }
    int totalSeconds = (storedHours * 3600 + storedMinutes * 60 + storedSeconds) + elapsedTime.inSeconds;
    int newHours = totalSeconds ~/ 3600;
    int newMinutes = (totalSeconds % 3600) ~/ 60;
    int newSeconds = totalSeconds % 60;

    setState(() {
      _hours = newHours;
      _minutes = newMinutes;
      _seconds = newSeconds;
      _isCheckOutVisible = true;
    });
    if (_isCheckOutVisible) {
      _startTimer();
    }
  }

  void _resetTimer() {
    setState(() {
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
    });
  }



  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkIn() async {
    if (_isLoading) return; // Prevent multiple clicks

    setState(() {
      _isLoading = true;
      _address = "Fetching location...";
    });
    // **Step 1: Check GPS Enabled**
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      _showSnackBar('Please enable GPS for check-in.', Colors.red);
      await Geolocator.openLocationSettings();
      setState(() => _isLoading = false);
      return;
    }
    // **Step 2: Request Location Permission**
    PermissionStatus permission = await Permission.locationWhenInUse.request();
    if (!permission.isGranted) {
      setState(() => _isLoading = false);
      _showSnackBar('Location permission is required to Check In.', Colors.red);
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );

      print("Current Location: Lat = ${position.latitude}, Long = ${position.longitude}");

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        Placemark place = placemarks.first;
        print("Locality: ${place.locality}");
        print("SubLocality: ${place.subLocality}");
        print("Postal Code: ${place.postalCode}");

        setState(() {
          _currentPosition = position;
          _isLoading = false;
          _address = "${place.locality}, ${place.subLocality}, ${place.postalCode}";
          _addCurrentLocationMarker();
        });

      // **Prevent multiple check-ins**
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isAlreadyCheckedIn = prefs.getBool("is_checked_in");
      if (isAlreadyCheckedIn == true) {
        _showSnackBar("You are already checked in.", Colors.orange);
        setState(() => _isLoading = false);
        return;
      }

      bool isCheckInSuccessful = await _apiService.checkIn(
          position.latitude.toString(),
          position.longitude.toString(),context);

      if(isCheckInSuccessful){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("is_checked_in", true);
        DateTime now = DateTime.now();
        await prefs.setString("check_in_time",now.toIso8601String());
        print('check_in_time:${now.toIso8601String()}');
        String? totalWorkingTime = prefs.getString('TotalWorking Time');
        await FlutterBackgroundService().startService();
        _startForegroundLocationTracking();
        await _fetchCheckInActivity();

        if (totalWorkingTime != null && totalWorkingTime.isNotEmpty) {
          List<String> timeParts = totalWorkingTime.split(':');
          setState(() {
            _hours = int.parse(timeParts[0]);
            _minutes = int.parse(timeParts[1]);
            _seconds = int.parse(timeParts[2]);
            _isCheckOutVisible = true;
          });
          if (!_isRunning) {
            _startTimer();
          }
        }
      }

    } catch (e) {
      print("Error getting current location: $e");
      _showSnackBar("Unable to fetch location. Please try again.", Colors.red);
    }finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: 'FontPoppins',
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
      ),
    );
  }
  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        if (_seconds == 59) {
          _seconds = 0;
          if (_minutes == 59) {
            _minutes = 0;
            _hours++;
          } else {
            _minutes++;
          }
        } else {
          _seconds++;
        }
      });
      // Save updated time in SharedPreferences
      await prefs.setInt("hours", _hours);
      await prefs.setInt("minutes", _minutes);
      await prefs.setInt("seconds", _seconds);
    });
  }
  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _totalTime = "$_hours HRS : $_minutes MINS : $_seconds SECS";
       workingTime = "$_hours:$_minutes:$_seconds";
      _resetTimer();
      _isCheckOutVisible = false;
      _address = "Fetching location...";
    });
  }
  Future<void> _checkOut() async {
    setState(() {
      _isLoading = true;
      _address = "Fetching location...";
    });
    try {

      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please enable GPS for check-out.',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: 'FontPoppins',
                  fontSize: 15,
                  color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        await Geolocator.openLocationSettings();
        setState(() => _isLoading = false);
        return;
      }
      PermissionStatus permission = await Permission.locationWhenInUse.request();
      if (!permission.isGranted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required to Check Out.')),
        );
        return;
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds:30),);
      } catch (e) {
        _showSnackBar('Unable to fetch current location. Please try again.', Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      print("Check-out Location: Lat = ${position.latitude}, Long = ${position.longitude}");

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        Placemark place = placemarks.first;
        setState(() {
          _currentPosition = position;
          _address =
          "${place.locality}, ${place.subLocality}, ${place.postalCode}";
          _isLoading = false;
          _addCurrentLocationMarker();
        });

        bool isCheckOutSuccessful = await _apiService.checkOut(
         position.latitude.toString(),position.longitude.toString(),context);

      if(isCheckOutSuccessful){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? totalWorkingTime = prefs.getString('TotalWorking Time checkOut');
        String formattedTime = "$_hours HRS : $_minutes MINS : $_seconds SECS";
        String formattedTime1 = "$_hours:$_minutes:$_seconds";
        await prefs.setString('TotalTiming', formattedTime);
        await prefs.setString('workingTime', formattedTime1);
        await prefs.setString('savedDate', DateFormat('yyyy-MM-dd').format(DateTime.now()));

        await prefs.setBool("is_checked_in", false);
        await prefs.setInt("hours", 0);
        await prefs.setInt("minutes", 0);
        await prefs.setInt("seconds", 0);

        FlutterBackgroundService().invoke("stop_service");
        _stopForegroundLocationTracking(); // Stop foreground tracking
        await _fetchCheckInActivity();

        setState(() {
          _totalTime = formattedTime;
          checkOutTiming = totalWorkingTime.toString();
          // _totalTime = totalWorkingTime.toString();
          workingTime = formattedTime1;
          _stopTimer();
        });
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
        _address = "Error fetching location.";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error fetching location. Cannot Check Out!',
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'FontPoppins',
                fontSize: 15,
                color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _startAutoCheckOutListener() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? autoCheckOutTime = prefs.getString('Auto checkOut Time');

      if (autoCheckOutTime == null || autoCheckOutTime.isEmpty) {
        print("Auto Check-Out Time is not set.");
        return;
      }

      print("Stored Auto Check-Out Time: $autoCheckOutTime");
      DateTime now = DateTime.now();
      String currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      List<String> timeParts = autoCheckOutTime.split(':');
      if (timeParts.length < 2) {
        print("Invalid format for Auto Check-Out Time.");
        return;
      }
      String targetTime = "${timeParts[0].padLeft(2, '0')}:${timeParts[1].padLeft(2, '0')}";
      print("Current Time: $currentTime");
      print("Target Time: $targetTime");
      if (currentTime == targetTime) {
        print("Auto Check-Out Triggered!");
        timer.cancel(); // Stop timer after execution
        _autoCheckOut();
      }
    });
  }
  Future<void> _autoCheckOut() async {
    setState(() {
      _isLoading = true;
      _address = "Fetching location...";
    });

    try {
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        _showSnackBar('Please enable GPS', Colors.red);
        await Geolocator.openLocationSettings();
        setState(() => _isLoading = false);
        return;
      }


      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds:20),
        );
      } on TimeoutException {
        print("❌ Location fetch timed out.");
        setState(() {
          _isLoading = false;
          _address = "Error fetching location.";
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to fetch location. Try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ));
        return;
      }


      print("Auto checkOut Location: Lat = ${position.latitude}, Long = ${position.longitude}");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionEndTime = prefs.getString('Auto checkOut Time');

      try {
        await _apiService.autoCheckOut(position.latitude.toString(), position.longitude.toString(),sessionEndTime.toString());
      } catch (apiError) {
        print("API Call Error: $apiError");
        rethrow;
      }

      await prefs.setBool("is_checked_in", false); // Ensure is_checked_in is false
      String formattedTime = "$_hours HRS : $_minutes MINS : $_seconds SECS";
      String formattedTime1 = "$_hours: $_minutes: $_seconds";
      await prefs.setString('TotalTiming', formattedTime);
      await prefs.setString('workingTime',formattedTime1);
      print("✅ TotalTiming stored: $formattedTime");
      print("✅ workingTime stored: $formattedTime1");
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await prefs.setString('savedDate', currentDate);


      // Reset timer in SharedPreferences
      await prefs.setInt("hours", 0);
      await prefs.setInt("minutes", 0);
      await prefs.setInt("seconds", 0);


      setState(() {
        // totalWorkingTiming = autoCheckOutTime.toString();
        _totalTime = formattedTime;
        workingTime = formattedTime;
        _stopTimer();
        _timer?.cancel(); // Ensure the timer is cancelled
        _isLoading = false;
      });

      FlutterBackgroundService().invoke("stop_service");
      _stopForegroundLocationTracking(); // Stop foreground tracking
      print("Auto Check-Out Completed, service stopped.");

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Auto Checkout Successfully',
          style: TextStyle(fontWeight: FontWeight.w600,
              fontFamily: 'FontPoppins', fontSize: 16, color: Colors.white),),
        backgroundColor: AppColors.gradientBG,
        duration: Duration(seconds: 3),
      ),);

    } catch (e) {
      print("❌ Auto Check-Out Error: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _address = "Error fetching location.";
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Auto Check-Out Failed. Try again.',
            style: TextStyle(fontWeight: FontWeight.w500,
                fontFamily: 'FontPoppins', fontSize: 16, color: Colors.white),),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),);
      }
    }
  }

  String? firstLogin;

  String formatTime(String? time) {
    if (time == null || time.trim().isEmpty) return ''; // Handle null or empty cases safely
    try {
      DateTime dateTime = DateFormat("HH:mm:ss").parseStrict(time.trim());
      return DateFormat("hh:mm a").format(dateTime);
    } catch (e) {
      print("Error formatting time: $e");
      return ''; // Return empty string if formatting fails
    }
  }

  late GoogleMapController mapController;
  final Set<Marker> _markers = {};

  Future<BitmapDescriptor> _getCustomMarker() async {
    ByteData data = await rootBundle.load(
        'assets/images/location_logo.png'); // Ensure this image exists in assets
    Uint8List bytes = data.buffer.asUint8List();
    ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 100);
    ui.FrameInfo fi = await codec.getNextFrame();
    ByteData? byteData =
    await fi.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
  void _addCurrentLocationMarker() async {
    if (_currentPosition != null) {
      final BitmapDescriptor customIcon = await _getCustomMarker();

      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            infoWindow: const InfoWindow(title: 'You are here'),
            icon: customIcon,
          ),
        );
      });

      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0, // Adjust zoom level as needed
        ),
      );
    }
  }
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }


  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.grey[200],
      /*floatingActionButton: FloatingActionButton(
        backgroundColor:AppColors.primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LeaveRequestScreen()),
          );
        },
        child:const Icon(Icons.add,color:Colors.white,size:22,),  // Plus sign icon
      ),*/
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      padding:
                      const EdgeInsets.only(top: 45, left: 15, right: 15),
                      height: 230,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(200, 253, 106, 111),
                            Color.fromARGB(200, 255, 155, 68),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                          const MyProfileScreen(), // Replace with your screen
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 30,
                                      backgroundImage: image != null &&
                                          image!.isNotEmpty
                                          ? NetworkImage(image!)
                                          : const AssetImage(
                                          'assets/images/profile.png')
                                      as ImageProvider,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userName != null && userName.isNotEmpty
                                            ? 'Hi, ${userName[0].toUpperCase()}${userName.substring(1)}'
                                            : 'Hi, Guest',
                                        // Default message if username is empty
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontFamily: 'FontPoppins',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        department,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'FontPoppins',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                   Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                      const NotificationScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Center(
                                      child: Icon(
                                        Icons.notifications,
                                        color: AppColors.primaryColor,
                                      )),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'FontPoppins',
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(
                                    firstLogin != null && firstLogin.toString().trim().isNotEmpty
                                        ? formatTime(firstLogin.toString())
                                        : '', // Default text when empty or null
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'FontPoppins',
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 150),
                      child: Container(
                        margin: const EdgeInsets.all(16.0),
                        padding: const EdgeInsets.all(18.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TimeWidget(time: _hours.toString().padLeft(2, '0'),
                                    label: 'HRS'),
                                const SizedBox(width: 8),
                                TimeWidget(
                                    time: _minutes.toString().padLeft(2, '0'),
                                    label: 'MINS'),
                                const SizedBox(width: 8),
                                TimeWidget(
                                    time: _seconds.toString().padLeft(2, '0'),
                                    label: 'SECS'),
                              ],
                            ),
                            const SizedBox(height:10),
                            Text(
                              (_totalTime != null && _totalTime!.isNotEmpty) ? _totalTime! : '',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontFamily: 'FontPoppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height:15),

                            // Buttons
                            _isCheckOutVisible
                                ? ElevatedButton.icon(
                              onPressed: _stopTimerWithConfirmation,
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              label: const Text("Punch Out",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'FontPoppins',
                                      fontSize: 15,
                                      color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gradientBG,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25, vertical: 10),
                              ),
                            )
                                : ElevatedButton.icon(
                              onPressed:_isLoading ? null : _checkIn, // Disable button when loading
                              icon: const Icon(
                                Icons.login,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Punch In",
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'FontPoppins',
                                    fontSize: 15,
                                    color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(left: 16, top: 12),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today working hour',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'FontPoppins',
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ActivityIcon(icon: Icons.access_time, time: workingTime.toString()),
                          const ActivityIcon(icon: Icons.pause, time: '--:--'),
                          const ActivityIcon(icon: Icons.work, time: '00:00:00'),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Today Your Activity',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontFamily: 'FontPoppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) =>
                                  const AllCheckInActivity(),
                                ),
                              );
                            },
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                  fontFamily: 'FontPoppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: AppColors.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<CheckInActivityResponse?>(
                    future: _checkInActivityFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        final errorMessage = snapshot.error.toString();
                        if (errorMessage.contains('No internet connection')) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.wifi_off_rounded,
                                    size:30,
                                    color: Colors.redAccent,
                                  ),
                                  SizedBox(height:8),
                                  Text(
                                    'No Internet Connection',
                                    style: TextStyle(
                                      fontSize:14,
                                      fontFamily: 'FontPoppins',
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Please check your network settings and try again.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize:12,
                                      fontFamily: 'FontPoppins',
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Center(child: Text('Error: $errorMessage'));
                        }
                        print('Error fetching centers: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data!.userActivity == null || snapshot.data!.userActivity!.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 12),
                                Icon(
                                  Icons.hourglass_empty,
                                  size:30,
                                  color:AppColors.primaryColor
                                ),
                                SizedBox(height:10),
                                Text(
                              'No Activity Data Available',
                              style: TextStyle(
                                fontSize:14,
                                fontFamily: 'FontPoppins',
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                                SizedBox(height: 8),
                                Text(
                                  'Please check back later.\nNew data will be available soon!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:12,
                                    fontFamily: 'FontPoppins',
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        final activityData = snapshot.data!.userActivity!;
                        final displayedActivities = activityData.take(3).toList();
                        if (firstLogin == null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              firstLogin = snapshot.data!.firstLoginTime?.toString() ?? "No Data";
                            });
                          });
                        }

                        return Container(
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.symmetric(vertical:5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'FontPoppins',
                                    fontSize: 16,
                                    color: AppColors.gradientBG,
                                  ),
                                ),
                                const SizedBox(height:10),
                                Column(
                                  children: List.generate(displayedActivities.length, (index) {
                                    final activity = displayedActivities[index];
                                    return Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                                          child: Column(
                                            children: [
                                              _buildActivityRow(Icons.login, "Check in", activity.loginTime.toString()),
                                              _buildActivityRow(Icons.logout, "Check out", activity.logoutTime.toString()),
                                              _buildActivityRow(Icons.work_history, "Working hrs", activity.workingHours.toString()),
                                            ],
                                          ),
                                        ),
                                        if (index < displayedActivities.length - 1) const Divider(), // Add divider between items
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            )
                        );
                      }
                    },
                  ),
                  ],
                  ),
                ),
                Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/map_image.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Container(
                      height: 180,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primaryColor, width: 0.5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: _currentPosition == null
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.primaryColor,
                              size: 40,
                            ),
                            Expanded(
                              child: Text(
                                _address,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'FontPoppins',
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        )
                            : GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            zoom: 14.0,
                          ),
                          markers: _markers, // Dynamic markers
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                // Semi-transparent background
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryColor),
                              strokeWidth: 6,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Fetching location...",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'FontPoppins',
                                  color: AppColors.gradientBG),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}


class TimeWidget extends StatelessWidget {
  final String time;
  final String label;

  const TimeWidget({super.key, required this.time, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(200, 253, 106, 111),
                Color.fromARGB(200, 255, 155, 68),
              ],
            ),
          ),
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 22,
              fontFamily: 'FontPoppins',
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(
          height: 4,
        ), // Space between the time and label
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'FontPoppins',
            color: AppColors.gradientBG,
          ),
        ),
      ],
    );
  }
}

class ActivityIcon extends StatelessWidget {
  final IconData icon;
  final String time;

  const ActivityIcon({super.key, required this.icon, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding:EdgeInsets.all(10),
          decoration:BoxDecoration(
            color:AppColors.gradientBG.withOpacity(0.2),
            shape:BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          time,
          style: const TextStyle(
              color: Colors.black54,
              fontFamily: 'FontPoppins',
              fontWeight: FontWeight.w500,
              fontSize: 14),
        ),
      ],
    );
  }
}

Widget _buildActivityRow(IconData icon, String title, String value) {
  return Row(
    children: [
      Icon(icon, color: AppColors.primaryColor, size: 22),
      const SizedBox(width: 16),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'FontPoppins',
            fontSize: 15,
            color: Colors.black,
          ),
        ),
      ),
      Text(
        (value == "null" || value == null || value == "00:00:00") ? "" : value, // Hide "00:00:00"
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'FontPoppins',
          fontSize: 15,
          color: Colors.black,
        ),
      ),

    ],
  );
}

class ActivityTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  final String checkOutTitle;
  final String checkOutTime;
  final IconData checkOutIcon;
  final String workinghrsTitle;
  final String workinghrsTime;
  final IconData workinghrsIcon;

  const ActivityTile({
    super.key,
    required this.icon,
    required this.title,
    required this.time,
    required this.checkOutTitle,
    required this.checkOutTime,
    required this.checkOutIcon,
    required this.workinghrsTitle,
    required this.workinghrsTime,
    required this.workinghrsIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              Icon(
                icon,
                color: AppColors.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'FontPoppins',
                          fontSize: 15,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Text(time,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'FontPoppins',
                      fontSize: 15,
                      color: Colors.black)),
            ],
          ),
          Row(
            children: [
              Icon(
                checkOutIcon,
                color: AppColors.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      checkOutTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'FontPoppins',
                          fontSize: 15,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Text(checkOutTime,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'FontPoppins',
                      fontSize: 15,
                      color: Colors.black)),
            ],
          ),
          Row(
            children: [
              Icon(
                workinghrsIcon,
                color: AppColors.primaryColor,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workinghrsTitle,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontFamily: 'FontPoppins',
                          fontSize: 15,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
              Text(workinghrsTime,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'FontPoppins',
                      fontSize: 15,
                      color: Colors.black)),
            ],
          ),
        ],
      ),
    );
  }
}

