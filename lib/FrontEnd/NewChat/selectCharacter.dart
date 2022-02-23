import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:chat_app/FrontEnd/NewChat/selectUser.dart';
import 'package:flutter/material.dart';

class SelectCharacter extends StatefulWidget {
  final String selectedDepartment;
  final String selectedDegree;
  final String userCharacter;
  final String userMail;
  final int tabs;
  const SelectCharacter({Key? key, required this.selectedDegree, required this.selectedDepartment, required this.userCharacter,required this.userMail, required this.tabs}) : super(key: key);

  @override
  State<SelectCharacter> createState() => _SelectCharacterState();
}

class _SelectCharacterState extends State<SelectCharacter> with TickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    super.initState();

    controller = TabController(length: 2, vsync: this);
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
    List posts = [
      'Faculty',
      'Student'
    ];
    return Scaffold(
      appBar: PostAppBar(),
      backgroundColor: bodyColor,
      body: ListView(children: [
        const SizedBox(
          height: 30,
        ),
        for (var i = 0; i < posts.length; i++)
          Post(post: posts[i], color: i % 2 == 0 ? lightBlue : royalBlue, userCharacter: widget.userCharacter,userMail: widget.userMail,selectedDepartment: widget.selectedDepartment,selectedDegree: widget.selectedDegree,tabs: widget.tabs,)
      ]),
    );
  }
}

PreferredSizeWidget PostAppBar() {
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
        'Select  User  Post',
        style: TextStyle(
          fontFamily: 'MyRaidBold',
          color: royalBlue,
          fontSize: 20,
        ),
      ),
    ),
  );
}

class Post extends StatelessWidget {
  final String post;
  final Color color;
  final String userCharacter;
  final String userMail;
  final String selectedDepartment;
  final String selectedDegree;
  final int tabs;
  const Post({required this.color, required this.post, required this.userMail, required this.userCharacter, required this.selectedDepartment, required this.tabs,required this.selectedDegree,Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: ElevatedButton(
          onPressed: (){
            if(post == "Faculty"){
              Navigator.push(context, MaterialPageRoute(builder: (_)=> SelectUser(tabs: ["HOD","Professor","Assisstant Professor","Associate Professor"], userMail: userMail, userCharacter: userCharacter, selectedCharacter: post, selectedDepartment: selectedDepartment, selectedDegree: selectedDegree)));
            }
            else{
              List year=[];
              if(tabs == 2){
                year=["I Year", "II Year"];
              }
              else if(tabs == 3){
                year=["I Year", "II Year","III Year"];
              }
              else if(tabs == 4){
                year=["I Year", "II Year","III Year","IV Year"];
              }
              else if(tabs==5){
                year=["I Year", "II Year","III Year","IV Year","V Year"];
              }
              print("Tabs: $year");
              Navigator.push(context,MaterialPageRoute(builder: (_) =>SelectUser(
                  tabs: year,
                  userMail: userMail,
                  userCharacter: userCharacter,
                  selectedCharacter: post,
                  selectedDepartment: selectedDepartment,
                  selectedDegree: selectedDegree
              )));
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
              border: Border.all(width: 2, color: color),
              color: Colors.transparent,
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                post,
                style: TextStyle(
                    fontFamily: 'MyRaidBold', fontSize: 18, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
