import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/FrontEnd/GroupChat/create_group/create_group.dart';
import 'package:chat_app/FrontEnd/GroupChat/members_list.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:chat_app/Global_Uses/show_toast_messages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddMembersInGroup extends StatefulWidget {
  final String userName;
  const AddMembersInGroup({Key? key, required this.userName}) : super(key: key);

  @override
  _AddMembersInGroupState createState() => _AddMembersInGroupState();
}

class _AddMembersInGroupState extends State<AddMembersInGroup> {
  List<Map<String, dynamic>> _availableUsers = [];
  List<Map<String, dynamic>> _sortedUsers = [];
  List<Map<String, dynamic>> _selectedMembers=[];
  FToast _fToast = FToast();
  bool _isLoading = false;


  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();

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
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void getCurrentUserDetails() async{
    await _firestore
        .collection("kec_users")
        .doc(_auth.currentUser!.email)
        .get()
        .then((map){
          setState(() {
            _selectedMembers.add({
              "userName": map["userName"],
              "userEmail": map["userEmail"],
              "userToken": map["userToken"],
              "profile_pic":map["profile_pic"],
              "isAdmin":true,
            });
          });
    });
  }

  onUserSelect(Map<String,dynamic> userMap) {
    bool isAlreadyExist = false;
    for(final member in _selectedMembers)
    {
        if(member["userName"] == userMap["userName"]){
          setState(() {
            _selectedMembers.remove(member);
          });
          isAlreadyExist = true;
          break;
        }
    }
    if(!isAlreadyExist){
      setState(() {
        _selectedMembers.add({
          "userName": userMap["userName"],
          "userEmail": userMap["userEmail"],
          "userToken": userMap["userToken"],
          "profile_pic":userMap["profile_pic"],
          "isAdmin":false,
        });
      });
    }
    else{
      showToast("${userMap["userName"]} is Already Selected", _fToast,bgColor: Colors.black,toastColor: Colors.white);
    }
  }
  
  bool isSelected({required String name}){
    for(final member in _selectedMembers){
      if(member["userName"] == name){
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    _initialDataFetchAndCheckUp();
    getCurrentUserDetails();
    _fToast.init(context);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final Size size =MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bodyColor,
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
          'Select Members',
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
      body:Container(
        margin:const EdgeInsets.all(4),
        child: Column(
          children: [
            (_selectedMembers.isNotEmpty)?
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child:Row(
                children: [
                  for(final members in _selectedMembers)
                    Padding(
                      padding: EdgeInsets.only(left:16,top:10),
                      child: GestureDetector(
                        onTap: (){
                          if(members["userEmail"]!= _auth.currentUser!.email)
                          {
                            setState(() {
                              _selectedMembers.remove(members);
                            });
                          }
                          else{
                            showToast("You Cannot be Removed", _fToast,bgColor: Colors.black,toastColor:Colors.white);
                          }
                        },
                        child: Column(
                          children: [
                            ClipOval(
                              child: Image.network(
                                members["profile_pic"].toString(),
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 2,),
                            FittedBox(
                              child: Text(
                                members["userName"].toString()
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              )
            )
            :SizedBox.shrink(),
            Container(
              width: size.width/1.15,
              margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),

                child: TextField(
                  autofocus: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search User Name',
                    hintStyle: TextStyle(color: Colors.white70),
                    focusedBorder: UnderlineInputBorder(
                        borderSide:
                        BorderSide(width: 2.0, color: Color.fromRGBO(0,180,255,1))),
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                        BorderSide(width: 2.0, color: Color.fromRGBO(0,180,255,1))),
                  ),
                  onChanged: (writeText) {
                    if(mounted){
                      setState(() {
                        _isLoading = true;
                        _sortedUsers.clear();

                        print('Available Users: ${_availableUsers}');
                      });
                    }
                    if(mounted){
                      _availableUsers.forEach((userMap) {
                        if (userMap["userName"].toString().contains(writeText)){
                          _sortedUsers.add(userMap);
                        }
                      });
                    }
                    print(_sortedUsers);
                    if(mounted){
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
              ),
            Flexible(
                child: SingleChildScrollView(
                  child: ListView.builder(
                      itemCount: _sortedUsers.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context,index){
                        return TextButton(
                          onPressed: () {
                            onUserSelect(_sortedUsers[index]);
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
                                        Expanded(
                                            flex: 3,
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 10, right: 15),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.transparent,
                                                          width: 0.5)),
                                                  color: Colors.transparent,
                                                ),
                                                height: constraints.maxHeight,
                                                child:  Padding(
                                                  padding: const EdgeInsets.all(10.0),
                                                  child: Container(
                                                      clipBehavior: Clip.hardEdge,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: bodyColor,
                                                      ),
                                                      child: isSelected(name:_sortedUsers[index]["userName"])
                                                          ? Container(
                                                          color: royalBlue,
                                                          child: const Icon(
                                                            Icons.check,
                                                            color: Colors.white,
                                                            size: 30,
                                                          ))
                                                          : Container()),
                                                ),
                                              ),
                                            )
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
          ],
        ),
      ),
      floatingActionButton:(_selectedMembers.length >=2)
        ?FloatingActionButton(
          backgroundColor:const Color.fromRGBO(8,33,198,1),
          child: Icon(
            Icons.arrow_forward,
            size: 30,
            color: Colors.white,
          ),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (_) => CreateGroup(membersList: _selectedMembers, userName:widget.userName,)));
          },
      )
      : SizedBox(),
    );
  }
}

