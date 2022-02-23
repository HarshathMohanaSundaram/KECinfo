import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';

class SettingsWindow extends StatefulWidget {
  @override
  _SettingsWindowState createState() => _SettingsWindowState();
}

class _SettingsWindowState extends State<SettingsWindow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      appBar: AppBar(

        backgroundColor: Colors.red,
        elevation: 0.0,
        shadowColor: Colors.white70,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontFamily: 'Lobster',
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(
            height: 40.0,
          ),
          everySettingsItem(
              mainText: 'Notification',
              icon: Icons.notification_important_outlined,
              smallDescription: 'Different Notification Customization'),
          SizedBox(
            height: 15.0,
          ),
          everySettingsItem(
              mainText: 'Chat Wallpaper',
              icon: Icons.wallpaper_outlined,
              smallDescription: 'Change Chat Common Wallpaper'),
          SizedBox(
            height: 15.0,
          ),
          everySettingsItem(
              mainText: 'Chat History',
              icon: Entypo.text_document_inverted,
              smallDescription: 'Chat History Including Media'),
          SizedBox(
            height: 15.0,
          ),
          everySettingsItem(
              mainText: 'Storage',
              icon: Icons.storage,
              smallDescription: 'Storage Usage'),
          SizedBox(
            height: 30.0,
          ),
          Center(
            child: Text(
              'Copyright © 2021 @ KECusers',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget everySettingsItem(
      {required String mainText,
        required IconData icon,
        required String smallDescription}) {
    return OpenContainer(
      closedElevation: 0.0,
      openColor: Colors.red,
      middleColor: Colors.red,
      closedColor: Colors.red,
      transitionType: ContainerTransitionType.fadeThrough,
      transitionDuration: Duration(milliseconds: 500),
      openBuilder: (_, __) {
        switch (mainText) {
        // case 'Notification':
        //   return SettingsNotificationConfiguration();
        //
        // case 'Chat Wallpaper':
        //   return ChatWallPaperMaker(allUpdatePermission: true, userName: '');
        //
        // case 'Generation Direct Calling Setting':
        //   return PhoneNumberConfig();
        //
        // case 'Chat History':
        //   return ChatHistoryMakerAndMediaViewer(
        //       historyOrMediaChoice: HistoryOrMediaChoice.History);
        //
        // case 'Storage':
        //   return ChatHistoryMakerAndMediaViewer(
        //       historyOrMediaChoice: HistoryOrMediaChoice.Media);

        }
        return Center(
          child: Text(
            'Sorry, Not yet Implemented',
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        );
      },
      closedBuilder: (_, __) {
        return Container(
          width: MediaQuery.of(context).size.width,
          height: 70.0,
          margin: EdgeInsets.only(
            left: 20.0,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.lightBlue,
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Text(
                    mainText,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(
                    top: 5.0,
                    left: 40.0,
                  ),
                  child: Text(
                    smallDescription,
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}