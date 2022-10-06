import 'package:chat_app/FrontEnd/widgets/recent_chat_provider.dart';
import 'package:chat_app/Global_Uses/foreground_receive_notification_management.dart';
import 'package:chat_app/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';


Future init() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// Initialize Notification Settings
  await notificationInitialize();

  /// For Background Message Handling
  FirebaseMessaging.onBackgroundMessage(backgroundMessageAction);

  /// For Foreground Message Handling
  FirebaseMessaging.onMessage.listen((messageEvent) {
    print("Message Data is: ${messageEvent.notification!.title}     ${messageEvent.notification!.body}");

    _receiveAndShowNotificationInitialization(
        title: messageEvent.notification!.title.toString(),
        body: messageEvent.notification!.body.toString());
  });

}

void main() async {

  await init();
  runApp(
    ChangeNotifierProvider(
        create: (context) => RecentChatModel(),
      child:MaterialApp(
          debugShowCheckedModeBanner: false,
          home: SplashScreen()
      ),
    ) ,
    );
}

Future<void> notificationInitialize() async{
  await FirebaseMessaging.instance.subscribeToTopic("KEC_INFO");
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}
void _receiveAndShowNotificationInitialization({required String title, required String body})async{
      final ForegroundNotificationManagement _fgNotifyManagement = ForegroundNotificationManagement();

      print("Notification Activated");

      await _fgNotifyManagement.showNotification(title: title, body: body);
}

Future<void> backgroundMessageAction(RemoteMessage message) async{
  await Firebase.initializeApp();

  _receiveAndShowNotificationInitialization(title: message.notification!.title.toString(), body: message.notification!.body.toString());
}
