import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SplashScreen.dart';
import 'constant/network/ApiService.dart';
import 'data/requestdata/LiveTrackingRequest.dart';


final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  await initializeService();
  await _retryPendingCheckOut();
}


Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true, // ✅ Ensures service restarts automatically
      autoStartOnBoot:true,
      isForegroundMode: true, // ✅ Runs in foreground mode
      foregroundServiceTypes: [AndroidForegroundType.location], // ✅ Required for Android 12+
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService(); // ✅ Start the service explicitly
}


@pragma('vm:entry-point') // ✅ Fixes the error
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "SafetyCircle",
      content: "Background location tracking is active...",
    );
  }


  DateTime lastLocationUpdate = DateTime.now();
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    final prefs = await SharedPreferences.getInstance();
    bool isCheckedIn = prefs.getBool("is_checked_in") ?? false;

    if (!isCheckedIn) {
      service.stopSelf();
      timer.cancel();
      return;
    }

    // ✅ Ensure location updates happen exactly every 60 seconds
    DateTime now1 = DateTime.now();
    if (now1.difference(lastLocationUpdate).inSeconds >= 60) {
      lastLocationUpdate = now1;

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15),
        );

        String timestamp = DateTime.now().toIso8601String();
        TrackingData trackingData = TrackingData(
          lat: position.latitude,
          long: position.longitude,
          dateTime: timestamp,
        );

        bool isOnline = await checkInternetConnection();
        if (isOnline) {
          // ✅ Send directly to API
          await ApiService().liveTracking([trackingData]);
          print("✅ Live tracking data sent successfully.");
          // ✅ Send any stored offline locations
          await sendStoredLocations();
        } else {
          // ✅ Save location locally
          await saveLocationOffline(trackingData);
          print("❌ No internet, location saved locally.");
        }
      } catch (e) {
        print("⚠️ Failed to fetch location: $e");
      }
    }




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

    // Check if it's time for auto check-out
    if (currentTime == targetTime) {
      print("Auto Check-Out Triggered!");
      timer.cancel(); // Stop timer after execution
      await _autoCheckOutBackground();
      service.stopSelf(); // Stop background service after checkout
    }


    // Timer Update Logic
    int hours = prefs.getInt("hours") ?? 0;
    int minutes = prefs.getInt("minutes") ?? 0;
    int seconds = prefs.getInt("seconds") ?? 0;

    if (seconds == 59) {
      seconds = 0;
      if (minutes == 59) {
        minutes = 0;
        hours++;
      } else {
        minutes++;
      }
    } else {
      seconds++;
    }

    await prefs.setInt("hours", hours);
    await prefs.setInt("minutes", minutes);
    await prefs.setInt("seconds", seconds);

    service.invoke("update_timer", {
      "hours": hours,
      "minutes": minutes,
      "seconds": seconds,
    });
  });

  service.on("stop_service").listen((event) {
    service.stopSelf();
  });
}


Future<void> _autoCheckOutBackground() async {
  final prefs = await SharedPreferences.getInstance();

  try {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      print("GPS is disabled. Auto Check-Out failed.");
      return;
    }

    Position? position;

    try {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30), // Increased timeout
      );
    } catch (e) {
      print("Location fetch timed out, trying last known position...");
      position = await Geolocator.getLastKnownPosition();
    }

    if (position == null) {
      print("Failed to get location even after fallback.");
      return;
    }


    print("Auto Check-Out Location (Background): Lat = ${position.latitude}, Long = ${position.longitude}");
    // Check internet connection
    bool hasInternet = await _hasInternetConnection();
    String? sessionEndTime = prefs.getString('Auto checkOut Time');

    if (hasInternet) {
      try {
        await ApiService().autoCheckOut(position.latitude.toString(), position.longitude.toString(),sessionEndTime.toString());
        await Future.delayed(const Duration(milliseconds: 500)); // Small delay to allow storage update
        print("✅ Auto Check-Out sent to server.");
      } catch (e) {
        print("❌ Failed to send auto check-out data: $e. Saving locally...");
        await _saveOfflineCheckOut(position.latitude, position.longitude);
      }
    } else {
      print("📴 No internet. Saving check-out data locally...");
      await _saveOfflineCheckOut(position.latitude, position.longitude);
    }

    // ✅ Store Auto Check-Out Time, TotalTiming, and savedDate in both online and offline cases
    String? autoCheckOutTime = prefs.getString('AutoCheckOutTime');

    if (autoCheckOutTime != null && autoCheckOutTime.isNotEmpty) {
      print("✅ Updated Auto Check-Out Time: $autoCheckOutTime");
      await prefs.setString('TotalTiming', autoCheckOutTime); // ✅ Store in TotalTiming as well
      print("✅ TotalTiming stored in Background: $autoCheckOutTime");
      String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await prefs.setString('savedDate', currentDate);
    } else {
      print("⚠️ AutoCheckOutTime not updated yet.");
    }

    await prefs.setBool("is_checked_in", false);
    await _resetTimer(); // Reset timer properly
    FlutterBackgroundService().invoke("stop_service");
    print("Auto Check-Out Completed in Background. Service stopped.");


  } catch (e) {
    print("Auto Check-Out Failed in Background: $e");
  }
}


Future<bool> _hasInternetConnection() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    return false;
  }
}
Future<void> _saveOfflineCheckOut(double lat, double lon) async {
  final prefs = await SharedPreferences.getInstance();
  String checkOutData = "$lat,$lon,${DateTime.now().toIso8601String()}";
  await prefs.setString('pendingCheckOut', checkOutData);
  print("⏳ Check-out data saved for later sync: $checkOutData");
}

Future<void> _retryPendingCheckOut() async {
  final prefs = await SharedPreferences.getInstance();
  String? pendingCheckOut = prefs.getString('pendingCheckOut');
  String? sessionEndTime = prefs.getString('Auto checkOut Time');

  if (pendingCheckOut != null) {
    List<String> data = pendingCheckOut.split(',');
    double lat = double.parse(data[0]);
    double lon = double.parse(data[1]);
    String timestamp = data[2];


    try {
      await ApiService().autoCheckOut(lat.toString(), lon.toString(),sessionEndTime.toString());
      await prefs.remove('pendingCheckOut'); // Clear stored data after successful sync
      print("✅ Offline check-out data sent successfully!");

      // ✅ Ensure AutoCheckOutTime, TotalTiming, and savedDate are updated
      String? autoCheckOutTime = prefs.getString('AutoCheckOutTime');
      if (autoCheckOutTime != null && autoCheckOutTime.isNotEmpty) {
        print("✅ Updated Auto Check-Out Time: $autoCheckOutTime");
        await prefs.setString('TotalTiming', autoCheckOutTime); // ✅ Store in TotalTiming as well
        print("✅ TotalTiming stored after offline sync: $autoCheckOutTime");
        String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await prefs.setString('savedDate', currentDate);

      } else {
        print("⚠️ AutoCheckOutTime not updated yet.");
      }
      // ✅ Stop the background service after successful check-out sync
      FlutterBackgroundService().invoke("stop_service");
      print("🛑 Background service stopped after offline check-out sync.");
      await _resetTimer();
      print("⏳ Timer reset after offline check-out sync.");

    } catch (e) {
      print("❌ Still unable to send check-out data: $e");
    }
  }
}


Future<void> _resetTimer() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt("hours", 0);
  await prefs.setInt("minutes", 0);
  await prefs.setInt("seconds", 0);
  print("Timer reset successfully in background.");

}

Future<bool> checkInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    return false;
  }
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
Future<void> saveLocationOffline(TrackingData trackingData) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> offlineLocations = prefs.getStringList("offline_locations") ?? [];

  offlineLocations.add(jsonEncode(trackingData.toJson()));

  await prefs.setStringList("offline_locations", offlineLocations);
}

Future<void> sendStoredLocations() async {
  final prefs = await SharedPreferences.getInstance();
  List<String> offlineLocations = prefs.getStringList("offline_locations") ?? [];

  if (offlineLocations.isNotEmpty) {
    print("📤 Sending ${offlineLocations.length} stored locations to API...");

    List<TrackingData> trackingList = offlineLocations.map((data) {
      return TrackingData.fromJson(jsonDecode(data));
    }).toList();

    try {
      await ApiService().liveTracking(trackingList);
      print("✅ Sent all offline locations successfully.");

      await prefs.remove("offline_locations");
    } catch (e) {
      print("⚠️ Failed to send stored locations: $e");
    }
  }
}

@pragma('vm:entry-point') // ✅ Required for background execution
bool onIosBackground(ServiceInstance service) {
  return true;
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const SplashScreen());
  }
}

