import 'dart:io';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/checking_character.dart';
import 'package:chat_app/FrontEnd/screens/home_screen.dart';
import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/BackEnd/sqflite/local_database_management.dart';
import 'package:chat_app/FrontEnd/GroupChat/group_chat_screen.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';


class CreateGroup extends StatefulWidget {
  final List<Map<String,dynamic>> membersList;
  final String userName;
  const CreateGroup(
      {required this.membersList,required this.userName, Key? key})
      : super(key: key);

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  var searchFocus = FocusNode();
  bool onSearch = false;
  final String defaultProfile = "https://firebasestorage.googleapis.com/v0/b/chatapp-2417b.appspot.com/o/KecProfile%2Fklogo.png?alt=media&token=a8c112c6-ce55-40cd-8a80-c7bccbb0e416";
  String profilePath="";
  late var groupMembers;
  var searchResults = [];
  var image;
  TextEditingController _groupName = TextEditingController();
  final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
  final LocalDatabase _localDatabase = LocalDatabase();
  bool _isLoading = false;
  final CloudStoreCharacter _cloudStoreCharacter = CloudStoreCharacter();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    searchFocus.addListener(() {
      setState(() {
        onSearch = searchFocus.hasFocus;
      });
    });
  }

  void onRemove(e) {
    setState(() {
      groupMembers.remove(e);
      if (onSearch) {
        if (searchResults.contains(e)) searchResults.remove(e);
      }
    });
  }

  void buildSearchResults(q) {
    var results = [];
    for (var a in groupMembers) {
      if (a["userName"].toLowerCase().contains(q.toLowerCase())) {
        for (var e in groupMembers) {
          if (e["userName"] == a["userName"]) {
            results.add(e);
          }
        }
      }
    }
    setState(() {
      searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    image = Image(
      image: NetworkImage(defaultProfile),
    );
    print("Image: $image");
    groupMembers = widget.membersList;
    final _formKey = GlobalKey<FormState>();
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
            'Create Group',
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            return LoadingOverlay(
              isLoading: _isLoading,
              child: Stack(
                children: [
                  ListView(
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: (){
                            showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 80,
                                  color: Colors.white54,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundColor: Colors.black12,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.camera_alt_rounded,
                                              color:const Color.fromRGBO(0, 180, 255, 1),
                                            ),
                                            onPressed: () async{
                                              if(mounted){
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                              }
                                              final _pickedImage = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
                                              if(_pickedImage!=null){
                                                final imageTemporary = File(_pickedImage.path);
                                                setState(() {
                                                  this.image = Image.file(imageTemporary);
                                                  profilePath = _pickedImage.path.toString();
                                                });
                                               }
                                              if(mounted){
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              }
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.black12,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.photo,
                                              color:const Color.fromRGBO(0, 180, 255, 1),
                                            ),
                                            onPressed: () async{
                                              if(mounted){
                                                setState(() {
                                                  _isLoading = true;
                                                });
                                              }
                                              final _pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
                                              if(_pickedImage!=null){
                                                final imageTemporary = File(_pickedImage.path);
                                                setState(() {
                                                  image = Image.file(imageTemporary);
                                                  profilePath = _pickedImage.path.toString();
                                                });
                                               }
                                              if(mounted){
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                              }
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: 100,
                            height: 100,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                color: Colors.red),
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child:(profilePath == "")? image:Image.file(File(profilePath)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Container(
                          width: constraints.maxWidth * 0.6,
                          decoration: const BoxDecoration(
                              color: Colors.transparent,
                              borderRadius:
                              BorderRadius.all(Radius.circular(20))),
                          padding: const EdgeInsets.all(10),
                          child: Form(
                            key: _formKey,
                            child: TextFormField(
                              controller: _groupName,
                              validator: (String? value){
                                if(value!.isEmpty){
                                  return "Please Enter Group Name";
                                }
                                else{
                                  return null;
                                }
                              },
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              maxLength: 50,
                              cursorColor: fadedPurple,
                              style: const TextStyle(
                                  color: fadedPurple,
                                  fontFamily: 'MyRaidBold',
                                  fontSize: 18),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                counterText: '',
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                hintText: 'Enter Group Name',
                                hintStyle: TextStyle(
                                    color: fadedPurple,
                                    fontFamily: 'MyRaidBold',
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: constraints.maxWidth * 0.8,
                          decoration: const BoxDecoration(
                              color: fadedWhite,
                              borderRadius:
                              BorderRadius.all(Radius.circular(20))),
                          child: TextFormField(
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            maxLength: 50,
                            cursorColor: fadedPurple,
                            onChanged: (text) => buildSearchResults(text),
                            focusNode: searchFocus,
                            style: const TextStyle(
                                color: fadedPurple,
                                fontFamily: 'MyRaidBold',
                                fontSize: 16),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              counterText: '',
                              floatingLabelBehavior: FloatingLabelBehavior.never,
                              hintText: 'Search People in group',
                              suffixIcon: onSearch
                                  ? IconButton(
                                onPressed: () => searchFocus.unfocus(),
                                padding: EdgeInsets.zero,
                                icon: Icon(
                                  Icons.close,
                                  color: fadedPurple.withOpacity(0.3),
                                ),
                              )
                                  : Icon(
                                Icons.search,
                                color: fadedPurple.withOpacity(0.3),
                              ),
                              hintStyle: TextStyle(
                                  color: fadedPurple.withOpacity(0.3),
                                  fontFamily: 'MyRaidBold',
                                  fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      for (int i = 0;
                      i <
                          (onSearch
                              ? searchResults.length
                              : groupMembers.length);
                      i++)
                        GroupMember(
                          image:Image.network((onSearch ? searchResults : groupMembers)[i]["profile_pic"]),
                          name: (onSearch ? searchResults : groupMembers)[i]["userName"],
                          onRemove: () => onRemove(
                              (onSearch ? searchResults : groupMembers)[i]),
                        ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                      )
                    ],
                  ),
                  Positioned(
                      bottom: 0,
                      child: Container(
                        color: bodyColor,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.1,
                        child: Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: const BoxDecoration(
                                color: royalBlue,
                                borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                            child: TextButton(
                              child: const Text(
                                'Create Group',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'MyRaidBold',
                                    fontSize: 18),
                              ),
                              onPressed: () async{
                                if(_formKey.currentState!.validate()){
                                  if(mounted){
                                    setState(() {
                                      _isLoading = true;
                                    });
                                  }
                                  final email = FirebaseAuth.instance.currentUser!.email.toString();
                                  final String userCharacter = await _cloudStoreCharacter.userCharacter(email: email);
                                  final String _messageTime = "${DateTime.now().hour}:${DateTime.now().minute}";
                                  final String? userProfilePath = await _cloudStoreDataManagement.getProfile(email: email);
                                  late String? downloadProfilePath;
                                  if(profilePath !=""){
                                    downloadProfilePath = await _cloudStoreDataManagement.uploadMediaToStorage(File(profilePath), reference: "groups/Profile");
                                  }
                                  else{
                                    setState(() {
                                      downloadProfilePath = defaultProfile;
                                    });
                                  }
                                  if(downloadProfilePath != null){
                                    String _createGroupId=await _cloudStoreDataManagement.createGroup(membersList:widget.membersList, GroupName: _groupName.text,userName: widget.userName,profilePath: downloadProfilePath!);
                                    if(_createGroupId != ""){
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Group Created Successfully")));
                                      await _cloudStoreDataManagement.sendMessageToGroup(
                                        sendMessageData: {
                                          ChatMessageTypes.Notify.toString():{
                                            "Message":"${widget.userName} Created this Group",
                                            "Time":_messageTime,
                                            "Holder":widget.userName
                                          }},
                                        groupId:_createGroupId,
                                        chatMessageTypes: ChatMessageTypes.Notify,
                                      );
                                      bool createGroupTable = await _localDatabase.insertOrUpdateThisGroupData(groupName: _groupName.text, groupId: _createGroupId.toString());
                                      if(createGroupTable){
                                        await _localDatabase.createTableForTheGroupMessage(
                                            groupName: _groupName.text);
                                        await _localDatabase.insertMessageInGroupTable(
                                            groupName: _groupName.text,
                                            actualMessage:  "You Created this Group",
                                            chatMessageTypes: ChatMessageTypes.Notify,
                                            messageHolderName: widget.userName,
                                            messageDateLocal: DateTime.now().toString().split(" ")[0],
                                            messageTimeLocal: _messageTime
                                        );
                                      }
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => GroupChatScreen(
                                        userName: widget.userName, userCharacter: userCharacter,)));
                                    }
                                    else{
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("There is Some Error in creating group")));
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => GroupChatScreen(
                                        userName: widget.userName, userCharacter: userCharacter,)));
                                    }
                                  }
                                  else{
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("There is Some Error in creating group")));
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen(character: userCharacter, email: email, userName: widget.userName, profilepath: userProfilePath!)));
                                  }
                                  if(mounted){
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ))
                ],
              ),
            );
          },
        ));
  }
}

class GroupMember extends StatefulWidget {
  final Image image;
  final String name;
  // ignore: prefer_typing_uninitialized_variables
  final Function onRemove;

  const GroupMember(
      {required this.image,
        required this.name,
        required this.onRemove,
        Key? key})
      : super(key: key);

  @override
  State<GroupMember> createState() => _GroupMemberState();
}

class _GroupMemberState extends State<GroupMember> {
  @override
  Widget build(BuildContext context) {
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
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: Colors.red),
                          child: IconButton(
                            onPressed: () => widget.onRemove(),
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              MdiIcons.minus,
                              color: Colors.white,
                            ),
                          )),
                    ),
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
