import 'package:chat_app/BackEnd/Firebase/Authentication/signup_auth.dart';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/FrontEnd/GroupChat/group_chat_screen.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/MessageTabBar.dart';
import 'package:chat_app/FrontEnd/screens/Principal/message_screen.dart';
import 'package:chat_app/FrontEnd/screens/Principal/principal_screen.dart';
import 'package:chat_app/FrontEnd/screens/messageDrawer.dart';
import 'package:chat_app/FrontEnd/screens/welcome_screen.dart';
import 'package:chat_app/Global_Uses/show_toast_messages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/FrontEnd/widgets/recent_chats.dart';
import 'package:animations/animations.dart';
import 'MenuScreens/about_screen.dart';
import 'MenuScreens/profile_screen.dart';
import 'MenuScreens/setting_screen.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';

class HomeScreen extends StatefulWidget {
  final String character;
  final String email;
  final String userName;
  final String profilepath;
  HomeScreen({required this.character, required this.email, required this.userName, required this.profilepath});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
final EmailAndPasswordAuth _emailAndPasswordAuth = EmailAndPasswordAuth();

class _HomeScreenState extends State<HomeScreen>with SingleTickerProviderStateMixin , WidgetsBindingObserver {
  late TabController controller;
  late List<String> tabs;
  late String email;
  int tMsgCount = 0;
  bool _isLoading = false;
  final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
  final FToast _fToast = FToast();

  void _getTotalChats({required String userMail}) async {
    int msgCount = 0;
    if (mounted) {
      setState(() {
        _isLoading = true;
        tMsgCount = 0;
      });
    }
    Map<String, dynamic>? _getDetails = await _cloudStoreDataManagement
        .getCurrentAccountAllData(email: userMail);
    if (_getDetails != null) {
      List<dynamic> chats = _getDetails["connectionName"];
      chats.forEach((msg) {
        if (msg.values.first != 0) {
          msgCount += 1;
        }
      });
      if (mounted) {
        setState(() {
          tMsgCount = msgCount;
        });
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _fToast.init(context);
    _getTotalChats(userMail: widget.email);
    super.initState();
    print("status checking");
    WidgetsBinding.instance?.addObserver(this);
    setStatus(staus: "Online");
    controller = TabController(
        length:  3, vsync: this);
    controller.addListener(() {
      setState(() {});
    });
  }

  void setStatus({required String staus}) async {
    await _cloudStoreDataManagement.setStatus(staus: staus);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("Status Updating");
    if (state == AppLifecycleState.resumed) {
      await _cloudStoreDataManagement.setStatus(staus: "Online");
    }
    else {
      await _cloudStoreDataManagement.setStatus(staus: "Offline");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    print(widget.character);
    if (widget.character == "Principal") {
      tabs = ['Chats','Global Message', 'Groups'];
    }
    else {
      tabs = ['Chats', 'Groups', 'Principal'];
    }
    print(tabs);
    return Scaffold(
        key: _scaffoldKey,
        endDrawerEnableOpenDragGesture: false,
        drawer: MessageDrawer(
          profilePic: Image(
            image: NetworkImage(widget.profilepath),
          ),
          name: widget.userName,
          email: widget.email,
          profile: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ProfileScreen()));
          },
          logOut: () async {
            await _cloudStoreDataManagement.setStatus(staus: "Offline");
            final bool _logout = await _emailAndPasswordAuth.logout();
            if (_logout) {
              showToast("successfully logged out", _fToast,toastColor: Colors.white,bgColor: Colors.black);
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>Welcome()), (route) => false);
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("There Is Some error in Logout")));
            }
          },
        ),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          shadowColor: Colors.grey,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(50)),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 20,
                      color: Colors.grey
                  )
                ]
            ),
          ),
          leading: Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState!.openDrawer();
              },
              child: Icon(
                Icons.menu,
                color: Colors.black,
              ),
            ),
          ),
          centerTitle: true,
          bottom: MessageTabBar(controller: controller, Tabs: tabs),
          toolbarHeight: 100,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      'KEC',
                      style: TextStyle(
                          fontFamily: 'MyraidBold',
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text(
                      'Info',
                      style: TextStyle(
                          fontFamily: 'MyRaid',
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if(tMsgCount != 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Container(
                        width: 35,
                        height: 35,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            tMsgCount < 100 ? tMsgCount.toString() : '99+',
                            style:
                            TextStyle(fontSize: 16,
                                fontFamily: 'MyRaidBold',
                                color: Colors.white),
                          ),
                        ),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Color.fromRGBO(0, 180, 255, 1),
                        ),
                      ),
                    ),

                ],
              )
            ],
          ),
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: (widget.character != "Principal") ?
          TabBarView(
              controller: controller,
              children: [
                RecentChats(userCharacter: widget.character,
                  email: widget.email,
                  userName: widget.userName,
                  profile:widget.profilepath,
                ),
                GroupChatScreen(
                    userName: widget.userName, userCharacter: widget.character),
                PrincipalScreen()
              ]
          )
              :
          TabBarView(
              controller: controller,
              children: [
                RecentChats(userCharacter: widget.character,
                  email: widget.email,
                  userName: widget.userName,
                  profile: widget.profilepath,
                ),
                PrincipalMessageScreen(),
                GroupChatScreen(
                    userName: widget.userName, userCharacter: widget.character),
              ]
          ),
        )
    );
  }
}