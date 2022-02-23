import 'package:chat_app/FrontEnd/Authentication/login.dart';
import 'package:chat_app/FrontEnd/Authentication/signup.dart';
import 'package:flutter/material.dart';

class Welcome extends StatelessWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Image(
                    image: AssetImage('assets/images/kongu_blackandwhite.png'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Welcome',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'MyRaid',
                        color: Colors.black),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: LayoutBuilder(
              builder: (context, constraits) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => Login()), (route) => false);
                      },
                      child: Container(
                        width: constraits.maxWidth,
                        height: constraits.maxHeight,
                        decoration:const BoxDecoration(
                            color: Color.fromRGBO(0,180,255,1),
                            borderRadius: BorderRadius.only(topLeft:Radius.circular(70.0))
                        ),
                        child: Column(
                            children:const [
                              Padding(
                                padding: EdgeInsets.only(top:20.0),
                                child: Text(
                                  'LOGIN',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'MyRaidBold',
                                      color: Colors.white),
                                ),
                              )]),
                      ),
                    ),
                    Positioned(
                      top: constraits.maxHeight / 2,
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => Signup()), (route) => false);
                        },
                        child: Container(
                          width: constraits.maxWidth,
                          height: constraits.maxHeight / 2,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(8,33,198,1),
                            borderRadius: BorderRadius.only(topLeft:Radius.circular(70.0)),
                          ),
                          child:const Center(
                            child:Text(
                              'SIGNUP',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'MyRaidBold',
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
