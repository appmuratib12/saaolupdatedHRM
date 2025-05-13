import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'constant/app_colors.dart';
import 'constant/database/NotificationDatabase.dart';
import 'data/requestdata/NotificationData.dart';
import 'get_server_key.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
NotificationDatabase databaseHelper = NotificationDatabase.instance;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification}');
  if (message.notification != null) {
    final notification = NotificationData(
      title: message.notification!.title!,
      body: message.notification!.body!,
      imageUrl: message.notification!.android!.imageUrl!,
    );
    print("***$notification");
    await NotificationDatabase.instance.insertNotification(notification);
  }
}

Future<void> FirebaseMessage(String title, String subtitle) async {
  String? deviceToken = await FirebaseMessaging.instance.getToken();
  final get = get_server_key();
  String token22222 = await get.server_token();
  log('bearerToken: $token22222');
  try {
    final body = {
      "message": {
        "token": deviceToken,
        "notification": {
          "title": title,
          "body": subtitle,
          "image": ""
          // URL of the image
        },
        "android": {
          "notification": {
            "sound": "muratibtone",
            "channel_id": "custom_channel_id",
            "image": "https://yt3.googleusercontent.com/TMw8wmvqfYG-eqcjsuC45PUqy0lCnpkXvAxoKnI-fEz7uShU7U3WKq7dH9piNVXPANjpauNq=s900-c-k-c0x00ffffff-no-rj"
          }
        },
        "apns": {
          "payload": {
            "aps": {"sound": "muratibtone.mp3", "mutable-content": 1}
          },
          "fcm_options": {
            "image": "https://yt3.googleusercontent.com/TMw8wmvqfYG-eqcjsuC45PUqy0lCnpkXvAxoKnI-fEz7uShU7U3WKq7dH9piNVXPANjpauNq=s900-c-k-c0x00ffffff-no-rj"
          }
        },
        "data": {
          "screen": "second",
          "title": title,
          "body": subtitle,
          "image": "https://yt3.googleusercontent.com/TMw8wmvqfYG-eqcjsuC45PUqy0lCnpkXvAxoKnI-fEz7uShU7U3WKq7dH9piNVXPANjpauNq=s900-c-k-c0x00ffffff-no-rj"
        },
      }
    };

    const projectID = 'saaolhrmapp-cf6b9';
    final get = get_server_key();
    String token22222 = await get.server_token();
    log('bearerToken: $token22222');
    if (token22222 == null) return;

    var res = await http.post(
      Uri.parse(
          'https://fcm.googleapis.com/v1/projects/$projectID/messages:send'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token22222'
      },
      body: jsonEncode(body),
    );

    log('Response status: ${res.statusCode}');
    log('Response body: ${res.body}');
  } catch (e) {
    log('\nsendPushNotificationE: $e');
  }
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        final payloadParts = response.payload?.split('|');
        print("SKNDNNSDNDKN$payloadParts");
        if (payloadParts != null && payloadParts.length == 3) {
          final notification = NotificationData(
            title: payloadParts[0],
            body: payloadParts[1],
            imageUrl: payloadParts[2],
          );
          await NotificationDatabase.instance.insertNotification(notification);
        }
      }
    },
  );
}

Future<void> showNotification({
  String? title,
  String? body,
  String? imageUrl,
}) async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'channel_id',
    'Channel Name',
    channelDescription: 'This is a test channel',
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  final payload =
      '${title ?? 'No Title'}|${body ?? 'No Body'}|${imageUrl ?? ''}';

  await flutterLocalNotificationsPlugin.show(
    0,
    title ?? 'No Title',
    body ?? 'No Body',
    notificationDetails,
    payload: payload,
  );
}

Future<void> setupFCM(BuildContext context) async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('📲 Foreground message received: ${message.notification?.title}');

    if (message.notification != null) {
      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

      String? imageUrl = message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl ??
          "";

      final notification = NotificationData(
        title: message.notification!.title ?? "",
        body: message.notification!.body ?? "",
        imageUrl: imageUrl,
        //  currentDate: formattedDate,
      );

      await NotificationDatabase.instance.insertNotification(notification);
      await showNotification(
        title: message.notification?.title ?? "",
        body: message.notification?.body ?? "",
        imageUrl: imageUrl,
      );
    }
  });

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  if (Platform.isIOS) {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    String? apnsToken = await messaging.getAPNSToken();
    print('🔑 APNS Token: $apnsToken');
  }
  String? token = await messaging.getToken();
  print('🔑 FCM Token: $token');
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationScreen> {
  late Future<List<NotificationData>> _notifications;

  @override
  void initState() {
    super.initState();

    _notifications = databaseHelper.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeNotifications();
    });
    _notifications = databaseHelper.fetchNotifications();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          'Notification',
          style: TextStyle(
            fontFamily: 'FontPoppins',
            fontSize: 18,
            letterSpacing: 0.2,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: FutureBuilder<List<NotificationData>>(
        future: _notifications,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text(
              'No notifications yet',
              style: TextStyle(
                  fontFamily: 'FontPoppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Colors.black87),
            ));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final notification = snapshot.data![index];
                return Card(
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    side: BorderSide(
                      color: Colors.grey.shade400, // Border color
                      width: 1.0, // Border width
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (notification.imageUrl != null)
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade200,
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: Image.network(
                              notification.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          const Icon(
                            Icons.notifications,
                            size: 50,
                            color: Colors.grey,
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title ?? 'No Title',
                                style: const TextStyle(
                                  fontFamily: 'FontPoppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification.body ?? 'No Body',
                                style: const TextStyle(
                                  fontFamily: 'FontPoppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                softWrap: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
