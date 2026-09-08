import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../../app/app.dart';
import '../../app/app_functions.dart';
import '../../app/app_prefs.dart';
import '../../app/imports.dart';

GlobalMethods globalMethods = GlobalMethods();

class GlobalMethods {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void registerNotification(context) {
    firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      configureLocalNotifications(message, context);

      showLocalNotification(
          message.notification ?? const RemoteNotification(), message.data);
    });

    firebaseMessaging.getToken().then((token) {
      if (token != null) {
        debugPrint('token ================================> $token');
      }
    }).catchError((error) {
      // AppFunctions.showsToast(error.toString(), ColorManager.red, context);
    });
  }

  void configureLocalNotifications(
      RemoteMessage message, BuildContext context) {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings iOSInitializationSettings =
        const DarwinInitializationSettings();

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iOSInitializationSettings,
    );

    flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        debugPrint('message ==================> ${message.data.toString()}');
        final data = message.data;

        log("NAVIGATION EXECUTED: $data");

        final Map<String, dynamic> data2 =
            Map<String, dynamic>.from(jsonDecode(details.payload!));

        log("NAVIGATION DATA => $data");
        log("NAVIGATION DATA2 => $data2");
        log("==========type => ${data2['type']}");
      }
    );
  }

  void showLocalNotification(
      RemoteNotification remoteNotification, Map<String, dynamic> data) async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
      "com.services.fixman",
      "fixman",
      playSound: true,
      enableVibration: true,
      importance: Importance.max,
      priority: Priority.high,
    );

    DarwinNotificationDetails iOSNotificationDetails =
        const DarwinNotificationDetails();

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id: remoteNotification.hashCode,
      title: remoteNotification.title,
      body: remoteNotification.body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(data),
    );
  }
}
