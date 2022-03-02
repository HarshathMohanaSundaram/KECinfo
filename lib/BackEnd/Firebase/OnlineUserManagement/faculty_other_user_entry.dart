import 'package:chat_app/BackEnd/sqflite/local_database_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CloudFirestoreFacultyAndOthers{

  final _collectionName = 'kec_users';

  final LocalDatabase _localDatabase = LocalDatabase();
  Future<bool> facultyotheruserentry({required String username, required String email, required String character, required String department, required String desgination, required String profilePath})async {
     try{
       final String? _getToken = await FirebaseMessaging.instance.getToken();
         FirebaseFirestore.instance.doc('$_collectionName/$email').set({
           "userName": username,
           "userToken":_getToken.toString(),
           "userEmail":email,
           "userCharacter":character,
           "userDepartment":department,
           "Desigination":desgination,
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
       print("Error In register new user ${e.toString()}");
       return false;
     }

  }
}
