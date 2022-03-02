import 'dart:convert';

import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/checking_character.dart';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/BackEnd/sqflite/local_database_management.dart';
import 'package:chat_app/FrontEnd/GroupChat/group_add_members.dart';
import 'package:chat_app/FrontEnd/GroupChat/group_chat_room.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:animations/animations.dart';


class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({Key? key, required this.userName, required this.userCharacter}) : super(key: key);
  final String userName;
  final String userCharacter;
  @override
  _GroupChatStateScreen createState() => _GroupChatStateScreen();
}

class _GroupChatStateScreen extends State<GroupChatScreen> {

  CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
  LocalDatabase _localDatabase = LocalDatabase();
  final String _groupName = "GroupName";
  final String _msgCount = "MsgCounts";
  final String _msgTime = "MessageTime";
  final String _msg = "Message";
  final String _groupProfile = "GroupProfile";
  final String email = FirebaseAuth.instance.currentUser!.email.toString();
  bool _isLoading = false;
  List groupList =[];
  List<Map<String,dynamic>> _allGroups = [];
  List<int> msgCount = [];
  List<String> message = [];
  List<String> msgTime = [];
  List<String> groupName=[];
  List<String> groupProfile = [];
  List<ChatMessageTypes> msgType = [];


 Future<void> _getAvailableGroups() async {
   if (mounted) {
     setState(() {
       _isLoading = true;
       _allGroups=[];
       groupList = [];
       msgCount = [];
       message = [];
       msgTime = [];
       groupName = [];
       msgType = [];
       groupProfile = [];
     });
   }
   List groups = await _cloudStoreDataManagement.getGroups(email: email);
   late int tmsg;
   late ChatMessageTypes chatMessageTypes;
   late String msg;
   late String mtime;

   for (int i = 0; i < groups.length; i++) {
     bool insertGroupData = await _localDatabase.insertOrUpdateThisGroupData(
         groupName: groups[i]['groupName'], groupId: groups[i]['groupId']);
     if (insertGroupData) {
       await _localDatabase.createTableForTheGroupMessage(
           groupName: "${groups[i]['groupName']}");
     }
     final Map<String,dynamic>? _groupData = await _cloudStoreDataManagement.getGroupDetails(groupId: groups[i]['groupId']);
     List<dynamic> _groupMessages= [];
       if(_groupData!["Message"]==null) _groupMessages=[];
       _groupMessages = _groupData["Message"];
       tmsg = (_groupData["msgCount"]!=null)?_groupData["msgCount"]:0;
       if( _groupMessages.isNotEmpty){
         int l=_groupMessages.length;
         final Map<String,dynamic> _latestMessage = _groupMessages[l-1];
         if(_latestMessage.keys.first.toString() == ChatMessageTypes.Text.toString()){
           var message = _latestMessage.values.first;
           chatMessageTypes = ChatMessageTypes.Text;
           msg = message["Message"];
           mtime = message["Time"];
           print("Message: ${message.keys.first.toString()}");
           print("Time:${message.values.first.toString()}");
         }
         else if(_latestMessage.keys.first.toString() == ChatMessageTypes.Image.toString()){
           var message = _latestMessage.values.first;
           chatMessageTypes = ChatMessageTypes.Image;
           msg = "Image";
           mtime = message["Time"];
           print("Message: Image");
           print("Time:${message.values.first.toString()}");
         }
         else if(_latestMessage.keys.first.toString() == ChatMessageTypes.Video.toString()){
           var message = _latestMessage.values.first;
           chatMessageTypes = ChatMessageTypes.Video;
           msg = "Video";
           mtime = message["Time"];
           print("Message: Video");
           print("Time:${message.values.first.toString()}");
         }
         else if(_latestMessage.keys.first.toString() == ChatMessageTypes.Document.toString()){
           var message = _latestMessage.values.first;
           chatMessageTypes = ChatMessageTypes.Document;
           msg = "Document";
           mtime = message["Time"];
           print("Message: Document");
           print("Time:${message.values.first.toString()}");
         }
         else if(_latestMessage.keys.first.toString() == ChatMessageTypes.Audio.toString()){
           var message = _latestMessage.values.first;
           chatMessageTypes = ChatMessageTypes.Audio;
           msg = "Audio";
           mtime = message["Time"];
           print("Message: Audio");
           print("Time:${message.values.first.toString()}");
         }
         else if (_latestMessage.keys.first.toString() ==
             ChatMessageTypes.Notify.toString()) {
           var message = _latestMessage.values.first;
           chatMessageTypes = ChatMessageTypes.Notify;
           msg = message["Message"];
           mtime = message["Time"];
         }
       }
       else{
         final Map<String,dynamic>? _fetchOldLatestMessage = await _localDatabase.fetchLatestUserMessage("${groups[i]["groupName"]}");
         print("Local Database Message: $_fetchOldLatestMessage");
         if (_fetchOldLatestMessage != null) {
           if (_fetchOldLatestMessage.keys.first.toString() ==
               ChatMessageTypes.Text.toString()) {
             var message = _fetchOldLatestMessage.values.first;
             chatMessageTypes = ChatMessageTypes.Text;
             msg = message.keys.first.toString();
             mtime =message.values.first.toString();
             print("Message: ${message.keys.first.toString()}");
             print("Time:${message.values.first.toString()}");
           }
           else if (_fetchOldLatestMessage.keys.first.toString() ==
               ChatMessageTypes.Image.toString()) {
             var message = _fetchOldLatestMessage.values.first;
             chatMessageTypes = ChatMessageTypes.Image;
             msg = "Image";
             mtime = message.values.first.toString();
             print("Message: Image");
             print("Time:${message.values.first.toString()}");
           }
           else if (_fetchOldLatestMessage.keys.first.toString() ==
               ChatMessageTypes.Video.toString()) {
             var message = _fetchOldLatestMessage.values.first;
             chatMessageTypes = ChatMessageTypes.Video;
             msg = "Video";
             mtime = message.values.first.toString();
             print("Message: Video");
             print("Time:${message.values.first.toString()}");
           }
           else if (_fetchOldLatestMessage.keys.first.toString() ==
               ChatMessageTypes.Document.toString()) {
             var message = _fetchOldLatestMessage.values.first;
             chatMessageTypes = ChatMessageTypes.Document;
             msg = "Document";
             mtime = message.values.first.toString();
             print("Message: Document");
             print("Time:${message.values.first.toString()}");
           }
           else if (_fetchOldLatestMessage.keys.first.toString() ==
               ChatMessageTypes.Audio.toString()) {
             var message = _fetchOldLatestMessage.values.first;
             chatMessageTypes = ChatMessageTypes.Audio;
             msg = "Audio";
             mtime =message.values.first.toString();
             print("Message: Audio");
             print("Time:${message.values.first.toString()}");
           }
           else if (_fetchOldLatestMessage.keys.first.toString() ==
               ChatMessageTypes.Notify.toString()) {
             var message = _fetchOldLatestMessage.values.first;
             chatMessageTypes = ChatMessageTypes.Notify;
             msg = message.keys.first.toString();
             mtime = message.values.first.toString();
           }
         }
         else{
           chatMessageTypes = ChatMessageTypes.Text;
           msg = groups[i]["groupName"];
           mtime = "";
         }
       }
       if(mounted){
         setState(() {
           _allGroups.add({
             _groupName:groups[i]['groupName'],
             _msgCount:tmsg,
             _msg:msg,
             _msgTime:mtime,
             _groupProfile:_groupData["groupProfile"].toString()
           });
           msgCount.add(tmsg);
           message.add(msg);
           msgTime.add(mtime);
           groupName.add(groups[i]["groupName"]);
           msgType.add(chatMessageTypes);
           print("Group Profile: ${_groupData["groupProfile"]}");
           groupProfile.add(_groupData["groupProfile"].toString());
         });
       }

     }


   if (mounted) {
     setState(() {
       groupList = groups;
       _isLoading = false;
     });
   }
 }


  @override
  void initState() {
    _getAvailableGroups();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final jsonList = _allGroups.map((item) =>jsonEncode(item)).toList();
    final uniqueJsonList = jsonList.toSet().toList();
    final uniqueGroups = uniqueJsonList.map((item) => jsonDecode(item)).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      body:Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0)
                  )
              ),
              child: LoadingOverlay(
                isLoading: _isLoading,
                child:(uniqueGroups.isNotEmpty)? ListView.builder(
                    itemCount: uniqueGroups.length,
                    itemBuilder: (context, index){
                      return MessageChat(
                          context: context,
                          index: index,
                          image: uniqueGroups[index][_groupProfile],
                          name: uniqueGroups[index][_groupName],
                          msg: uniqueGroups[index][_msg],
                          time: uniqueGroups[index][_msgTime],
                          msgCount: uniqueGroups[index][_msgCount],
                      );
                    }
                )
               :const Center(
                  child: Text(
                    "Your Groups Appears Here",
                    style: TextStyle(
                      fontFamily: "MyRaidBold",
                      color: lightBlue,
                      fontSize: 22,
                    ),
                  ),
                )
              ),
            ),
          )
        ],
      ),

      floatingActionButton:(widget.userCharacter != "Student")? FloatingActionButton(
        backgroundColor: const Color.fromRGBO(8,33,198,1),
        tooltip: "Create Group",
        child:const Icon(Icons.create,color: Colors.white,),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddMembersInGroup(userName: widget.userName,)));
        },
      )
      :SizedBox(),
    );
  }

  Widget MessageChat(
      {
        required BuildContext context,
        required int index,
        required String image,
        required String name,
        required String msg,
        required String time,
        required int msgCount,
      }
      ) {
    return OpenContainer(
      //openColor: royalBlue,
      middleColor: const Color.fromRGBO(0, 0, 0, 0.001),
      closedElevation: 0.0,
      transitionDuration: Duration(milliseconds: 500),
      transitionType: ContainerTransitionType.fadeThrough,
      openBuilder: (_,__){
        return GroupChatRoom(userName: widget.userName,groupName: name,groupId: groupList[index]["groupId"],profilePath: image,);
      },
      closedBuilder: (_, __) {
        return Padding(
          key: Key('$index'),
          padding: const EdgeInsets.only(top: 1.0, bottom: 1.0),
          child: Container(
              width: double.infinity,
              height: 80,
              color: bodyColor,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 25),
                        child: Container(
                          width: 5,
                          height: constraints.maxHeight,
                          color: msgCount != 0 ? royalBlue : Colors.transparent,
                        ),
                      ),
                      Container(
                        decoration:const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey,width: .5))
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top:15,bottom:15,right: 15),
                          child: SizedBox(
                              width: constraints.maxHeight / 1.5,
                              height: constraints.maxHeight,
                              child: Stack(
                                children: [
                                  Container(
                                      width: constraints.maxWidth,
                                      height: constraints.maxHeight,
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: FittedBox(fit:BoxFit.cover,child: Image.network(image))),
                                ],
                              )),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Container(
                          decoration:const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Colors.grey,width: .5))
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                                height: constraints.maxHeight,
                                color: bodyColor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, left: 8, right: 8, bottom: 5),
                                      child: Text(
                                        name,
                                        style:const TextStyle(
                                            fontFamily: 'MyRaidBold',
                                            overflow: TextOverflow.ellipsis,
                                            fontSize: 16,
                                            color: fadedPurple),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 8, bottom: 8),
                                      child: Row(
                                        children: [
                                          Text(
                                            msg,
                                            overflow: TextOverflow.ellipsis,
                                            style:const TextStyle(
                                                fontFamily: 'MyRaidBold',
                                                fontSize: 14,
                                                color: royalPurple),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10,right: 15),
                          child: Container(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Colors.grey,width: .5)),
                                color: bodyColor,
                              ),
                              height: constraints.maxHeight,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 5),
                                    child: Text(
                                      time,
                                      style: const TextStyle(
                                          fontFamily: 'MyRaid',
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 16,
                                          color: fadedPurple),
                                    ),
                                  ),
                                  if(msgCount != 0) Container(
                                    width: 25,
                                    height: 25,
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        msgCount < 100 ? msgCount.toString() : '99+',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'MyRaidBold',
                                            color: Colors.white),
                                      ),
                                    ),
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(200)),
                                      color: lightBlue,
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    ],
                  );
                },
              )),
        );
      },
    );
  }
}