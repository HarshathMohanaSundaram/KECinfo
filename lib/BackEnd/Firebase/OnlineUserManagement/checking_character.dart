import 'package:cloud_firestore/cloud_firestore.dart';

class CloudStoreCharacter {
  final _collectionname = "kec_users";
  var _character = "";
  var _userName ="";
  var profilePic="";
  Future<String> userCharacter({required String email}) async {
    try {
      await FirebaseFirestore.instance.collection("$_collectionname").doc(
          "$email").get().then((value) => _character = value['userCharacter']);
      return _character;
    }
    catch (e) {
      print("Error in Checking ${e.toString()}");
      _character = "error";
      return _character;
    }
  }

  Future<String> userName({required String email}) async{
    try{
      await FirebaseFirestore.instance.collection("$_collectionname").doc(
          "$email").get().then((value) => _userName = value['userName']);
      return _userName;
    }
    catch (e){
      print("Error in Getting User Name: ${e.toString()}");
      _userName = "error";
      return _userName;
    }
  }

  Future<String> userProfile({required String email}) async{
    try{
      await FirebaseFirestore.instance.collection("$_collectionname").doc(
          "$email").get().then((value) => profilePic = value['profile_pic']);
      return profilePic;
    }
    catch (e){
      print("Error in Getting User Name: ${e.toString()}");
      profilePic = "error";
      return profilePic;
    }
  }

}