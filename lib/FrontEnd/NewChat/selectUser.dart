import 'dart:convert';

import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:chat_app/FrontEnd/NewChat/customTabBar.dart';
import 'package:chat_app/FrontEnd/Services/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_overlay/loading_overlay.dart';


class SelectUser extends StatefulWidget {
  List tabs;
  final String userCharacter;
  final String userMail;
  final String selectedDepartment;
  final String selectedCharacter;
  final String selectedDegree;
  final String userProfile;

  SelectUser({required this.tabs,required this.userProfile,required this.userMail,required this.userCharacter,required this.selectedCharacter,required this.selectedDepartment,required this.selectedDegree, Key? key})
      : super(key: key);

  @override
  State<SelectUser> createState() => _SelectUserState();
}

class _SelectUserState extends State<SelectUser> with TickerProviderStateMixin {
  late TabController controller;
  bool _isLoading = false;
  List<Map<String,dynamic>> _userList = [];
  final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();

  Future<void> _fetchDetails(String character) async{
    if(mounted){
      setState(() {
        _userList=[];
        _isLoading = true;
      });
    }
    final Stream<QuerySnapshot<Map<String, dynamic>>>? realTimeSnapshot = await _cloudStoreDataManagement.fetchAllUserDetails(character: widget.selectedCharacter);
    if(widget.selectedCharacter == "Faculty"){
      realTimeSnapshot!.listen((querySnapshot) async{
        querySnapshot.docs.forEach((queryDocumentSnapshot) {
          if(queryDocumentSnapshot.id != widget.userMail){
            final String depart = queryDocumentSnapshot.get("userDepartment");
            print("Department: $depart");
            if(widget.selectedDepartment.contains("B.Sc")){
              if(depart.contains("B.Sc")){
                final String profile = queryDocumentSnapshot.get("profile_pic");
                final String desgination = queryDocumentSnapshot.get("Desigination");
                final String userName = queryDocumentSnapshot.get("userName");
                final String userMail = queryDocumentSnapshot.get("userEmail");
                _userList.add({
                  "Profile":profile,
                  "Designation":desgination,
                  "UserName":userName,
                  "UserMail":userMail
                });
              }
            }
            else{
              if(depart == widget.selectedDepartment){
                  final String profile = queryDocumentSnapshot.get("profile_pic");
                  final String desgination = queryDocumentSnapshot.get("Desigination");
                  final String userName = queryDocumentSnapshot.get("userName");
                  final String userMail = queryDocumentSnapshot.get("userEmail");
                  _userList.add({
                    "Profile":profile,
                    "Designation":desgination,
                    "UserName":userName,
                    "UserMail":userMail
                  });
              }
            }
          }
        });
      });
    }
    else if(widget.selectedCharacter == "Student")
    {
      realTimeSnapshot!.listen((querySnapshot) async{
        querySnapshot.docs.forEach((queryDocumentSnapshot) {
          if(queryDocumentSnapshot.id != widget.userMail){
            final String depart = queryDocumentSnapshot.get("userDepartment");
            final String degree = queryDocumentSnapshot.get("userDegree");
            if(depart == widget.selectedDepartment){
              if(degree == widget.selectedDegree){
                final String profile = queryDocumentSnapshot.get("profile_pic");
                final String name = queryDocumentSnapshot.get("userName");
                final String mail = queryDocumentSnapshot.get("userEmail");
                final String year = queryDocumentSnapshot.get("userYear");
                if(mounted){
                  setState(() {
                    _userList.add({
                      "Profile":profile,
                      "UserName":name,
                      "UserMail":mail,
                      "Year":year
                    });
                  });
                }
              }
            }
          }
        });
      });
      print("User List: $_userList");
    }
    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  void initState() {
    _fetchDetails(widget.selectedCharacter);
    super.initState();

    controller = TabController(length: widget.tabs.length, vsync: this);
    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.tabs;
    print("UserList: $_userList");
    final jsonList = _userList.map((item) =>jsonEncode(item)).toList();
    final uniqueJsonList = jsonList.toSet().toList();
    final uniqueList = uniqueJsonList.map((item) => jsonDecode(item)).toList();
    return Scaffold(
      appBar: SelectUserAppBar(controller: controller, tabs: tabs),
      backgroundColor: bodyColor,
      body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: LoadingOverlay(
            isLoading: _isLoading,
            child:(widget.selectedCharacter == "Faculty")?TabBarView(
              controller: controller,
              children:[
                ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (context, index){
                      return (uniqueList[index]["Designation"] == "HOD")
                          ?User(
                          name:uniqueList[index]["UserName"],
                          color: index % 2 == 0 ? lightBlue: royalBlue,
                          department: widget.selectedDepartment,
                          image: uniqueList[index]["Profile"],
                        oppositeMail: uniqueList[index]["UserMail"],
                        currentMail: widget.userMail,
                        currentProfile: widget.userProfile,
                          )
                          :SizedBox.shrink();
                    }
                ),
                ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (context, index){
                      return (uniqueList[index]["Designation"] == "Professor")
                          ?User(
                        name:uniqueList[index]["UserName"],
                        color: index % 2 == 0 ? lightBlue: royalBlue,
                        department: widget.selectedDepartment,
                        image: uniqueList[index]["Profile"],
                        oppositeMail: uniqueList[index]["UserMail"],
                        currentMail: widget.userMail,
                        currentProfile: widget.userProfile,
                      )
                      :SizedBox.shrink();
                    }
                ),
                ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (context, index){
                      return (uniqueList[index]["Designation"] == "Assisstant Professor")
                          ?User(
                        name:uniqueList[index]["UserName"],
                        color: index % 2 == 0 ? lightBlue: royalBlue,
                        department: widget.selectedDepartment,
                        image: uniqueList[index]["Profile"],
                        oppositeMail: uniqueList[index]["UserMail"],
                        currentMail: widget.userMail,
                        currentProfile: widget.userProfile,
                      )
                      :SizedBox.shrink();
                    }
                ),
                ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (context, index){
                      return (uniqueList[index]["Designation"] == "Associate Professor")
                          ?User(
                        name:uniqueList[index]["UserName"],
                        color: index % 2 == 0 ? lightBlue: royalBlue,
                        department: widget.selectedDepartment,
                        image: uniqueList[index]["Profile"],
                        oppositeMail: uniqueList[index]["UserMail"],
                        currentMail: widget.userMail,
                        currentProfile: widget.userProfile,
                      )
                      :SizedBox.shrink();
                    }
                ),
              ],
            )
            //PG Degree Except M.Sc
            :(widget.tabs.length == 2)? TabBarView(
              controller: controller,
              children: [
                ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (context,index){
                      return (uniqueList[index]["Year"] == "I")
                          ?User(
                          name: uniqueList[index]["UserName"],
                          color:  index % 2 == 0 ? lightBlue: royalBlue,
                          department: widget.selectedDepartment,
                          image: uniqueList[index]["Profile"],
                        oppositeMail: uniqueList[index]["UserMail"],
                        currentMail: widget.userMail,
                        currentProfile: widget.userProfile,
                      )
                      :SizedBox.shrink();
                    }
                ),
                ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (context,index){
                      return (uniqueList[index]["Year"] == "II")
                          ?User(
                          name: uniqueList[index]["UserName"],
                          color:  index % 2 == 0 ? lightBlue: royalBlue,
                          department: widget.selectedDepartment,
                          image: uniqueList[index]["Profile"],
                        oppositeMail: uniqueList[index]["UserMail"],
                        currentMail: widget.userMail,
                        currentProfile: widget.userProfile,
                      )
                      :SizedBox.shrink();
                    }
                )
              ],
            )
            //B.Sc Degree
            :(widget.tabs.length == 3)?TabBarView(
               controller: controller,
               children: [
                 ListView.builder(
                     itemCount: uniqueList.length,
                     itemBuilder: (context,index){
                       return (uniqueList[index]["Year"] == "I")
                           ?User(
                           name: uniqueList[index]["UserName"],
                           color:  index % 2 == 0 ? lightBlue: royalBlue,
                           department: widget.selectedDepartment,
                           image: uniqueList[index]["Profile"],
                         oppositeMail: uniqueList[index]["UserMail"],
                         currentMail: widget.userMail,
                         currentProfile: widget.userProfile,
                       )
                       :SizedBox.shrink();
                     }
                 ),
                 ListView.builder(
                     itemCount: uniqueList.length,
                     itemBuilder: (context,index){
                       return (uniqueList[index]["Year"] == "II")
                           ?User(
                           name: uniqueList[index]["UserName"],
                           color:  index % 2 == 0 ? lightBlue: royalBlue,
                           department: widget.selectedDepartment,
                           image: uniqueList[index]["Profile"],
                         oppositeMail: uniqueList[index]["UserMail"],
                         currentMail: widget.userMail,
                         currentProfile: widget.userProfile,
                       )
                       :SizedBox.shrink();
                     }
                 ),
                 ListView.builder(
                     itemCount: uniqueList.length,
                     itemBuilder: (context,index){
                       return (uniqueList[index]["Year"] == "III")
                           ?User(
                           name: uniqueList[index]["UserName"],
                           color:  index % 2 == 0 ? lightBlue: royalBlue,
                           department: widget.selectedDepartment,
                           image: uniqueList[index]["Profile"],
                         oppositeMail: uniqueList[index]["UserMail"],
                         currentMail: widget.userMail,
                         currentProfile: widget.userProfile,
                       )
                       :SizedBox.shrink();
                     }
                 ),
               ]
            )
            //BE Degree
            :(widget.tabs.length == 4)? TabBarView(
              controller: controller,
              children: [
                ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (context,index){
                      return (uniqueList[index]["Year"] == "I")
                          ?User(
                          name: uniqueList[index]["UserName"],
                          color:  index % 2 == 0 ? lightBlue: royalBlue,
                          department: widget.selectedDepartment,
                          image: uniqueList[index]["Profile"],
                        oppositeMail: uniqueList[index]["UserMail"],
                        currentMail: widget.userMail,
                        currentProfile: widget.userProfile,
                      )
                      :SizedBox.shrink();
                    }
                ),
                ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (context,index){
                      return (uniqueList[index]["Year"] == "II")
                          ?User(
                          name: uniqueList[index]["UserName"],
                          color:  index % 2 == 0 ? lightBlue: royalBlue,
                          department: widget.selectedDepartment,
                          image: uniqueList[index]["Profile"],
                        oppositeMail: uniqueList[index]["UserMail"],
                        currentMail: widget.userMail,
                        currentProfile: widget.userProfile,
                      )
                      :SizedBox.shrink();
                    }
                ),
                ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (context,index){
                      return (uniqueList[index]["Year"] == "III")
                          ?User(
                          name: uniqueList[index]["UserName"],
                          color:  index % 2 == 0 ? lightBlue: royalBlue,
                          department: widget.selectedDepartment,
                          image: uniqueList[index]["Profile"],
                        oppositeMail: uniqueList[index]["UserMail"],
                        currentMail: widget.userMail,
                        currentProfile: widget.userProfile,
                      )
                      :SizedBox.shrink();
                    }
                ),
                ListView.builder(
                    itemCount: uniqueList.length,
                    itemBuilder: (context,index){
                      return (uniqueList[index]["Year"] == "IV")
                          ?User(
                          name: uniqueList[index]["UserName"],
                          color:  index % 2 == 0 ? lightBlue: royalBlue,
                          department: widget.selectedDepartment,
                          image: uniqueList[index]["Profile"],
                        oppositeMail: uniqueList[index]["UserMail"],
                        currentMail: widget.userMail,
                        currentProfile: widget.userProfile,
                      )
                      :SizedBox.shrink();
                    }
                ),
              ],
            )
            //M.Sc Students
            :(widget.tabs.length==5)?TabBarView(
              controller: controller,
                children: [
                  ListView.builder(
                      itemCount: uniqueList.length,
                      itemBuilder: (context,index){
                        return (uniqueList[index]["Year"] == "I")
                            ?User(
                            name: uniqueList[index]["UserName"],
                            color:  index % 2 == 0 ? lightBlue: royalBlue,
                            department: widget.selectedDepartment,
                            image: uniqueList[index]["Profile"],
                          oppositeMail: uniqueList[index]["UserMail"],
                          currentMail: widget.userMail,
                          currentProfile: widget.userProfile,
                        )
                        :SizedBox.shrink();
                      }
                  ),
                  ListView.builder(
                      itemCount: uniqueList.length,
                      itemBuilder: (context,index){
                        return (uniqueList[index]["Year"] == "II")
                            ?User(
                            name: uniqueList[index]["UserName"],
                            color:  index % 2 == 0 ? lightBlue: royalBlue,
                            department: widget.selectedDepartment,
                            image: uniqueList[index]["Profile"],
                          oppositeMail: uniqueList[index]["UserMail"],
                          currentMail: widget.userMail,
                          currentProfile: widget.userProfile,
                        )
                        :SizedBox.shrink();
                      }
                  ),
                  ListView.builder(
                      itemCount: uniqueList.length,
                      itemBuilder: (context,index){
                        return (uniqueList[index]["Year"] == "III")
                            ?User(
                            name: uniqueList[index]["UserName"],
                            color:  index % 2 == 0 ? lightBlue: royalBlue,
                            department: widget.selectedDepartment,
                            image: uniqueList[index]["Profile"],
                            oppositeMail: uniqueList[index]["UserMail"],
                            currentMail: widget.userMail,
                          currentProfile: widget.userProfile,
                        )
                        :SizedBox.shrink();
                      }
                  ),
                  ListView.builder(
                      itemCount: uniqueList.length,
                      itemBuilder: (context,index){
                        return (uniqueList[index]["Year"] == "IV")
                            ?User(
                            name: uniqueList[index]["UserName"],
                            color:  index % 2 == 0 ? lightBlue: royalBlue,
                            department: widget.selectedDepartment,
                            image: uniqueList[index]["Profile"],
                          oppositeMail: uniqueList[index]["UserMail"],
                          currentMail: widget.userMail,
                          currentProfile: widget.userProfile,
                        )
                        :SizedBox.shrink();
                      }
                  ),
                  ListView.builder(
                      itemCount: uniqueList.length,
                      itemBuilder: (context,index){
                        return (uniqueList[index]["Year"] == "V")
                            ?User(
                            name: uniqueList[index]["UserName"],
                            color:  index % 2 == 0 ? lightBlue: royalBlue,
                            department: widget.selectedDepartment,
                            image: uniqueList[index]["Profile"],
                          oppositeMail: uniqueList[index]["UserMail"],
                          currentMail: widget.userMail,
                          currentProfile: widget.userProfile,
                        )
                        :SizedBox.shrink();
                      }
                  ),
                ]
            )
            :SizedBox.shrink()
          )
      ),
    );
  }
}

PreferredSizeWidget SelectUserAppBar({var controller, var tabs}) {
  return AppBar(
    elevation: 0,
    backgroundColor: Colors.white,
    shadowColor: Colors.grey,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(50)),
          boxShadow: [BoxShadow(blurRadius: 20, color: Colors.grey)]),
    ),
    leading: Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Builder(builder: (context) {
        return IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        );
      }),
    ),
    centerTitle: true,
    toolbarHeight: 100,
    bottom: CustomTabBar(controller: controller, tabs: tabs, onTap: (int) {}),
    title: const Padding(
      padding: EdgeInsets.all(4.0),
      child: Text(
        'Select  User',
        style: TextStyle(
          fontFamily: 'MyRaidBold',
          color: royalBlue,
          fontSize: 20,
        ),
      ),
    ),
  );
}

class User extends StatelessWidget {
  final String name;
  final String department;
  final Color color;
  final String image;
  final String oppositeMail;
  final String currentMail;
  final String currentProfile;
  const User(
      {required this.name,
        required this.color,
        required this.currentProfile,
        required this.department,
        required this.image,
        required this.oppositeMail,
        required this.currentMail,
        Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.15,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            color: fadedWhite, borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  color: Colors.transparent,
                  child: FittedBox(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.black,
                              fontFamily: 'MyRaidBold',
                              fontSize: 16),
                        ),
                        Text(
                          department,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontFamily: 'MyRaid',
                              fontSize: 16),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ElevatedButton(
                              onPressed: () async{
                                final bool existing = await _cloudStoreDataManagement.checkConnection(oppositeUserMail: oppositeMail, currentUserMail: currentMail);
                                if(!existing){
                                  final bool connection = await _cloudStoreDataManagement.addNewConnection(currentUserMail: currentMail, oppositeUserMail:oppositeMail);
                                  if(connection){
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(userName: name, userProfile: image,currentProfile: currentProfile,)));
                                  }
                                  else{
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("There is some Error in creating connection please try after some times")));
                                  }
                                }
                                else{
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(userName: name, userProfile: image,currentProfile: currentProfile,)));
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                primary: Colors.transparent,
                                elevation: 0,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(5)),
                                width: 100,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: const [
                                    Text(
                                      'Message',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'MyRaidBold',
                                          fontSize: 14),
                                    ),
                                    Icon(
                                      Icons.message,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  ],
                                ),
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.transparent,
                  ),
                  child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          child: Image(
                              fit: BoxFit.cover,
                              image: NetworkImage(image),
                          ),
                        );
                      }
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
