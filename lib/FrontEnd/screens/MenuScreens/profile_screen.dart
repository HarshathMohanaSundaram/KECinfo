import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/BackEnd/sqflite/local_database_management.dart';
import 'package:chat_app/FrontEnd/widgets/show_image.dart';
import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:chat_app/Global_Uses/show_toast_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _userDetails = {};
  final FToast _fToast = FToast();
  final ImagePicker _imagePicker = ImagePicker();
  final LocalDatabase _localDatabase = LocalDatabase();
  bool _isLoading = false;
  final _formkey = GlobalKey<FormState>();
  int index = -1;
  String _selectedYears = "Year";
  String _userName="Name";
  String _userAbout = "About";
  String _userEmail = "Email";
  List<String> years = ["I","II","III","IV","V"];
  var _selectedDepartment = null;
  List<String> departments = ["Civil","Mechanical","Mechatronics","Automobile","EEE","E&I","ECE","Computer Science","Information Technology","Chemical","Food Technology","AI and DS","AI and ML","Computer Science and Design","B.Sc CSD","B.Sc IS","B.Sc SS","M.Sc Software Systems","MBA","MCA","Construction Engineering and Management","Structural Engineering","Engineering Design","Power Electronics and Drives","Control and Instrumentation","Embedded Systems","VLSI Design","Admin","CCO"];
  String _selectedDegree = "Degree";
  List<String>  degree = ["UG","PG"];
  String _selectedDesigination = "Faculty";
  List<String> designation = ["HOD","Professor","Assisstant Professor","Associate Professor"];
  String _profile = "profile";

  TextEditingController _about = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _name = TextEditingController();


  final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
   Future<void> _getProfileInformation() async{
    if(mounted){
      setState(() {
        _isLoading = true;
      });
    }
    Map<String, dynamic>? _myDetails = await _cloudStoreDataManagement.getCurrentAccountAllData(email: FirebaseAuth.instance.currentUser!.email.toString());
    print("Fetched: $_myDetails");
    if(mounted){
      setState(() {
        _userDetails = _myDetails!;
        print("Updated: $_userDetails");
        _userName = _userDetails["userName"];
        _userAbout = _userDetails["about"];
        _userEmail = _userDetails["userEmail"];
        _profile = _userDetails["profile_pic"];
        _selectedDepartment=_userDetails["userDepartment"];
        if(_userDetails["userCharacter"] == "Student"){
          _selectedDegree = _userDetails["userDegree"];
          _selectedYears = _userDetails["userYear"];
        }
        else{
          _selectedDesigination = _userDetails["Desigination"];
        }
      });
    }
    if(mounted){
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _getProfileInformation();
    _fToast.init(context);
    super.initState();
  }

  void _showDialog(){
    showDialog(context: context, builder: (_){
      return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0)
        ),
        elevation: 0.3,
        backgroundColor: Colors.black,
        content: Container(
          width: MediaQuery.of(context).size.width*0.1,
          height: MediaQuery.of(context).size.height*0.1,
          child: Center(
            child: Column(
              mainAxisAlignment:MainAxisAlignment.spaceBetween,
              children: [
                Text("Save Your Changes", style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
                ),
                FittedBox(
                  child: Text(
                    "You Want Save Your Changes",
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
                        setState(() {
                          index=-1;
                        });
                        showToast("Press Again to Exist",_fToast,toastColor: Colors.white, bgColor: Colors.black);
                        Navigator.pop(context);
                      },
                      child: Text(
                        "No",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          index=-1;
                        });
                        _updateProfile();
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Yes",
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

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text("Profile"),
            titleTextStyle: const TextStyle(fontFamily: 'Myraid', fontSize: 20),
            centerTitle: true,
            leading: BackButton(
              onPressed: (){
                if(index != -1){
                    _showDialog();
                    Navigator.pop(context);
                }
                else{
                  Navigator.pop(context);
                }
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 100,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 180, 255, 1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40))),
          ),
      ),
      body:Padding(
          padding: const EdgeInsets.all(40.0),
          child:Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Container(
                        child: GestureDetector(
                          child: ClipRRect(
                            child: (_profile !="")?Image.network(_profile):Image.network('https://picsum.photos/500'),
                            borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                          ),
                          onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder: (_)=>ShowImage(imageUrl: _profile)));
                          },
                          onLongPress: (){
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
                                                  final String? downloadPath = await _cloudStoreDataManagement.uploadMediaToStorage(File(_pickedImage.path), reference:"Profile/$_userName");
                                                  if(downloadPath != null){
                                                    if(mounted){
                                                      setState(() {
                                                        _userDetails["profile_pic"] = downloadPath;
                                                      });
                                                    }
                                                    await _cloudStoreDataManagement.updateProfileImage(email: _userEmail, path: downloadPath);
                                                    showToast("Profile Pic Updated Successfully", _fToast,bgColor: Colors.black,toastColor: Colors.white);
                                                  }
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
                                                final String? downloadPath = await _cloudStoreDataManagement.uploadMediaToStorage(File(_pickedImage.path), reference:"Profile/$_userName");
                                                if(downloadPath != null){
                                                  if(mounted){
                                                    setState(() {
                                                      _userDetails["profile_pic"] = downloadPath;
                                                    });
                                                  }
                                                  await _cloudStoreDataManagement.updateProfileImage(email: _userEmail, path: downloadPath);
                                                  showToast("Profile Pic Updated Successfully", _fToast,bgColor: Colors.black,toastColor: Colors.white);
                                                }
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
                        ),
                      ),
                    ),
                  )
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    child: Form(
                        key: _formkey,
                        child: SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              FormsText(label: 'Name', value: _userDetails["userName"].toString(),enabled: false),
                              FormsText(label: 'Email', value: _userDetails["userEmail"],enabled: false),
                              FormsText(label: 'About', value: _userAbout),
                              DropdownButtonFormField<String>(
                                value: _selectedDepartment,
                                decoration: InputDecoration(
                                  border: const UnderlineInputBorder(),
                                  labelText: 'Department',
                                  labelStyle:const TextStyle(
                                      color: Colors.black,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'MyRaid'),
                                ),
                                style: const TextStyle(
                                    color: Color.fromRGBO(8, 33, 198, 1),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'MyRaidBold'
                                ),
                                onChanged: (department) =>
                                    setState(() {
                                      index =1;
                                      _selectedDepartment = department!;
                                      _userDetails["userDepartment"] = department;
                                    }),
                                validator: (value) => value == null ? 'Department required' : null,
                                items: departments.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              (_userDetails["userCharacter"] == "Student")?
                                  Column(
                                    children: [
                                      DropdownButtonFormField<String>(
                                        value: _selectedYears,
                                        decoration: InputDecoration(
                                          border: const UnderlineInputBorder(),
                                          labelText: 'Year',
                                          labelStyle:const TextStyle(
                                              color: Colors.black,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'MyRaid'),
                                        ),
                                        style: const TextStyle(
                                            color: Color.fromRGBO(8, 33, 198, 1),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'MyRaidBold'
                                        ),
                                        onChanged: (year) =>
                                            setState(() {
                                              _selectedYears = year!;
                                              _userDetails["userYear"] = year;
                                              index = 0;
                                            }
                                            ),
                                        validator: (value) => value == null ? 'Year required' : null,
                                        items: years.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                      DropdownButtonFormField<String>(
                                        value: _selectedDegree,
                                        decoration: InputDecoration(
                                          border: const UnderlineInputBorder(),
                                          labelText: 'Degree',
                                          labelStyle:const TextStyle(
                                              color: Colors.black,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'MyRaid'),
                                        ),
                                        style: const TextStyle(
                                            color: Color.fromRGBO(8, 33, 198, 1),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            fontFamily: 'MyRaidBold'
                                        ),
                                        onChanged: (degree) =>
                                            setState(() {
                                              _selectedDegree = degree!;
                                              index=0;
                                              _userDetails["userDegree"] = degree;
                                            }),
                                        validator: (value) => value == null ? 'Degree required' : null,
                                        items: degree.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ]
                                  )

                              :(_userDetails["userCharacter"] == "Faculty")?
                              DropdownButtonFormField<String>(
                                value: _selectedDesigination,
                                decoration: InputDecoration(
                                  border: const UnderlineInputBorder(),
                                  labelText: 'Designation',
                                  labelStyle:const TextStyle(
                                      color: Colors.black,
                                      fontSize:22,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'MyRaid'),
                                ),
                                style: const TextStyle(
                                    color: Color.fromRGBO(8, 33, 198, 1),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'MyRaidBold'
                                ),
                                onChanged: (designation) =>
                                    setState(() {
                                      _selectedDesigination = designation!;
                                      index = 0;
                                      _userDetails["Desigination"] = designation;
                                    }),
                                validator: (value) => value == null ? 'Designation required' : null,
                                items: designation.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ):SizedBox.shrink(),
                            ],
                          ),
                        )
                    ),
                  )
                ),
                GestureDetector(
                  child: Container(
                    child: const Center(
                        child: Text(
                          'Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'MyRaid',
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(0, 180, 255, 1),
                        borderRadius: BorderRadius.all(Radius.circular(50.0))),
                    width: double.infinity,
                  ),
                  onTap: ()async{
                    setState(() {
                      index=-1;
                    });
                    _updateProfile();
                  },
                ),
               ],
              ),
          ),
      ),
    );
  }
  Widget FormsText({ required String label, required String value, bool enabled = true}) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'enter correctly';
        }
        return null;
      },
      decoration: InputDecoration(
        border: const UnderlineInputBorder(),
        labelText: label,
        labelStyle: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            fontFamily: 'MyRaid'),
      ),
      style: const TextStyle(
          color: Color.fromRGBO(8, 33, 198, 1),
          fontSize: 24,
          fontWeight: FontWeight.w700,
          fontFamily: 'MyRaidBold'),
      onChanged: (value) {
        setState(() {
          _userDetails["about"] = value;
          _userAbout = value;
          index = 0;
        });
      },
      initialValue: value,
      enabled: enabled,
    );
  }

  void _updateProfile() async{
    bool updateResponse = await _cloudStoreDataManagement.updateProfile(profileInfo: _userDetails, email: FirebaseAuth.instance.currentUser!.email.toString());
    if(updateResponse){
      showToast("Profile Updated Successfully", _fToast, toastColor: Colors.white, bgColor: Colors.black);
    }
    else{
      showToast("There is some error in Updating Profile", _fToast, toastColor: Colors.white, bgColor: Colors.black);
    }
    setState(() {
      index = -1;
    });
  }
}