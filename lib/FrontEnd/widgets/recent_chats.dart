import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/BackEnd/sqflite/local_database_management.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:chat_app/FrontEnd/NewChat/selectDepartment.dart';
import 'package:chat_app/FrontEnd/Services/chat_screen.dart';
import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';

 class RecentChats extends StatefulWidget {
   final String userCharacter;
   final String email;
   final String userName;
   const RecentChats({Key? key, required this.userCharacter, required this.email, required this.userName}) : super(key: key);

   @override
   _RecentChatsState createState() => _RecentChatsState();
 }

 class _RecentChatsState extends State<RecentChats> {
   bool _isLoading = false;
   List<String> _allConnectionUserName = [];
   final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
   final LocalDatabase _localDatabase = LocalDatabase();
   List<String> userAbout = [];
   List<int> msgCounts = [];
   List<bool> OnlineStatus=[];
   List<ChatMessageTypes> messageType=[];
   List<String>messageTime=[];
   List<String>Message=[];
   List<String> userProfile =[];

   Future<void> _checkingForNewConnection(
       QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot,
       List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
     if (mounted) {
       setState(() {
         _isLoading = true;
         _allConnectionUserName=[];
         userAbout = [];
         msgCounts=[];
         OnlineStatus=[];
         messageType=[];
         messageTime=[];
         Message=[];
         userProfile=[];
       });
     }

     final List<dynamic> _connectionList = queryDocumentSnapshot.get(
         "connectionName");
     print(_connectionList);
     for(int i=0;i<_connectionList.length;i++) {
       docs.forEach((everyDocument) async {
         if (everyDocument.id == _connectionList[i].keys.first.toString()) {
           final String _connectedUserName = everyDocument.get("userName");
           final String _token = everyDocument.get("userToken");
           final String _about = everyDocument.get("about");
           final String _department = everyDocument.get("userDepartment");
           final String _profilePath = everyDocument.get("profile_pic");
           final int msgCount = _connectionList[i].values.first;
           final bool isOnline = (everyDocument.get("status") == "Online")?true:false;
           final bool _newConnectionNameInserted = await _localDatabase
               .insertOrUpdateThisAccountData(
               userName: _connectedUserName,
               userMail: everyDocument.id,
               userToken: _token,
               userAbout: _about,
               userDepartment: _department);
           if (_newConnectionNameInserted) {
             await _localDatabase.createTableForTheUser(
                 userName: _connectedUserName);
           }
           late ChatMessageTypes chatMessageTypes;
           late String msg;
           late String msgTime;
           final Map<String,dynamic>? _latestMessage = await _cloudStoreDataManagement.getLatestUserMessages(connectionEmail: _connectionList[i].keys.first.toString());
           print("LatestMessage: $_latestMessage");
           if(_latestMessage != null){
             if(_latestMessage.keys.first.toString() == ChatMessageTypes.Text.toString()){
               var message = _latestMessage.values.first;
               chatMessageTypes = ChatMessageTypes.Text;
               msg = message.keys.first.toString();
               msgTime = message.values.first.toString();
               print("Message: ${message.keys.first.toString()}");
               print("Time:${message.values.first.toString()}");
             }
             else if(_latestMessage.keys.first.toString() == ChatMessageTypes.Image.toString()){
               var message = _latestMessage.values.first;
               chatMessageTypes = ChatMessageTypes.Image;
               msg = "Image";
               msgTime = message.values.first.toString();
               print("Message: Image");
               print("Time:${message.values.first.toString()}");
             }
             else if(_latestMessage.keys.first.toString() == ChatMessageTypes.Video.toString()){
               var message = _latestMessage.values.first;
               chatMessageTypes = ChatMessageTypes.Video;
               msg = "Video";
               msgTime = message.values.first.toString();
               print("Message: Video");
               print("Time:${message.values.first.toString()}");
             }
             else if(_latestMessage.keys.first.toString() == ChatMessageTypes.Document.toString()){
               var message = _latestMessage.values.first;
               chatMessageTypes = ChatMessageTypes.Document;
               msg = "Document";
               msgTime = message.values.first.toString();
               print("Message: Document");
               print("Time:${message.values.first.toString()}");
             }
             else if(_latestMessage.keys.first.toString() == ChatMessageTypes.Audio.toString()){
               var message = _latestMessage.values.first;
               chatMessageTypes = ChatMessageTypes.Audio;
               msg = "Audio";
               msgTime = message.values.first.toString();
               print("Message: Audio");
               print("Time:${message.values.first.toString()}");
             }
           }
           else {
             final Map<String,
                 dynamic>? _fetchOldLatestMessage = await _localDatabase
                 .fetchLatestUserMessage(_connectedUserName);
             print("Local Database Message: $_fetchOldLatestMessage");
             if (_fetchOldLatestMessage != null) {
               if (_fetchOldLatestMessage.keys.first.toString() ==
                   ChatMessageTypes.Text.toString()) {
                 var message = _fetchOldLatestMessage.values.first;
                 chatMessageTypes = ChatMessageTypes.Text;
                 msg = message.keys.first.toString();
                 msgTime = message.values.first.toString();
                 print("Message: ${message.keys.first.toString()}");
                 print("Time:${message.values.first.toString()}");
               }
               else if (_fetchOldLatestMessage.keys.first.toString() ==
                   ChatMessageTypes.Image.toString()) {
                 var message = _fetchOldLatestMessage.values.first;
                 chatMessageTypes = ChatMessageTypes.Image;
                 msg = "Image";
                 msgTime = message.values.first.toString();
                 print("Message: Image");
                 print("Time:${message.values.first.toString()}");
               }
               else if (_fetchOldLatestMessage.keys.first.toString() ==
                   ChatMessageTypes.Video.toString()) {
                 var message = _fetchOldLatestMessage.values.first;
                 chatMessageTypes = ChatMessageTypes.Video;
                 msg = "Video";
                 msgTime = message.values.first.toString();
                 print("Message: Video");
                 print("Time:${message.values.first.toString()}");
               }
               else if (_fetchOldLatestMessage.keys.first.toString() ==
                   ChatMessageTypes.Document.toString()) {
                 var message = _fetchOldLatestMessage.values.first;
                 chatMessageTypes = ChatMessageTypes.Document;
                 msg = "Document";
                 msgTime = message.values.first.toString();
                 print("Message: Document");
                 print("Time:${message.values.first.toString()}");
               }
               else if (_fetchOldLatestMessage.keys.first.toString() ==
                   ChatMessageTypes.Audio.toString()) {
                 var message = _fetchOldLatestMessage.values.first;
                 chatMessageTypes = ChatMessageTypes.Audio;
                 msg = "Audio";
                 msgTime = message.values.first.toString();
                 print("Message: Audio");
                 print("Time:${message.values.first.toString()}");
               }
             }
             else{
               chatMessageTypes = ChatMessageTypes.Text;
               msg = _about;
               msgTime = "";
             }
           }
           print("Message Count:$msgCount");
           print("${everyDocument.get("status")}");
           print("isOnline: $isOnline");
           if (mounted) {
             setState(() {
               _allConnectionUserName.add(_connectedUserName);
               userAbout.add(_about);
               msgCounts.add(msgCount);
               OnlineStatus.add(isOnline);
               messageType.add(chatMessageTypes);
               Message.add(msg);
               messageTime.add(msgTime);
               userProfile.add(_profilePath);
               print("messageTime: $messageTime");
             });
           }
         }
       });
     }
     if (mounted) {
       setState(() {
         _isLoading = false;
       });
     }
   }

   Future<void> _fetchRealTimeDataFromCloudStorage() async {
     final realTimeSnapshot = await _cloudStoreDataManagement
         .fetchRealTimeDataFromFirestore();
     realTimeSnapshot!.listen((querySnapshot) {
       querySnapshot.docs.forEach((queryDocumentSnapshot) async {
         if (queryDocumentSnapshot.id ==
             FirebaseAuth.instance.currentUser?.email.toString()) {
           print("${queryDocumentSnapshot.toString()}  ${querySnapshot
               .toString()}");
           await _checkingForNewConnection(
               queryDocumentSnapshot, querySnapshot.docs);
         }
       });
     });
   }

   @override
   void initState() {
     _fetchRealTimeDataFromCloudStorage();
     super.initState();
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       body: Container(
         margin: const EdgeInsets.only(top: 20.0),
         child: LoadingOverlay(
           isLoading: _isLoading,
           child: ListView.builder(
             itemCount: _allConnectionUserName.length,
             itemBuilder: (context, index) {
               return MessageChat(
                   context: context,
                   index: index,
                   image: userProfile[index],
                   name: _allConnectionUserName[index],
                   msg: Message[index],
                   chatMsgType: messageType[index],
                   time: messageTime[index],
                   msgCount: msgCounts[index],
                   isOnline: OnlineStatus[index]);
             },
           ),
         ),
       ),
       floatingActionButton: FloatingActionButton(
         backgroundColor: const Color.fromRGBO(8,33,198,1),
         tooltip: "New Chat",
         child:const Icon(Icons.message,color: Colors.white,),
         onPressed: (){
           Navigator.push(context, MaterialPageRoute(builder: (_) =>SelectDepartment(
               userName: widget.userName,
               userCharacter: widget.userCharacter,
               userMail:widget.email)));

         },
       ),
     );
   }

   Widget MessageChat(
       {required BuildContext context,
         required int index,
         required String image,
         required String name,
         required String msg,
         required ChatMessageTypes chatMsgType,
         required String time,
         required int msgCount,
         required bool isOnline}
       ) {
     return OpenContainer(
       //openColor: royalBlue,
       middleColor: const Color.fromRGBO(0, 0, 0, 0.001),
       closedElevation: 0.0,
       transitionDuration: Duration(milliseconds: 500),
       transitionType: ContainerTransitionType.fadeThrough,
       openBuilder: (_,__){
         return ChatScreen(userName: name, profile: image,);
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
                                       child: FittedBox(fit:BoxFit.cover,child:Image.network(image))),
                                   if(isOnline) Positioned(
                                     right: 0,
                                     child: Container(
                                       width: 15,
                                       height: 15,
                                       decoration: BoxDecoration(
                                           color: Colors.blue,
                                           border:
                                           Border.all(width: 2, color: Colors.white),
                                           borderRadius: BorderRadius.circular(10)),
                                     ),
                                   )
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