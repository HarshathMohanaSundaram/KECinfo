import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ForegroundNotificationManagement{
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings= AndroidInitializationSettings("app_icon");

  ForegroundNotificationManagement(){
    final InitializationSettings _initializationSettings = InitializationSettings(android: _androidInitializationSettings);

    print("Foreground Notification Generator");
    initAll(_initializationSettings);
  }

  initAll(InitializationSettings initializationSettings)async{
    final response = await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onSelectNotification: (payload) async{
          print("On Select Notification Payload: $payload");
      });

    print("Local Notification Initialization Status: $response");
  }

  Future<void> showNotification({required String title, required String body}) async{
    try{
        final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
            "CHANNEL ID", "Kongu Engineering College Official App",
          channelDescription: "This app is used for communication in KEC",
          importance: Importance.high,
          playSound: true
        );

        final NotificationDetails generalNotificationDetails = NotificationDetails(android: androidDetails);

        await _flutterLocalNotificationsPlugin.show(0, title, body, generalNotificationDetails,payload: title);
    }
    catch(e){
      print("Foreground Notification Error :${e.toString()}");
    }
  }

}