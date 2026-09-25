import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseNotificationApi {
  int _messageCount = 0;

  sendNotifyFromFirebase({
    required String title,
    required String body,
    required String sendNotifyTo,
    required String type,
    String? taskID,
    String? uploadedBy,
  }) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAAdFKGxjg:APA91bFFnesWiYpFa7rZC1kpiIaqcAbrcd5dYEGfVtMAy8yJSCK7EiXp-MkAE4015CxWSZ6ZYWqOyLQk1Z5Bkuo-NTG02iflDwoYnvDkYW7rti6EbOcYSEkvezr3WPn5VgtXG4Pu6w6i',
      },
      body: constructFCMPayload(
          body: body,
          title: title,
          sendNotifyTo: sendNotifyTo,
          type: type,
          taskID: taskID,
          uploadedBy: uploadedBy),
    );
  }

  String constructFCMPayload({
    required String title,
    required String body,
    required String sendNotifyTo,
    required String type,
    String? taskID,
    String? uploadedBy,
  }) {
    _messageCount++;
    return jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': body,
          'title': title,
          'android_channel_id': 'business'
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'status': 'done',
          'type': type,
          'task_id': taskID,
          'uploaded_by': uploadedBy,
          'count': _messageCount.toString(),
          'body': body,
          'title': title,
        },
        'to': sendNotifyTo,
      },
    );
  }
}

FirebaseNotificationApi fireApi = FirebaseNotificationApi();
