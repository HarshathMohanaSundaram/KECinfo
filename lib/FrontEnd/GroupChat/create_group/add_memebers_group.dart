import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/BackEnd/sqflite/local_database_management.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:chat_app/Global_Uses/show_toast_messages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddMembersInGroup extends StatefulWidget {
  final List memberList;
  final String groupName, groupId,adminName, profilePath;
  const AddMembersInGroup({Key? key, required this.memberList, required this.groupName, required this.groupId, required this.adminName, required this.profilePath}) : super(key: key);

  @override
  _AddMembersInGroupState createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  List<Map<String, dynamic>> _availableUsers = [];
  List<Map<String, dynamic>> _sortedUsers = [];
  List<dynamic> _members = [];
  FToast _fToast = FToast();
  bool _isLoading = false;


  FirebaseAuth _auth = FirebaseAuth.instance;

  final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
  final LocalDatabase _localDatabase = LocalDatabase();

  Future<void> _initialDataFetchAndCheckUp() async {
    if (mounted) {
      setState(() {
        this._isLoading = true;
      });
    }

    final List<Map<String, dynamic>> takeUsers =
    await _cloudStoreDataManagement.getAllUsersListExceptMyAccount(
        currentUserEmail:
        _auth.currentUser!.email.toString());

    final List<Map<String, dynamic>> takeUsersAfterSorted = [];

    if (mounted) {
      setState(() {
        takeUsers.forEach((element) {
          if (mounted) {
            setState(() {
              takeUsersAfterSorted.add(element);
            });
          }
        });
      });
    }

    if (mounted) {
      setState(() {
        _availableUsers = takeUsers;
        _sortedUsers = takeUsersAfterSorted;
        _members = widget.memberList;
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> onAddMembers(Map<String, dynamic> userMap) async {
    if(mounted){
      setState(() {
        _isLoading = true;
      });
    }
    bool isAlreadyExist = false;
    for (final member in _members) {
      if (member["userName"] == userMap["userName"]) {
        isAlreadyExist = true;
      }
    }
    if (!isAlreadyExist) {
      setState(() {
        _members.add({
          "userName": userMap["userName"],
          "userEmail": userMap["userEmail"],
          "UserID": userMap["userID"],
          "profile_pic": userMap["profile_pic"],
          "isAdmin": false,
        });
        _sortedUsers.remove(userMap);
      });

      await _cloudStoreDataManagement.addMembersInGroup(membersList: _members, GroupId: widget.groupId, GroupName:widget.groupName,userMail: userMap["userEmail"],profile:widget.profilePath);

      final String _messageTime = "${DateTime.now().hour}:${DateTime.now().minute}";

      await _cloudStoreDataManagement.sendMessageToGroup(
          sendMessageData: {
            ChatMessageTypes.Notify.toString():{
              "Message":"${widget.adminName.toString()} added ${userMap["userName"].toString()}",
              "Time":_messageTime,
              "Holder":widget.adminName
            }},
          groupId:widget.groupId,
          chatMessageTypes: ChatMessageTypes.Notify,
      );
      await _localDatabase.insertMessageInGroupTable(
          groupName:widget.groupName,
          actualMessage:  "You added ${userMap["userName"].toString()}",
          chatMessageTypes: ChatMessageTypes.Notify,
          messageHolderName: widget.adminName.toString(),
          messageDateLocal: DateTime.now().toString().split(" ")[0],
          messageTimeLocal: _messageTime
      );

    }
    else {
      showToast("${userMap["userName"]} is Already Exist", _fToast,
          bgColor: Colors.black, toastColor: Colors.white);
    }

    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }

  }

  @override
  void initState() {
    _initialDataFetchAndCheckUp();
    _fToast.init(context);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        toolbarHeight: 80,
        elevation: 0,
        title: const Text(
          'Add Members',
          style: TextStyle(
              color: Colors.white, fontFamily: 'MyRaidBold', fontSize: 20),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              color: lightBlue,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40)),
              boxShadow: [
                BoxShadow(
                    blurRadius: 30, offset: Offset.zero, color: Colors.grey)
              ]),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: size.width / 1.15,
            margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),

            child: TextField(
              autofocus: true,
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Search User Name',
                hintStyle: TextStyle(color: Colors.white70),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(width: 2.0, color: Colors.red)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                    BorderSide(width: 2.0, color: Colors.red)),
              ),
              onChanged: (writeText) {
                if (mounted) {
                  setState(() {
                    _isLoading = true;
                    _sortedUsers.clear();

                    print('Available Users: ${_availableUsers}');
                  });
                }
                if (mounted) {
                  _availableUsers.forEach((userMap) {
                    if (userMap["userName"].toString().contains(
                        writeText)) {
                      _sortedUsers.add(userMap);
                    }
                  });
                }
                print(_sortedUsers);
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
            ),
          ),
          Flexible(
            child: LoadingOverlay(
              isLoading: _isLoading,
              child: SingleChildScrollView(
                child: ListView.builder(
                    itemCount: _sortedUsers.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return TextButton(
                        onPressed: () {
                          onAddMembers(_sortedUsers[index]);
                        },
                        style: TextButton.styleFrom(
                            minimumSize: Size.zero, padding: const EdgeInsets.all(0)),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 2.5, top: 2.5),
                          child: Container(
                              width: double.infinity,
                              height: 80,
                              color: fadedWhite,
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 25),
                                        child: Container(
                                            width: 5,
                                            height: constraints.maxHeight,
                                            color:Colors.transparent
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color:Colors.transparent,
                                                    width: .5))),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 15, bottom: 15, right: 15),
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
                                                      child: FittedBox(
                                                          fit: BoxFit.cover, child: Image.network(_sortedUsers[index]['profile_pic']))),
                                                ],
                                              )),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 7,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.transparent,
                                                      width: .5))),
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 12),
                                            child: Container(
                                                height: constraints.maxHeight,
                                                color: Colors.transparent,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 8.0, left: 8, right: 8, bottom: 5),
                                                      child: Text(
                                                        _sortedUsers[index]["userName"],
                                                        style: const TextStyle(
                                                            fontFamily: 'MyRaidBold',
                                                            overflow: TextOverflow.ellipsis,
                                                            fontSize: 16,
                                                            color: fadedPurple),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  );
                                },
                              )),
                        ),
                      );
                    }
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
