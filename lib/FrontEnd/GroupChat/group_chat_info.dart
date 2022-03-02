import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/checking_character.dart';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/FrontEnd/GroupChat/create_group/add_memebers_group.dart';
import 'package:chat_app/FrontEnd/GroupChat/group_chat_screen.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupInfo extends StatefulWidget {

  final String groupName,groupId, userName, profilePath;

  const GroupInfo({Key? key, required this.groupName,required this.groupId,required this.userName, required this.profilePath}) : super(key: key);

  @override
  _GroupInfoState createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {

  bool _isLoading = false;
  List _membersList = [];
  late int userIndex;
  final String _rmsg = "You Want to Remove";
  bool onEditName = false;
  late String _groupName;
  final nameFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();

  CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
  CloudStoreCharacter _cloudStoreCharacter = CloudStoreCharacter();

  Future<void> _getMembersList() async{
    List members =await _cloudStoreDataManagement.getMembersList(groupId: widget.groupId);
    for(int i=0;i<members.length;i++){
      if(members[i]["userName"] == widget.userName){
        setState(() {
          userIndex = i;
          print("$userIndex");
        });
      }
    }
    if(mounted){
      setState(() {
        _membersList = members;
      });
    }
  }

  bool checkAdmin(){
    bool isAdmin= false;
    _membersList.forEach((element) {
      if(element["userName"] == widget.userName){
        isAdmin=element["isAdmin"];
      }
    });

    return isAdmin;
  }

  void showCannot(String msg){
    showDialog(context: context, builder: (_){
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
        ),
        elevation: 0.3,
        backgroundColor: Colors.black,
        content: Container(
          width: MediaQuery.of(context).size.width*0.05,
          height: MediaQuery.of(context).size.height*0.1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(msg, style: TextStyle(color: Colors.white, fontWeight:FontWeight.bold, fontSize: 16 ),),
              SizedBox(height: 10.0),
              InkWell(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Text(
                  "Ok",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void showRemoveDialog(int index, String msg, bool remove){
    showDialog(context: context, builder: (_){
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
        ),
        elevation: 0.3,
        backgroundColor: Colors.white54,
        content: Container(
          width: MediaQuery.of(context).size.width*0.1,
          height: MediaQuery.of(context).size.height*0.1,
          child: Center(
            child: Column(
              mainAxisAlignment:MainAxisAlignment.spaceBetween,
              children: [
                Text("Are You Sure?", style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
                ),
                FittedBox(
                  child: Text(
                    msg,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        if(remove){ 
                          removeUser(index);
                          Navigator.pop(context);
                        }
                        else{
                          LeaveGroup(index);
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        "Ok",
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    });
  }

  void removeUser(int index) async{
    if(mounted){
      setState(() {
        _isLoading = true;
      });
    }
    String userMail = _membersList[index]["userEmail"];
    _membersList.removeAt(index);
    print(_membersList);

    await _cloudStoreDataManagement.updateGroupMembers(membersList: _membersList, groupId: widget.groupId, uEmail: userMail.toString());

    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }
  }

  void LeaveGroup(int index) async{
    if(mounted){
      setState(() {
        _isLoading = true;
      });
    }
      final String mail = _membersList[index]["userEmail"];
      _membersList.removeAt(index);
      await _cloudStoreDataManagement.updateGroupMembers(membersList: _membersList, groupId: widget.groupId, uEmail: mail);
      String userCharacter = await _cloudStoreCharacter.userCharacter(email: FirebaseAuth.instance.currentUser!.email.toString());
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => GroupChatScreen(userName: widget.userName, userCharacter: userCharacter,)), (route) => false);
      
     if(mounted){
       setState(() {
         _isLoading = false;
       });
     }
  }

  @override
  void initState() {
    _getMembersList();
    super.initState();

    nameFocus.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (onEditName) {
      nameFocus.requestFocus();
    }
    final Size size = MediaQuery.of(context).size;
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
          'Group Info',
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
      backgroundColor: bodyColor,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: ListView(
          children: [
            Center(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      color: lightBlue),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Image.network(widget.profilePath),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Text(
                    widget.groupName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: fadedPurple,
                        fontFamily: 'MyRaidBold',
                        fontSize: 18),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 0.5,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            (checkAdmin())?
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: MaterialButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(context,MaterialPageRoute(builder: (_) =>AddMembersInGroup(memberList: _membersList, groupName: widget.groupName,groupId: widget.groupId,adminName:widget.userName,profilePath: widget.profilePath,)));
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
                          ),
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                              color: royalBlue, shape: BoxShape.circle),
                        ),
                      ),
                      Text(
                        'Add Members',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: royalBlue,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: 'MyRaidBold',
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ):SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: MaterialButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if(!checkAdmin()){
                      showRemoveDialog(userIndex,"You Want To Leave The Group",false);
                    }
                    else{
                      showCannot("You Can't Left");
                    }
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          child: Icon(
                            Icons.logout,
                            color: Colors.white,
                            size: 18,
                          ),
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                              color: royalBlue, shape: BoxShape.circle),
                        ),
                      ),
                      Text(
                        'Leave Group',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: royalBlue,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: 'MyRaidBold',
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 0.5,
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Text(
                  _membersList.length.toString() + '  Participants',
                  style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      overflow: TextOverflow.ellipsis,
                      fontFamily: 'MyRaidBold',
                      fontSize: 14),
                ),
              ),
            ),
            for (int i = 0; i < (_membersList.length); i++)
              GestureDetector(
                onTap: (){
                  if(checkAdmin()){
                      if(_membersList[i]["userName"] != widget.userName){
                        showRemoveDialog(i,_rmsg+" ${_membersList[i]["userName"]}",true);
                      }
                      else{
                        showCannot("You Cannot Remove YourSelf");
                      }
                    }
                },
                child: GroupMemberList(
                  image: Image.network(_membersList[i]["profile_pic"]),
                  name: (_membersList[i]["userName"] == widget.userName)?"You":_membersList[i]["userName"],
                  isAdmin: _membersList[i]["isAdmin"],
                ),
              ),
            // onRemove(groupMembers[i]),
            const SizedBox(
              height: 30,
            ),

          ],
        ),
      ),
    );
  }
}


class GroupMemberList extends StatefulWidget {
  final Image image;
  final String name;
  final bool isAdmin;

  const GroupMemberList(
      {required this.image, required this.name, this.isAdmin = false, Key? key})
      : super(key: key);

  @override
  State<GroupMemberList> createState() => _GroupMemberListState();
}

class _GroupMemberListState extends State<GroupMemberList> {
  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.isAdmin;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 40),
          child: Container(
            width: constraints.maxWidth,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.transparent,
                border: Border.all(color: royalBlue, width: 1)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.transparent),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: widget.image,
                  ),
                ),
                ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(widget.name,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: fadedPurple,
                            overflow: TextOverflow.ellipsis,
                            fontFamily: 'MyRaidBold',
                            fontSize: 18))),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        color: Colors.transparent,
                        child: Text(
                          isAdmin ? 'Admin' : '',
                          style: const TextStyle(
                              color: lightBlue,
                              overflow: TextOverflow.ellipsis,
                              fontFamily: 'MyRaidBold',
                              fontSize: 14),
                        )),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}