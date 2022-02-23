import 'dart:ui';

import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MessageDrawer extends StatelessWidget {
  final Image profilePic;
  final String name, email;
  final Function profile, logOut;
  const MessageDrawer(
      {required this.profilePic,
        required this.name,
        required this.email,
        required this.profile,
        required this.logOut,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Drawer(
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(100),
                        bottomRight: Radius.circular(100))),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 50, right: 50, bottom: 50, left: 30),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: FittedBox(
                                      fit: BoxFit.cover,
                                      child: Center(
                                          child: profilePic
                                      )
                                  ),
                                ),
                                GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.black54,
                                    ))
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child: FittedBox(
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                          color: royalBlue,
                                          fontFamily: 'MyRaidBold',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 20),
                                    ),
                                  )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Align(
                                  alignment: Alignment.topLeft,
                                  child:FittedBox(
                                    child: Text(
                                      email,
                                      style: const TextStyle(
                                          color: Colors.black54,
                                          fontFamily: 'MyRaid',
                                          fontWeight: FontWeight.w100,
                                          fontSize: 14),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: ListView(
                          children: [
                            CustomButton(
                                callBack: profile,icon: MdiIcons.accountOutline, name: 'Profile'),

                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.transparent,
                          child: CustomButton(
                            callBack: logOut,
                            icon: MdiIcons.logout,
                            name: 'Log Out',
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ))),
    );
  }
}

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  String name;
  IconData icon;
  Function callBack;
  CustomButton({required this.icon,required this.callBack, required this.name, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => callBack(),
      child: Center(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(
                icon,
                color: royalBlue,
                size: 22,
              ),
            ),
            Text(
              name,
              style: const TextStyle(
                  fontFamily: 'MyRaid', color: Colors.black, fontSize: 20),
            )
          ],
        ),
      ),
    );
  }
}