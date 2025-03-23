import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constant/app_colors.dart';
import 'constant/network/ApiService.dart';


class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  _CheckInOutScreenState createState() => _CheckInOutScreenState();
}


class _CheckInOutScreenState extends State<CheckInOutScreen> {
  Timer? _timer;
  int _hours = 0, _minutes = 0, _seconds = 0;
  bool _isRunning = false;
  bool _isCheckOutVisible = false;
  bool _isLoading = false;
  String _totalTime = "No time logged yet";
  Position? _currentPosition;
  String _address = "Fetching location...";
  String? getAutoCheckOutTime = '14:37:00';
  String? totalWorkingTiming;
  final ApiService _apiService = ApiService();
  String? centerLat;
  String? centerLong;
  double? centerLatDouble;
  double? centerLongDouble;



  Future<void> _loadSavedTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      centerLat = prefs.getString('center_lat');
      centerLong = prefs.getString('center_long');
      getAutoCheckOutTime = prefs.getString('Auto checkOut Time');
      print('getAutoCheckOutTime: $getAutoCheckOutTime');
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


  Future<void> _loadSavedTime1() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Step 1: Check if the user is checked in
    bool isCheckedIn = prefs.getBool("is_checked_in") ?? false;
    if (!isCheckedIn) {
      _resetTimer(); // Reset timer if not checked in
      setState(() {
        _isCheckOutVisible = false;
      });
      return;
    }

    // Step 2: Get stored check-in time
    String? checkInTimeStr = prefs.getString("check_in_time");
    if (checkInTimeStr == null) {
      _resetTimer();
      return; // No check-in time found, reset timer and exit
    }

    DateTime checkInTime = DateTime.parse(checkInTimeStr);
    DateTime now = DateTime.now();

    // Step 3: Calculate elapsed time since check-in
    Duration elapsedTime = now.difference(checkInTime);

    // Step 4: Get stored TotalWorking Time (from API response)
    String? totalWorkingTime = prefs.getString("TotalWorking Time");
    int storedHours = 0, storedMinutes = 0, storedSeconds = 0;
    if (totalWorkingTime != null && totalWorkingTime.isNotEmpty) {
      List<String> timeParts = totalWorkingTime.split(':');
      storedHours = int.parse(timeParts[0]);
      storedMinutes = int.parse(timeParts[1]);
      storedSeconds = int.parse(timeParts[2]);
    }


    // Step 5: Add elapsed time to TotalWorking Time
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

    _startTimer(); // Resume the timer
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

  @override
  void initState() {
    super.initState();
    _loadSavedTime1();
    _loadSavedTime().then((_) {
      _startAutoCheckOutListener();
    });
  }

  Future<void> _checkIn() async {
    setState(() {
      _isLoading = true;
      _address = "Fetching location...";
    });
    // **Step 1: Check GPS Enabled**
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      await Geolocator.openLocationSettings();
      setState(() => _isLoading = false);
      return;
    }
    // **Step 2: Request Location Permission**
    PermissionStatus permission = await Permission.locationWhenInUse.request();
    if (!permission.isGranted) {
      setState(() => _isLoading = false);
      return;
    }

    try {

      Position? position;
      // **Step 3: Try Last Known Location (Faster)**
      position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Timeout in 10 seconds
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
      });


      double checkLat = 28.461428;
      double checkLong = 77.152905;

      print("Manual Location: Lat = $checkLat, Long = $checkLong");

      //await _apiService.checkIn(checkLat,checkLong,context);
      bool isCheckInSuccessful = await _apiService.checkIn(
          checkLat.toString(),
          checkLong.toString(),context);

      if(isCheckInSuccessful){

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool("is_checked_in", true);
        // Store Check-In Time (Exact Timestamp)
        DateTime now = DateTime.now();
        await prefs.setString("check_in_time", now.toIso8601String());
        await FlutterBackgroundService().startService();
        String? totalWorkingTime = prefs.getString('TotalWorking Time');
        if (totalWorkingTime != null && totalWorkingTime.isNotEmpty) {
          List<String> timeParts = totalWorkingTime.split(':');
          setState(() {
            _hours = int.parse(timeParts[0]);
            _minutes = int.parse(timeParts[1]);
            _seconds = int.parse(timeParts[2]);
            _isCheckOutVisible = true;
            _startTimer();

          });
        }
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
        _address = "Error fetching location.";
      });
    }
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

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds:15),);
      } catch (e) {
        position = await Geolocator.getLastKnownPosition();
      }
      if (position == null) {
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
      });


      bool isCheckOutSuccessful = await _apiService.checkOut(
          position.latitude.toString(),
          position.longitude.toString(),context);

      if(isCheckOutSuccessful){
        // Only proceed if check-out is successful
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? totalWorkingTime = prefs.getString('TotalWorking Time checkOut');
        String formattedTime = "$_hours HRS : $_minutes MINS : $_seconds SECS";
        String formattedTime1 = "$_hours:$_minutes:$_seconds";
        await prefs.setString('TotalTiming', formattedTime);
        await prefs.setString('workingTime', formattedTime1);

        await prefs.setBool("is_checked_in", false);
        await prefs.setInt("hours", 0);
        await prefs.setInt("minutes", 0);
        await prefs.setInt("seconds", 0);

        FlutterBackgroundService().invoke("stop_service");

        setState(() {
          _totalTime = formattedTime;
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


  void _startTimer() {
    if (_isRunning) return;
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
      _resetTimer();
      _isCheckOutVisible = false;
      _address = "Fetching location...";
    });
  }


  void _startAutoCheckOutListener() {
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? autoCheckOutTime = prefs.getString('Auto checkOut Time');

      if (autoCheckOutTime == null || autoCheckOutTime.isEmpty) {
        print("Auto Check-Out Time is not set.");
        return;
      }


      // Debugging: Print stored time
      print("Stored Auto Check-Out Time: $autoCheckOutTime");
      // Get current time
      DateTime now = DateTime.now();
      String currentTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      // Extract only HH:mm (ignoring seconds)
      List<String> timeParts = autoCheckOutTime.split(':');
      if (timeParts.length < 2) {
        print("Invalid format for Auto Check-Out Time.");
        return;
      }
      String targetTime = "${timeParts[0].padLeft(2, '0')}:${timeParts[1].padLeft(2, '0')}";

      // Debugging: Print comparison
      print("Current Time: $currentTime");
      print("Target Time: $targetTime");

      // Check if it's time for auto check-out
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

      SharedPreferences prefs = await SharedPreferences.getInstance();
      print("Auto checkOut Location: Lat = ${position.latitude}, Long = ${position.longitude}");
      String? autoCheckOutTime = prefs.getString('Auto checkOut Time');
      try {
        await _apiService.autoCheckOut(position.latitude.toString(), position.longitude.toString(),autoCheckOutTime.toString());
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


      // Reset timer in SharedPreferences
      await prefs.setInt("hours", 0);
      await prefs.setInt("minutes", 0);
      await prefs.setInt("seconds", 0);


      setState(() {
        // totalWorkingTiming = autoCheckOutTime.toString();
        _totalTime = formattedTime;
        _stopTimer();
        _timer?.cancel(); // Ensure the timer is cancelled
        _isLoading = false;
      });


      FlutterBackgroundService().invoke("stop_service");
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Fetching location...",
                    style: TextStyle(fontSize: 16, color: Colors.black)),
              ],
            )
                : Text(
              _address,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Text(
              "$_hours HRS : $_minutes MINS : $_seconds SECS",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _totalTime,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Text(totalWorkingTiming.toString(),
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            _isCheckOutVisible
                ? ElevatedButton.icon(
              onPressed:_checkOut,
              icon: const Icon(Icons.logout),
              label: const Text("Check Out"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
            )
                : ElevatedButton.icon(
              onPressed: _checkIn,
              icon: const Icon(Icons.login),
              label: const Text("Check In"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

