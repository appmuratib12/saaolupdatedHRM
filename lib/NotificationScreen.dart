import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'constant/app_colors.dart';
import 'constant/database/NotificationDatabase.dart';
import 'data/requestdata/NotificationData.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
  if (message.notification != null) {
    final notification = NotificationData(
      title: message.notification?.title,
      body: message.notification?.body,
      imageUrl: message.notification?.android?.imageUrl,
    );
    await NotificationDatabase.instance.insertNotification(notification);
  }
}

Future<void> initializeNotifications(BuildContext context) async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // App icon

  const InitializationSettings initializationSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        // Decode payload to extract notification data
        final payloadParts = response.payload?.split('|');
        if (payloadParts != null && payloadParts.length == 3) {
          final notification = NotificationData(
            title: payloadParts[0],
            body: payloadParts[1],
            imageUrl: payloadParts[2],
          );
          await NotificationDatabase.instance.insertNotification(notification);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const NotificationScreen(),
            ),
          );
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
    'channel_id', // Unique channel ID
    'Channel Name', // Channel name for Android settings
    channelDescription: 'This is a test channel', // Optional description
    importance: Importance.max,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  final payload =
      '${title ?? 'No Title'}|${body ?? 'No Body'}|${imageUrl ?? ''}';

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title ?? 'No Title', // Notification title
    body ?? 'No Body', // Notification body
    notificationDetails,
    payload: payload, // Additional data
  );
}

Future<void> setupFCM(BuildContext context) async {
  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Foreground message received: ${message.notification?.title}');
    if (message.notification != null) {
      final notification = NotificationData(
        title: message.notification?.title,
        body: message.notification?.body,
        imageUrl: message.notification?.android?.imageUrl,
      );
      await NotificationDatabase.instance.insertNotification(notification);
      showNotification(
        title: message.notification?.title,
        body: message.notification?.body,
        imageUrl: message.notification?.android?.imageUrl,
      );
    }
  });
  String? token = await FirebaseMessaging.instance.getToken();
  print('FCM Token: $token');
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
    _notifications = NotificationDatabase.instance.fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    // Ensure setup is only called once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupFCM(context);
      initializeNotifications(context);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Notification",
          style: TextStyle(
            fontFamily: 'FontPoppins',
            fontSize: 18,
            letterSpacing: 0.2,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
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
                  fontSize: 17,
                  color: AppColors.primaryColor),
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
                      // Adds a border
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
                                  fontSize: 16,
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
                                  fontSize: 13,
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
