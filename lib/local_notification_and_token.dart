// import 'package:micro_teaching_studio/common/app/functions.dart';
// import 'package:micro_teaching_studio/common/resources/color_manager.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// GlobalMethods globalMethods = GlobalMethods();

// class GlobalMethods {
//   final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   void registerNotification(context) {

//     firebaseMessaging.requestPermission();

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//         configureLocalNotifications(message, context);
//         showLocalNotification(message.notification ?? const RemoteNotification());
//     });

//     firebaseMessaging.getToken().then((token) {
//       if (token != null) {
//         debugPrint('token ================================> $token');
//       }
//     }).catchError((error) {
//       AppFunctions.showsToast(error.toString(), ColorManager.red, context);
//     });
//   }

//   void configureLocalNotifications(RemoteMessage message, context) {
//     AndroidInitializationSettings androidInitializationSettings = const AndroidInitializationSettings('@mipmap/ic_launcher');

//     DarwinInitializationSettings iOSInitializationSettings = const DarwinInitializationSettings();

//     InitializationSettings initializationSettings = InitializationSettings(
//       android: androidInitializationSettings,
//       iOS: iOSInitializationSettings,
//     );

//     flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {
//         debugPrint('message ==================> ${message.data.toString()}');
//       },
//     );
//   }

//    void showLocalNotification(RemoteNotification remoteNotification) async {
//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();

//     AndroidNotificationDetails androidNotificationDetails =
//         const AndroidNotificationDetails(
//       "com.services.fixman",
//       "fixman",
//       playSound: true,
//       enableVibration: true,
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     DarwinNotificationDetails iOSNotificationDetails =
//         const DarwinNotificationDetails();

//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidNotificationDetails,
//       iOS: iOSNotificationDetails,
//     );

//     await flutterLocalNotificationsPlugin.show(
//       remoteNotification.hashCode,
//       remoteNotification.title,
//       remoteNotification.body,
//       notificationDetails,
//       payload: null,
//     );
//   }
// }
