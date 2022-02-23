import 'dart:async';

import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/checking_character.dart';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:chat_app/FrontEnd/NewUserDetails/new_user_setup.dart';
import 'package:chat_app/FrontEnd/screens/home_screen.dart';
import 'package:chat_app/FrontEnd/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/svg.dart';



class SplashScreen extends StatelessWidget {
  Tween<double> _scaleTween = Tween<double>(begin: 0.5, end: 1);

  SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds:3),()async => differentContextDecisionTake(context));

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        toolbarHeight: 0,
        backgroundColor: royalBlue,
        elevation: 0,
      ),
      body: Container(
        color: royalBlue,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Center(
              child: TweenAnimationBuilder(
                tween: _scaleTween,
                duration: Duration(seconds: 1),
                curve: Curves.bounceOut,
                builder: (context, double scale, child) {
                  if (scale == 1) {}
                  return Transform.rotate(
                    angle: -5 * (scale - 1) / 10,
                    child: Transform.scale(scale: scale, child: child),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    color: royalBlue,
                  ),
                  child: const Image(
                    image: AssetImage('assets/images/logo_white.png'),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.transparent,
                height: 40,
                width: MediaQuery.of(context).size.width,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'developed by  ',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'MyRaid',
                            fontSize: 12),
                      ),
                      SizedBox(
                          height: 20,
                          child: Image(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/images/logo_idot.png'),
                          ))
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }
  Future<void> differentContextDecisionTake(BuildContext context) async{
    if(FirebaseAuth.instance.currentUser == null){
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) =>Welcome()),(route) => false);
    }
    else{
      var _character ="";
      final email = FirebaseAuth.instance.currentUser!.email.toString();
      final CloudStoreDataManagement _cloudestoredata = CloudStoreDataManagement();
      final CloudStoreCharacter _cloudstorecharacter = CloudStoreCharacter();
      final bool userPresentOrNot = await _cloudestoredata.userRecordPresentOrNot(email:email );
      final String userCharacter = await _cloudstorecharacter.userCharacter(email: email);
      final String profile = await _cloudstorecharacter.userProfile(email: email);
      final String userName = await _cloudstorecharacter.userName(email: email);
      if(userPresentOrNot){
        _character = userCharacter;
      }
      if(userPresentOrNot){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) =>HomeScreen(character: _character, email: email,userName: userName,profilepath: profile,)), (route) => false);
      }
      else{
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>SetUp()),(route) => false);
      }
    }
  }
}



