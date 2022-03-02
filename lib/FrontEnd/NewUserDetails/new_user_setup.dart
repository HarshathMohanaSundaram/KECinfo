import 'dart:io';

import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/faculty_other_user_entry.dart';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/student_user_entry.dart';
import 'package:chat_app/BackEnd/sqflite/local_database_management.dart';
import 'package:chat_app/FrontEnd/screens/home_screen.dart';
import 'package:chat_app/Global_Uses/show_toast_messages.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class SetUp extends StatefulWidget {
  const SetUp({Key? key}) : super(key: key);

  @override
  _SetUpState createState() => _SetUpState();
}

class _SetUpState extends State<SetUp> {
  final String defaultProfile = "https://firebasestorage.googleapis.com/v0/b/chatapp-2417b.appspot.com/o/KecProfile%2Fklogo.png?alt=media&token=a8c112c6-ce55-40cd-8a80-c7bccbb0e416";
  String profilePath ="";
  final FToast _fToast = FToast();
  final ImagePicker _imagePicker = ImagePicker();
  var _characters = ["Student","CCO","Principal","Faculty"];
  var _years = ["I","II","III","IV","V"];
  var _selectedyear= null;
  var _degrees = ["UG","PG"];
  var _selecteddegree = null;
  var _selectedCharacter = null;
  var _departments = ["Civil","Mechanical","Mechatronics","Automobile","EEE","E&I","ECE","Computer Science","Information Technology","Chemical","Food Technology","AI and DS","AI and ML","Computer Science and Design","B.Sc CSD","B.Sc IS","B.Sc SS","M.Sc Software Systems","MBA","MCA","Construction Engineering and Management","Structural Engineering","Engineering Design","Power Electronics and Drives","Control and Instrumentation","Embedded Systems","VLSI Design","Admin","CCO"];
  var _selectedDepartment = null;
  var _designation = ["HOD","Professor","Assisstant Professor","Associate Professor"];
  var _selectedDesignation = null;
  bool _isLoading = false;
  final CloudFirestoreFacultyAndOthers _facultyRegister= CloudFirestoreFacultyAndOthers();
  final StudentUserManagement _studentRegister = StudentUserManagement();
  final LocalDatabase _localDatabase = LocalDatabase();
  final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
  final String _hodGroupName = "HODs";
  final String _hodGroupId = "HOD111";
  final String _ccoGroupName = "CCOs";
  final String _ccoGroupId = "CCO111";
  var image;
  Map<String,dynamic> userDetails={};
  var email = FirebaseAuth.instance.currentUser!.email.toString();
  var _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    String _username = email.split("@")[0].toUpperCase();
    _username = _username.replaceAll(".", "_");
    image = Image(
      image: NetworkImage(defaultProfile),
    );
    print("ProfilePath: $profilePath");
    print("Image: $image");
    return Scaffold(
      // ignore: avoid_print
      resizeToAvoidBottomInset: false,
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: ListView(
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.height * 0.25,
                height: MediaQuery.of(context).size.height * 0.25,
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: GestureDetector(
                        child:FittedBox(
                          fit: BoxFit.cover,
                          child:(profilePath == "")? image:Image.file(File(profilePath)) ,
                        ),
                        onTap: ()async{
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
                                            final _pickedImage = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 50);
                                            if(_pickedImage!=null){
                                              setState(() {
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
                                            final _pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);
                                            if(_pickedImage!=null){
                                              setState(() {
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
                      )),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: MediaQuery
                      .of(context)
                      .size
                      .height * 0.75),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, .1),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(100)),
                ),
                child: SetUpArea(profilePath: (profilePath == "")?defaultProfile:profilePath, userName: _username, profile: (profilePath != "")?profilePath:defaultProfile, defaultProfile: defaultProfile),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget SetUpArea({required String profilePath,required String userName, required String profile, required String defaultProfile}){
    return Container(
      padding: const EdgeInsets.only(
          top: 40.0, left: 10.0, bottom: 40.0, right: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Welcome !',
                      style: TextStyle(
                          fontFamily: 'MyraidBold',
                          fontSize: 22,
                          color: royalPurple),
                    ),
                    SizedBox(height:1),
                    Text(
                      'Set up your account',
                      style: TextStyle(
                          fontFamily: 'Myraid',
                          fontSize: 16,
                          color: fadedPurple),
                    ),
                  ],
                ),
                Text('Set Up',
                    style: TextStyle(fontFamily: 'Mistral', fontSize: 28))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
            child: Container(
              child: SetUpForm(userName: userName),
              padding: const EdgeInsets.all(40.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async{
              String msg ="";
              String? downloadProfile = "";
              if(_formkey.currentState!.validate()) {
                if(mounted){
                  setState(() {
                    _isLoading=true;
                    userDetails={};
                  });
                }
                if(profilePath == defaultProfile){
                  downloadProfile = profilePath;
                }
                else{
                   downloadProfile = await _cloudStoreDataManagement.uploadMediaToStorage(File(profilePath), reference:"Profile/$userName");
                }
                if(downloadProfile != null){
                  if(_selectedCharacter == 'Student'){
                    final bool _studentResponse = await _studentRegister.studentuserentry(userName: userName, email: email, character: _selectedCharacter, department:_selectedDepartment , year: _selectedyear, degree: _selecteddegree, profilePath: downloadProfile);
                    if(_studentResponse){
                      final String _userToken = await _cloudStoreDataManagement.getTokenFromCloud(userMail: FirebaseAuth.instance.currentUser!.email.toString());
                      print("User Token: $_userToken");
                      await _localDatabase.insertOrUpdateThisAccountData(
                        userName: userName,
                        userMail: email,
                        userToken: _userToken,
                        userAbout: _selectedCharacter,
                        userDepartment: _selectedDepartment,
                        profileImagePath: downloadProfile
                      );
                      await _localDatabase.createTableToStoreImportantData();
                      await _localDatabase.createTableToStoreImportantDataForGroup();
                      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_) => HomeScreen(character: _selectedCharacter,email:email,userName: userName,profilepath:profilePath)), (route)=>false);
                    }
                    else{
                      msg="There is some error in registering try again!!";
                    }
                  }
                  else if(_selectedCharacter == "Faculty"||_selectedCharacter=="CCO"){
                    final bool _facultyResponse = await _facultyRegister
                        .facultyotheruserentry(
                        username: userName,
                        email: email,
                        character: _selectedCharacter,
                        department: _selectedDepartment,
                        desgination: _selectedDesignation.toString(),
                        profilePath: downloadProfile
                    );
                    if (_facultyResponse) {
                      final String _userToken = await _cloudStoreDataManagement.getTokenFromCloud(userMail: FirebaseAuth.instance.currentUser!.email.toString());
                      print("User Token: $_userToken");
                      await _localDatabase.insertOrUpdateThisAccountData(
                        userName: userName,
                        userMail: email,
                        userToken: _userToken,
                        userAbout: _selectedCharacter,
                        userDepartment: _selectedDepartment,
                        profileImagePath: downloadProfile
                      );
                      if(_selectedDepartment=="CCO"){
                        setState(() {
                          userDetails.addAll({
                            "userName": userName,
                            "userEmail": email,
                            "UserID": FirebaseAuth.instance.currentUser!.uid,
                            "profile_pic": downloadProfile,
                            "isAdmin": false,
                          });
                        });
                        print("CCO Group  Called");
                        await _cloudStoreDataManagement.addMemberForPrincipalCCOGroup(member: userDetails, groupId: _ccoGroupId, groupName: _ccoGroupName, userMail: email, profile: "https://firebasestorage.googleapis.com/v0/b/chatapp-2417b.appspot.com/o/KecProfile%2Fklogo.png?alt=media&token=a8c112c6-ce55-40cd-8a80-c7bccbb0e416");
                      }
                      if(_selectedDesignation == "HOD"){
                        setState(() {
                          userDetails.addAll({
                            "userName": userName,
                            "userEmail": email,
                            "UserID": FirebaseAuth.instance.currentUser!.uid,
                            "profile_pic": downloadProfile,
                            "isAdmin": false,
                          });
                        });

                        await _cloudStoreDataManagement.addMemberForPrincipalGroup(member: userDetails, groupId: _hodGroupId, groupName: _hodGroupName, userMail: email,profile: "https://firebasestorage.googleapis.com/v0/b/chatapp-2417b.appspot.com/o/KecProfile%2Fklogo.png?alt=media&token=a8c112c6-ce55-40cd-8a80-c7bccbb0e416");
                      }
                      await _localDatabase.createTableToStoreImportantData();
                      await _localDatabase.createTableToStoreImportantDataForGroup();
                      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_) => HomeScreen(character: _selectedCharacter,email:email,userName: userName,profilepath:profilePath)), (route)=>false);
                    }
                    else {
                      msg =
                      "There is some error in registering try again!!";
                    }
                  }
                  else if(_selectedCharacter=="Principal") {
                    final bool _principalResponse = await _facultyRegister
                        .facultyotheruserentry(
                        username: userName,
                        email: email,
                        character: _selectedCharacter,
                        department: _selectedDepartment,
                        desgination: _selectedDesignation.toString(),
                        profilePath: downloadProfile
                    );
                    if (_principalResponse) {
                      final String _userToken = await _cloudStoreDataManagement.getTokenFromCloud(userMail: FirebaseAuth.instance.currentUser!.email.toString());
                      print("User Token: $_userToken");
                      await _localDatabase.insertOrUpdateThisAccountData(
                        userName: userName,
                        userMail: email,
                        userToken: _userToken,
                        userAbout: _selectedCharacter,
                        userDepartment: _selectedDepartment,
                        profileImageUrl: downloadProfile
                      );

                      setState(() {
                        userDetails.addAll({
                          "userName": userName,
                          "userEmail": email,
                          "UserID": FirebaseAuth.instance.currentUser!.uid,
                          "profile_pic": downloadProfile,
                          "isAdmin": true,
                        });
                      });


                      await _cloudStoreDataManagement.addMemberForPrincipalGroup(member:userDetails , groupId: _hodGroupId, groupName: _hodGroupName, userMail: email,profile:"https://firebasestorage.googleapis.com/v0/b/chatapp-2417b.appspot.com/o/KecProfile%2Fklogo.png?alt=media&token=a8c112c6-ce55-40cd-8a80-c7bccbb0e416");
                      await _cloudStoreDataManagement.addMemberForPrincipalCCOGroup(member:userDetails , groupId: _hodGroupId, groupName: _hodGroupName, userMail: email,profile:"https://firebasestorage.googleapis.com/v0/b/chatapp-2417b.appspot.com/o/KecProfile%2Fklogo.png?alt=media&token=a8c112c6-ce55-40cd-8a80-c7bccbb0e416");
                      await _localDatabase.createTableToStoreImportantData();
                      await _localDatabase.createTableToStoreImportantDataForGroup();
                      Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_) => HomeScreen(character: _selectedCharacter,email:email,userName: userName,profilepath: profilePath,)), (route)=>false);
                    }
                    else {
                      msg =
                      "There is some error in registering try again!!";
                    }
                  }
                }
                else{
                  msg = "There is some error in registering try again!!";
                }

                if(mounted){
                  setState(() {
                    _isLoading=false;
                  });
                }
                if(msg !=""){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                }
              }
            },
            child: Container(
              child: const Center(
                  child: Text(
                    'SetUp',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'MyRaid',
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              decoration: const BoxDecoration(
                  color: royalBlue,
                  borderRadius: BorderRadius.all(Radius.circular(50.0))),
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  Widget SetUpForm({required String userName}){
    return SingleChildScrollView(
      child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children:[
              TextFormField(
                initialValue: userName,
                enabled: false,
                maxLines: 1,
                decoration: const InputDecoration(
                    labelText: 'User Name',
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1)),
                    hintStyle: TextStyle(
                        fontFamily: 'Myraid',
                        fontSize: 16,
                        color: Color.fromRGBO(74, 61, 84, .5)),
                    prefixIcon:Icon(MdiIcons.account),
                    prefixIconColor: Colors.grey),
              ),
              TextFormField(
                initialValue: email,
                enabled: false,
                maxLines: 1,
                decoration:const InputDecoration(
                    labelText: 'Mail ID',
                    border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1)),
                    hintStyle: TextStyle(
                        fontFamily: 'Myraid',
                        fontSize: 16,
                        color: Color.fromRGBO(74, 61, 84, .5)),
                    prefixIcon:Icon(Icons.mail_outline_outlined),
                    prefixIconColor: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: DropdownButtonFormField<String>(
                  value: _selectedCharacter,
                  dropdownColor: Colors.white,
                  isExpanded: true,
                  elevation: 10,
                  hint: Text(
                    "Character",
                    style: TextStyle(
                        fontFamily: 'Myraid',
                        fontSize: 16,
                        color: Color.fromRGBO(74, 61, 84, .5)),
                  ),
                  style:const TextStyle(
                      fontFamily: 'Myraid',
                      fontSize: 16,
                      color: Color.fromRGBO(74, 61, 84, 1)),
                  onChanged: (character) =>
                      setState(() => _selectedCharacter = character),
                  validator: (value) => value == null ? 'Character required' : null,
                  items: _characters.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: DropdownButtonFormField<String>(
                  value: _selectedDepartment,
                  dropdownColor: Colors.white,
                  isExpanded: true,
                  elevation: 10,
                  hint: Text(
                    "Department",
                    style: TextStyle(
                        fontFamily: 'Myraid',
                        fontSize: 16,
                        color: Color.fromRGBO(74, 61, 84, .5)),
                  ),
                  style:const TextStyle(
                      fontFamily: 'Myraid',
                      fontSize: 16,
                      color: Color.fromRGBO(74, 61, 84, 1)),
                  onChanged: (department) =>
                      setState(() => _selectedDepartment = department),
                  validator: (value) => value == null ? 'Department required' : null,
                  items: _departments.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),),
              ),
              (_selectedCharacter == "Faculty")?
              Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: DropdownButtonFormField<String>(
                    value: _selectedDesignation,
                    dropdownColor: Colors.white,
                    isExpanded: true,
                    elevation: 10,
                    hint: Text(
                      "Designation",
                      style: TextStyle(
                          fontFamily: 'Myraid',
                          fontSize: 16,
                          color: Color.fromRGBO(74, 61, 84, .5)),
                    ),
                    style:const TextStyle(
                        fontFamily: 'Myraid',
                        fontSize: 16,
                        color: Color.fromRGBO(74, 61, 84, 1)),
                    onChanged: (designation) =>
                        setState(() => _selectedDesignation = designation!),
                    validator: (value) => value == null ? 'Desigination required' : null,
                    items: _designation.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  )
              )
                  :SizedBox.shrink(),
              (_selectedCharacter == "Student")?
              Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: DropdownButtonFormField<String>(
                        value: _selectedyear,
                        dropdownColor: Colors.white,
                        isExpanded: true,
                        elevation: 10,
                        hint: Text(
                          "Year",
                          style: TextStyle(
                              fontFamily: 'Myraid',
                              fontSize: 16,
                              color: Color.fromRGBO(74, 61, 84, .5)),
                        ),
                        style:const TextStyle(
                            fontFamily: 'Myraid',
                            fontSize: 16,
                            color: Color.fromRGBO(74, 61, 84, 1)),
                        onChanged: (year) =>
                            setState(() => _selectedyear = year!),
                        validator: (value) => value == null ? 'Year required' : null,
                        items: _years.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: DropdownButtonFormField<String>(
                        value: _selecteddegree,
                        dropdownColor: Colors.white,
                        isExpanded: true,
                        elevation: 10,
                        hint: Text(
                          "Degree",
                          style: TextStyle(
                              fontFamily: 'Myraid',
                              fontSize: 16,
                              color: Color.fromRGBO(74, 61, 84, .5)),
                        ),
                        style:const TextStyle(
                            fontFamily: 'Myraid',
                            fontSize: 16,
                            color: Color.fromRGBO(74, 61, 84, 1)),
                        onChanged: (degree) =>
                            setState(() => _selecteddegree = degree!),
                        validator: (value) => value == null ? 'Degree required' : null,
                        items: _degrees.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      )
                  )
                ],
              )
                  : SizedBox.shrink(),
            ],
          )),
    );
  }

}

class SetUpArea extends StatefulWidget {
  const SetUpArea({Key? key}) : super(key: key);

  @override
  _SetUpAreaState createState() => _SetUpAreaState();
}

class _SetUpAreaState extends State<SetUpArea> {
  List<String> _characters = ["Student","CCO","Principal","Faculty"];
  var _years = ["I","II","III","IV","V"];
  var _selectedyear= null;
  var _degrees = ["UG","PG"];
  var _selecteddegree = null;
  var _selectedCharacter = null;
  var _departments = ["BTech IT","CSE","Civil","Mechanical","M.Sc","B.Sc","EEE","ECE","E&I","Food Technology","Chemical","Mechatronics","Admin","CCO"];
  var _selectedDepartment = null;
  var _designation = ["HOD","Professor","Assisstant Professor","Associate Professor"];
  var _selectedDesignation = null;
  var _ctugdegree = ["Computer Designing","Software Systems","Information Systems"];
  var _selectedctug = null;
  final String profilePath = "https://firebasestorage.googleapis.com/v0/b/chatapp-2417b.appspot.com/o/chatImages%2FTSmvIkytXxNf0bieyYQXg9GQHlo13112022133520924?alt=media&token=e2596fcd-c330-4238-bf1a-7fbd5290ba46";
  bool _isLoading = false;
  final CloudFirestoreFacultyAndOthers _facultyRegister= CloudFirestoreFacultyAndOthers();
  final StudentUserManagement _studentRegister = StudentUserManagement();
  final LocalDatabase _localDatabase = LocalDatabase();
  final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
  final String _hodGroupName = "HODs";
  final String _hodGroupId = "HOD111";
  Map<String,dynamic> userDetails={};
  var email = FirebaseAuth.instance.currentUser!.email.toString();
  var _formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
          top: 40.0, left: 10.0, bottom: 40.0, right: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 40.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Welcome !',
                      style: TextStyle(
                          fontFamily: 'MyraidBold',
                          fontSize: 22,
                          color: royalPurple),
                    ),
                    Text(
                      'Set up your account',
                      style: TextStyle(
                          fontFamily: 'Myraid',
                          fontSize: 16,
                          color: fadedPurple),
                    ),
                  ],
                ),
                Text('Set Up',
                    style: TextStyle(fontFamily: 'Mistral', fontSize: 28))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
            child: Container(
              child: SetUpForm(),
              padding: const EdgeInsets.all(40.0),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () async{
              if(_formkey.currentState!.validate()){
                print("SetUp Successful");
              }
            },
            child: Container(
              child: const Center(
                  child: Text(
                    'SetUp',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'MyRaid',
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),
              padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
              decoration: const BoxDecoration(
                  color: royalBlue,
                  borderRadius: BorderRadius.all(Radius.circular(50.0))),
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
}



  Widget SetUpForm(){
    String _username = email.split("@")[0].toUpperCase();
    _username = _username.replaceAll(".", "_");
      return LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children:[
                TextFormField(
                  initialValue: _username,
                  enabled: false,
                  maxLines: 1,
                  decoration: const InputDecoration(
                      labelText: 'User Name',
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1)),
                      hintStyle: TextStyle(
                          fontFamily: 'Myraid',
                          fontSize: 16,
                          color: Color.fromRGBO(74, 61, 84, .5)),
                      prefixIcon:Icon(MdiIcons.account),
                      prefixIconColor: Colors.grey),
                ),
                TextFormField(
                  initialValue: email,
                  enabled: false,
                  maxLines: 1,
                  decoration:const InputDecoration(
                      labelText: 'Mail ID',
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1)),
                      hintStyle: TextStyle(
                          fontFamily: 'Myraid',
                          fontSize: 16,
                          color: Color.fromRGBO(74, 61, 84, .5)),
                      prefixIcon:Icon(Icons.mail_outline_outlined),
                      prefixIconColor: Colors.grey),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: DropdownButtonFormField<String>(
                      value: _selectedCharacter,
                        dropdownColor: Colors.white,
                        isExpanded: true,
                        elevation: 10,
                        hint: Row(
                          children: const[
                            Padding(
                                padding: const EdgeInsets.only(left: 10, right: 10),
                                child: Icon(
                                  MdiIcons.post,
                                  color: Colors.grey,
                                )
                            ),
                            Text(
                              "Character",
                              style: TextStyle(
                                  fontFamily: 'Myraid',
                                  fontSize: 16,
                                  color: Color.fromRGBO(74, 61, 84, .5)),
                            ),
                          ],
                        ),
                        style:const TextStyle(
                            fontFamily: 'Myraid',
                            fontSize: 16,
                            color: Color.fromRGBO(74, 61, 84, 1)),
                      onChanged: (character) =>
                          setState(() => _selectedCharacter = character),
                      validator: (value) => value == null ? 'Character required' : null,
                      items: _characters.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      elevation: 10,
                      hint: Row(
                        children: const[
                          Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Icon(
                                MdiIcons.officeBuilding,
                                color: Colors.grey,
                              )
                          ),
                          Text(
                            "Department",
                            style: TextStyle(
                                fontFamily: 'Myraid',
                                fontSize: 16,
                                color: Color.fromRGBO(74, 61, 84, .5)),
                          ),
                        ],
                      ),
                      style:const TextStyle(
                          fontFamily: 'Myraid',
                          fontSize: 16,
                          color: Color.fromRGBO(74, 61, 84, 1)),
                      onChanged: (department) =>
                          setState(() => _selectedDepartment = department),
                      validator: (value) => value == null ? 'Department required' : null,
                      items: _departments.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),),
                  ),
                  (_selectedCharacter == "Faculty")?
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: DropdownButtonFormField<String>(
                      value: _selectedDesignation,
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      elevation: 10,
                      hint: Row(
                        children: const[
                          Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Icon(
                                MdiIcons.account,
                                color: Colors.grey,
                              )
                          ),
                          Text(
                            "Designation",
                            style: TextStyle(
                                fontFamily: 'Myraid',
                                fontSize: 16,
                                color: Color.fromRGBO(74, 61, 84, .5)),
                          ),
                        ],
                      ),
                      style:const TextStyle(
                          fontFamily: 'Myraid',
                          fontSize: 16,
                          color: Color.fromRGBO(74, 61, 84, 1)),
                      onChanged: (designation) =>
                          setState(() => _selectedDesignation = designation!),
                      validator: (value) => value == null ? 'Desigination required' : null,
                      items: _designation.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    )
                  )
                  :SizedBox.shrink(),
                  (_selectedCharacter == "Student")?
                  Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: DropdownButtonFormField<String>(
                            value: _selectedyear,
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            elevation: 10,
                            hint: Row(
                              children: const[
                                Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: Icon(
                                      MdiIcons.account,
                                      color: Colors.grey,
                                    )
                                ),
                                Text(
                                  "Year",
                                  style: TextStyle(
                                      fontFamily: 'Myraid',
                                      fontSize: 16,
                                      color: Color.fromRGBO(74, 61, 84, .5)),
                                ),
                              ],
                            ),
                            style:const TextStyle(
                                fontFamily: 'Myraid',
                                fontSize: 16,
                                color: Color.fromRGBO(74, 61, 84, 1)),
                            onChanged: (year) =>
                                setState(() => _selectedyear = year!),
                            validator: (value) => value == null ? 'Year required' : null,
                            items: _years.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: DropdownButtonFormField<String>(
                            value: _selecteddegree,
                            dropdownColor: Colors.white,
                            isExpanded: true,
                            elevation: 10,
                            hint: Row(
                              children: const[
                                Padding(
                                    padding: const EdgeInsets.only(left: 10, right: 10),
                                    child: Icon(
                                      MdiIcons.postOutline,
                                      color: Colors.grey,
                                    )
                                ),
                                Text(
                                  "Degree",
                                  style: TextStyle(
                                      fontFamily: 'Myraid',
                                      fontSize: 16,
                                      color: Color.fromRGBO(74, 61, 84, .5)),
                                ),
                              ],
                            ),
                            style:const TextStyle(
                                fontFamily: 'Myraid',
                                fontSize: 16,
                                color: Color.fromRGBO(74, 61, 84, 1)),
                            onChanged: (degree) =>
                                setState(() => _selecteddegree = degree!),
                            validator: (value) => value == null ? 'Degree required' : null,
                            items: _degrees.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          )
                      )
                    ],
                  )
                  : SizedBox.shrink(),
                ],
              )),
        ),
      );
    }
  }


// class SetUpForm extends StatefulWidget {
//   const SetUpForm({Key? key}) : super(key: key);
//
//   @override
//   _SetUpFormState createState() => _SetUpFormState();
// }
//
// class _SetUpFormState extends State<SetUpForm> {
//   final _formkey = GlobalKey<_SetUpFormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Form(
//         key: _formkey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             const SetUpText(icon: Icon(MdiIcons.account), label: 'User Name'),
//             const SetUpText(
//                 icon: Icon(Icons.mail_outline_outlined), label: 'Mail ID'),
//             SetUpDrop(
//                 icon: Icon(
//                   MdiIcons.post,
//                   color: Colors.grey,
//                 ),
//                 name: 'Character',
//                 items: ['Student','Faculty','H.O.D','Principal']),
//             SetUpDrop(
//                 icon: Icon(
//                   MdiIcons.officeBuilding,
//                   color: Colors.grey,
//                 ),
//                 name: 'Department',
//                 items: ['M.Sc.','B.E','B.Tech','B.Sc.']),
//           ],
//         ));
//   }
// }
//
// class SetUpDrop extends StatelessWidget {
//   final String name;
//   final List<String> items;
//   final Icon icon;
//   const SetUpDrop({required this.icon,required this.name, required this.items, Key? key})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(top: 10),
//       child: DropdownButton<String>(
//           dropdownColor: Colors.white,
//           isExpanded: true,
//           elevation: 10,
//           underline: Container(
//             color: Colors.grey,
//             height: 1,
//           ),
//           hint: Row(
//             children: [
//               Padding(
//                   padding: const EdgeInsets.only(left: 10, right: 10),
//                   child: icon
//               ),
//               Text(
//                 name,
//                 style: TextStyle(
//                     fontFamily: 'Myraid',
//                     fontSize: 16,
//                     color: Color.fromRGBO(74, 61, 84, .5)),
//               ),
//             ],
//           ),
//           style: TextStyle(
//               fontFamily: 'Myraid',
//               fontSize: 16,
//               color: Color.fromRGBO(74, 61, 84, .5)),
//           items: items.map<DropdownMenuItem<String>>((e) {
//             return DropdownMenuItem<String>(value: e, child: Text(e));
//           }).toList(),
//           onChanged: (String? a) {
//             a = a;
//           }),
//     );
//   }
// }
//
// class SetUpText extends StatefulWidget {
//   final String label;
//   final Icon icon;
//   const SetUpText({required this.icon, required this.label, Key? key})
//       : super(key: key);
//
//   @override
//   _SetUpTextState createState() => _SetUpTextState();
// }
//
// class _SetUpTextState extends State<SetUpText> {
//   @override
//   Widget build(BuildContext context) {
//     final String _label = widget.label;
//     final Icon _icon = widget.icon;
//
//     return TextFormField(
//       decoration: InputDecoration(
//           hintText: _label,
//           border: UnderlineInputBorder(
//               borderSide: BorderSide(color: Colors.grey, width: 1)),
//           hintStyle: const TextStyle(
//               fontFamily: 'Myraid',
//               fontSize: 16,
//               color: Color.fromRGBO(74, 61, 84, .5)),
//           prefixIcon: _icon,
//           prefixIconColor: Colors.grey),
//     );
//   }
// }
