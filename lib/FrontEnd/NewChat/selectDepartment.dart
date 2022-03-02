import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:chat_app/FrontEnd/NewChat/selectCharacter.dart';
import 'package:chat_app/FrontEnd/NewChat/selectUser.dart';
import 'package:flutter/material.dart';

class SelectDepartment extends StatefulWidget {
  final String userName;
  final String userCharacter;
  final String userMail;
  final String userProfile;
  const SelectDepartment({Key? key, required this.userName,required this.userCharacter, required this.userMail, required this.userProfile}) : super(key: key);

  @override
  State<SelectDepartment> createState() => _SelectDepartmentState();
}

class _SelectDepartmentState extends State<SelectDepartment>
{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DepartmentAppBar(),
      backgroundColor: bodyColor,
      body: ListView(
          children: [
            const SizedBox(height: 30,),
            for(var i = 0 ; i < departments.length ; i++ )
              Department(degree: departments[i].degree, department: departments[i].department,tabs: departments[i].tabs,color: i % 2 == 0 ? lightBlue : royalBlue,userName: widget.userName,userCharacter: widget.userCharacter,userMail: widget.userMail,userProfile: widget.userProfile,)
          ]
      ),
    );
  }
}

PreferredSizeWidget DepartmentAppBar() {
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
    title: const Padding(
      padding: EdgeInsets.all(4.0),
      child: Text(
        'Select  Department',
        style: TextStyle(
          fontFamily: 'MyRaidBold',
          color: royalBlue,
          fontSize: 20,
        ),
      ),
    ),
  );
}

class Department extends StatelessWidget {
  final String degree;
  final String department;
  final Color color;
  final String userCharacter;
  final String userName;
  final String userMail;
  final int tabs;
  final String userProfile;
  const Department({required this.color,required this.userProfile,required this.degree,required this.department, required this.tabs,required this.userName,required this.userCharacter,required this.userMail,Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: ElevatedButton(
          onPressed: () {
            print("User Character: $userCharacter");
            if(userCharacter == "Student"){
              Navigator.push(context, MaterialPageRoute(builder: (_) => SelectUser(
                  tabs: ["HOD","Professor","Assisstant Professor","Associate Professor"],
                  userMail: userMail,
                  userCharacter: userCharacter,
                  selectedCharacter: "Faculty",
                  selectedDegree: degree,
                  selectedDepartment: department,
                 userProfile: userProfile,
              )));
            }
            else{
              Navigator.push(context,MaterialPageRoute(builder: (_) =>SelectCharacter(selectedDegree: degree, selectedDepartment:department, userCharacter: userCharacter, userMail: userMail, tabs: tabs,userProfile: userProfile,)));
            }
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.all(0),
            primary: Colors.transparent,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            clipBehavior: Clip.hardEdge,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(width: 2, color: color)),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    color: color,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        degree,
                        style: const TextStyle(
                            fontFamily: 'MyRaidBold',
                            fontSize: 18,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(5),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        department,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontFamily: 'MyRaid',
                            fontSize: 18,
                            color: Colors.black),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
