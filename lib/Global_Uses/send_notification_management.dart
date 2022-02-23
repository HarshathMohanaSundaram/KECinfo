import 'dart:convert';

import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:http/http.dart';

class SendNotification{
  Future<void> messageNotificationClassifier(
      ChatMessageTypes messageTypes,
      { String txt="",
        String groupName="",
        int groupMessage=0,
        required String userToken,
        required String currUserName,
      }
        ) async{
        switch(messageTypes){
          case ChatMessageTypes.Text:
            await sendNotification(
                userToken: userToken,
                title:(groupMessage == 0)? currUserName:groupName,
                body: (groupMessage == 0)?"Send You a Message":'$currUserName Send You a Message'
            );
            break;
          case ChatMessageTypes.Image:
            await sendNotification(
              userToken: userToken,
              title: (groupMessage == 0)? currUserName:groupName,
              body: (groupMessage == 0)?"Send You a Image":'$currUserName Send You a Image'
            );
            break;
          case ChatMessageTypes.Video:
            await sendNotification(
                userToken: userToken,
                title: (groupMessage == 0)? currUserName:groupName,
                body: (groupMessage == 0)?"Send You a Video":'$currUserName Send You a Video'
            );
            break;
          case ChatMessageTypes.Document:
            await sendNotification(
                userToken: userToken,
                title: (groupMessage == 0)? currUserName:groupName,
                body: (groupMessage == 0)?"Send You a Document":'$currUserName Send You a Document'
            );
            break;
          case ChatMessageTypes.Audio:
            await sendNotification(
                userToken: userToken,
                title: (groupMessage == 0)? currUserName:groupName,
                body: (groupMessage == 0)?"Send You a Audio":'$currUserName Send You a Audio'
            );
            break;
        }
  }

  Future<int> sendNotification({required String userToken, required String title, required String body})async{
    try{
      final String _serverKey = "AAAAj-8SLWo:APA91bHdoMCQIYNVregffUgfb2odhiABQ9gtZxwHsEXVTigcK-BbZLt4QJbb6VOQnz499eAwcLn8D7WVJLEgpaqN7y8xobd4t0G8gSVqAf1bhQ7GrqZVe1JPar7ST-mLwRQ9kETj5B42";

      final Response response = await post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String,String>{
          "Content-Type":"application/json",
          "Authorization":"key=$_serverKey",
        },
        body: jsonEncode(<String,dynamic>{
          "notification":<String,dynamic>{
            "body":body,
            "title":title,
          },
          "priority": "high",
          "data":<String,dynamic>{
            "click": "FLUTTER_NOTIFICATION_CLICK",
            "id":"1",
            "status":"done",
            "collapse_key":"type_a",
          },
          "to":userToken,
        }),
      );

      print("Response is ${response.statusCode}    ${response.body}");

      return response.statusCode;

    }
    catch(e){
      print("Error in Notification Send: ${e.toString()}");
      return 404;
    }
  }

}