import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class StudentUserManagement{
  final _collectionName = 'kec_users';
  final _userid = FirebaseAuth.instance.currentUser!.uid.toString();
  Future<bool> studentuserentry({required String userName , required String email, required String character, required String department,required String year, required String degree, required String profilePath}) async{
    try{
      String? getToken = await FirebaseMessaging.instance.getToken();
      FirebaseFirestore.instance.doc('$_collectionName/$email').set({
        "userName": userName,
        "userToken":getToken.toString(),
        "userEmail":email,
        "userCharacter":character,
        "userDepartment":department,
        "userDegree":degree,
        "userYear":year,
        "profile_pic":profilePath,
        "connections":{},
        "connectionName":[],
        "principalMessages":[],
        "groups":[],
        "status":"",
        "about":character,
      });

      return true;
    }
    catch(e){
        print("Error in Register faculty ${e.toString()}");
        return false;
    }

  }
}