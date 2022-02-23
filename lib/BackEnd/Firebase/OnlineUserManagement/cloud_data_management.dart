import 'dart:io';
import 'package:chat_app/Global_Uses/foreground_receive_notification_management.dart';
import 'package:chat_app/Global_Uses/send_notification_management.dart';
import 'package:uuid/uuid.dart';
import 'package:chat_app/BackEnd/sqflite/local_database_management.dart';
import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


class CloudStoreDataManagement {
  final _collectionname = "kec_users";
  final LocalDatabase _localDatabase = LocalDatabase();
  final SendNotification _sendNotification = SendNotification();

  Future<bool> userRecordPresentOrNot({required String email}) async {
    try {
      DocumentSnapshot<
          Map<String, dynamic>> documentSnapshot = await FirebaseFirestore
          .instance.doc("$_collectionname/$email").get();
      return documentSnapshot.exists;
    }
    catch (e) {
      print("Error in Checking ${e.toString()}");
      return false;
    }
  }

  Future<String> getTokenFromCloud({required String userMail}) async{
    try{
      DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance.doc("$_collectionname/$userMail").get();
      final String userToken = documentSnapshot["userToken"];
      return userToken;
    }
    catch(e){
      print("Error in getting token ${e.toString()}");
      return "";
    }
  }

  Future<Map<String, dynamic>?> getCurrentAccountAllData(
      {required String email}) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance
          .doc('$_collectionname/$email')
          .get();

      return documentSnapshot.data();
    } catch (e) {
      print('Error in getCurrentAccountAll Data: ${e.toString()}');
      return {};
    }
  }

  Future<bool> checkConnection({
    required String oppositeUserMail,
    required String currentUserMail
  })async{
    try{
      int index = -1;
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.doc('$_collectionname/$currentUserMail').get();
      Map<String, dynamic>? map = documentSnapshot.data();
      List<dynamic> _myConnectionsList = map!["connectionName"];
      _myConnectionsList.forEach((connection) {
        if(connection.keys.first.toString() == oppositeUserMail){
          index = 0;
        }
      });
      if(index != -1){
        print("Connection Already Present");
        return true;
      }
      else{
        print("Connection Not Present");
        return false;
      }
    }
    catch(e){
      print("Error in checking Connection ${e.toString()}");
      return false;
    }
  }

  Future<bool> addNewConnection({
    required String oppositeUserMail,
    required String currentUserMail,
  }) async {
    try {
      print('Come here');

      /// Opposite Connection database Update
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.doc('$_collectionname/$oppositeUserMail')
          .get();

      Map<String, dynamic>? map = documentSnapshot.data();
      List<dynamic> _oppositeConnectionsList = map!["connectionName"];
      print('Map: $map');
      Map<String, dynamic>? currentUserMap = await getCurrentAccountAllData(
          email: currentUserMail);
      List<dynamic> _myConnectionsList = currentUserMap!["connectionName"];
      print('Current User Map: $currentUserMap');


      int index = -1;

      _oppositeConnectionsList.forEach((element) {
        if (element == currentUserMail) {
          index = _oppositeConnectionsList.indexOf(element);
        }
      });

      if (index > -1) {
        return true;
      }
      else {
        _oppositeConnectionsList.insert(0,{currentUserMail:0});
        map["connections"].addAll({
          currentUserMail: []
        });
        map["connectionName"] = _oppositeConnectionsList;

        await FirebaseFirestore.instance.doc(
            "$_collectionname/$oppositeUserMail").update(map).whenComplete(() => print("Updated"));
        _myConnectionsList.insert(0,{oppositeUserMail:0});
        currentUserMap["connections"].addAll({
          oppositeUserMail: []
        });
        currentUserMap["connectionName"] = _myConnectionsList;
        await FirebaseFirestore.instance.doc(
            "$_collectionname/$currentUserMail").update(currentUserMap);
        return true;
      }
    } catch (e) {
      print('Error in Change Connection Status: ${e.toString()}');
      return false;
    }
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>?>
  fetchRealTimeDataFromFirestore() async {
    try {
      return FirebaseFirestore.instance.collection(_collectionname).snapshots();
    }
    catch (e) {
      print("Error in fetching real time data ${e.toString()}");
      return null;
    }
  }

  Future<Stream<DocumentSnapshot<Map<String, dynamic>>>?> fetchRealTimeMessages() async {
    try {
      return FirebaseFirestore.instance.doc(
          "$_collectionname/${FirebaseAuth.instance.currentUser!.email
              .toString()}").snapshots();
    }
    catch (e) {
      print("Error in fetching real time Messages");
      return null;
    }
  }


  Future<void> sendMessageToUser({
    required String connectionUserName,
    required Map<String, Map<String, String>>sendMessageData,
    required ChatMessageTypes chatMessageTypes
  }) async {
    print("Send Message To User Called");
    final String currentUserEmail = FirebaseAuth.instance.currentUser!.email
        .toString();
    final String? _getUserEmail = await _localDatabase
        .getParticularDataFromImportantTable(
        userName: connectionUserName,
        getField: GetFieldForImportantDataLocalDatabase.UserEmail);
      try {
        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.doc("$_collectionname/$_getUserEmail")
            .get();
        final Map<String, dynamic>? userData = documentSnapshot.data();
        List<dynamic> getConnectionName = userData!["connectionName"];
        for(int i=0;i<getConnectionName.length;i++){
          if(getConnectionName[i].keys.first.toString() == currentUserEmail){
            int msgCount = getConnectionName[i].values.first;
            msgCount = msgCount+1;
            getConnectionName[i] = {getConnectionName[i].keys.first.toString():msgCount};
            var item = getConnectionName[i];
            print("item:$item");
            print("Connection:$getConnectionName");
            getConnectionName.remove(item);
            print("Removed Connection: $getConnectionName");
            getConnectionName.insert(0, item);
            print("After Adding: $getConnectionName");
            break;
          }
        }
        userData["connectionName"] = getConnectionName;
        List<dynamic>? getOldMessages = userData["connections"][currentUserEmail.toString()];
        if (getOldMessages == null) getOldMessages = [];
        getOldMessages.add(sendMessageData);
        userData["connections"][currentUserEmail.toString()] = getOldMessages;
        await FirebaseFirestore.instance.doc("$_collectionname/$_getUserEmail")
            .update({
          "connections": userData["connections"],
          "connectionName": userData["connectionName"],
        })
            .whenComplete(() async{
          print("Data Send Completed");

          final String? conUserToken = await _localDatabase.getParticularDataFromImportantTable(userName: connectionUserName, getField: GetFieldForImportantDataLocalDatabase.Token);
          final String? currUserName = await _localDatabase.getUserNameForParticularUser(userMail: FirebaseAuth.instance.currentUser!.email.toString());
          print("Notification Send Started");
          await _sendNotification.messageNotificationClassifier(chatMessageTypes, userToken:conUserToken ?? "" , currUserName:currUserName ?? "");
          print("Notification Send Completed");
        });
        final DocumentSnapshot<Map<String, dynamic>> currentUser = await FirebaseFirestore.instance.doc("$_collectionname/$currentUserEmail").get();
        final Map<String, dynamic>? currentUserData = currentUser.data();
        List<dynamic> _currentConnectionList = currentUserData!["connectionName"];
        for(int i=0;i<_currentConnectionList.length;i++){
          if(_currentConnectionList[i].keys.first.toString() == _getUserEmail){
            var item = _currentConnectionList[i];
            print("item:$item");
            print("Connection:$_currentConnectionList");
            _currentConnectionList.remove(item);
            print("Removed Connection: $_currentConnectionList");
            _currentConnectionList.insert(0, item);
            print("After Adding: $_currentConnectionList");
            break;
          }
        }
        currentUserData["connectionName"] = _currentConnectionList;
        await FirebaseFirestore.instance.doc("$_collectionname/$currentUserEmail").update({
            "connectionName": currentUserData["connectionName"],
        });
        print("Send Message Completed");
      }
      catch (e) {
        print("Error in sending message ${e.toString()}");
      }
  }

  Future<void> removeOldMessages({required String userEmail}) async {
    try {
      final String? currentUserEmail = FirebaseAuth.instance.currentUser!.email;

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.doc("$_collectionname/$currentUserEmail").get();

      final Map<String, dynamic>? connectedUserData = documentSnapshot.data();
      connectedUserData!["connections"][userEmail.toString()] = [];

      List<dynamic> connectionName = connectedUserData["connectionName"];
      for(int i=0;i<connectionName.length;i++){
        if(connectionName[i].keys.first.toString() == userEmail){
          int msgCount = connectionName[i].values.first;
          msgCount = 0;
          connectionName[i] = {connectionName[i].keys.first.toString():msgCount};
          break;
        }
      }
      connectedUserData["connectionName"] = connectionName;

      await FirebaseFirestore.instance.doc("$_collectionname/$currentUserEmail")
          .update({
        "connections": connectedUserData["connections"],
        "connectionName":connectedUserData["connectionName"]
      }).whenComplete(() => print("Data Send Completed"));
    }
    catch (e) {
      print("error in send Data: ${e.toString()}");
    }
  }

  Future<String?> uploadMediaToStorage(File filepath,{required String reference, String fileName=""}) async {
    try {
      print("Upload Media");
      String? downloadUrl;
      late String filename;
      if(fileName == ""){
        filename =
        "${FirebaseAuth.instance.currentUser!.uid}${DateTime
            .now()
            .day}${DateTime
            .now()
            .month}${DateTime
            .now()
            .year}${DateTime
            .now()
            .hour}${DateTime
            .now()
            .minute}${DateTime
            .now()
            .second}${DateTime
            .now()
            .millisecond}";
      }
      else{
        filename = fileName;
      }

      final Reference firebaseStorageRef = FirebaseStorage.instance.ref(
          reference).child(filename);
      print("Firebase Storage Reference: $firebaseStorageRef");

      final UploadTask uploadTask = firebaseStorageRef.putFile(filepath);
      await uploadTask.whenComplete(() async {
        print("Media Uploaded");
        downloadUrl = await firebaseStorageRef.getDownloadURL();
        print("Download URL: $downloadUrl");
      });
      print("Upload Successfull");
      return downloadUrl;
    }
    catch (e) {
      print("Error: Firebasebase Storage Exception is ${e.toString()}");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsersListExceptMyAccount(
      {required String currentUserEmail}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection(_collectionname)
          .get();

      List<Map<String, dynamic>> _usersDataCollection = [];

      querySnapshot.docs.forEach(
              (QueryDocumentSnapshot<
              Map<String, dynamic>> queryDocumentSnapshot) {
            if (currentUserEmail != queryDocumentSnapshot.id) {
              _usersDataCollection.add(queryDocumentSnapshot.data());
            }
          });

      print(_usersDataCollection);

      return _usersDataCollection;
    } catch (e) {
      print('Error in get All Users List: ${e.toString()}');
      return [];
    }
  }

  Future<String> createGroup({required List<Map<String,
      dynamic>> membersList, required String GroupName, required String userName, required String profilePath}) async {
    try {
      String groupId = Uuid().v1();
      await FirebaseFirestore.instance.collection("groups").doc(groupId).set({
        "groupName": GroupName,
        "members": membersList,
        "groupProfile":profilePath,
        "id": groupId,
      });

      for (int i = 0; i < membersList.length; i++) {
        String userEmail = membersList[i]["userEmail"];
        await FirebaseFirestore.instance.collection(_collectionname).doc(
            userEmail).collection("groups").doc(groupId).set({
          "groupName": GroupName,
          "groupId": groupId,
          "groupProfile":profilePath,
          "Message":[],
          "msgCount":0,
        });
        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.doc("$_collectionname/$userEmail").get();
        final Map<String, dynamic>? userData = documentSnapshot.data();
        List<dynamic>? getGroups = userData!["groups"];
        print("Groups:$getGroups");
        if(getGroups == null){
          getGroups = [];
        }
        getGroups.insert(0, { "groupName": GroupName, "groupId": groupId,});
        userData["groups"] = getGroups;
        print("After Adding: ${userData["groups"]}");
        await FirebaseFirestore.instance.doc("$_collectionname/$userEmail").update({
          "groups": userData["groups"],
        }).whenComplete(() => print("Data Added in Groups: ${userData["groups"]}"));
      }
      return groupId;
    }
    catch (e) {
      print("Error in Creating Group ${e.toString()}");
      return "";
    }
  }

  Future<List> getGroups({required String email}) async {
    List groups = [];
    await FirebaseFirestore.instance
        .collection(_collectionname)
        .doc(email)
        .get()
        .then((value) {
      groups = value["groups"];
      print("groups");
    });
    return groups;
  }

  Future<void> sendMessageToGroup({
    required Map<String,Map<String, String>>sendMessageData, required String groupId, required ChatMessageTypes chatMessageTypes}) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.collection("groups").doc(groupId).get();
      final List<dynamic> Members = documentSnapshot
          .data()!["members"];
      final String groupName = documentSnapshot.data()!["groupName"];
      List<dynamic>? getOldMessages = [];
      int msgCount = 0;
      for (int i = 0; i < Members.length; i++) {
        getOldMessages = [];
        msgCount = 0;
        if (Members[i]['userEmail'] != FirebaseAuth.instance.currentUser!.email) {
          final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore
              .instance.doc("$_collectionname/${Members[i]['userEmail']}")
              .collection("groups").doc(groupId)
              .get();
          final Map<String, dynamic>? userData = documentSnapshot.data();
          getOldMessages = userData!["Messages"];
          msgCount = userData["msgCount"];
          if(getOldMessages == null){
            getOldMessages = [];
          }
          getOldMessages.add(sendMessageData);
          userData["Messages"] = getOldMessages;
          if(chatMessageTypes!= ChatMessageTypes.Notify) {
            msgCount = msgCount + 1;
          }
          userData["msgCount"] = msgCount;
          await FirebaseFirestore.instance.doc("$_collectionname/${Members[i]['userEmail']}").collection("groups").doc(groupId).update({
            "Messages":userData["Messages"],
            "msgCount":userData["msgCount"],
          });
          final String? conUserToken = Members[i]["userToken"];
          final String? currUserName = await _localDatabase.getUserNameForParticularUser(userMail: FirebaseAuth.instance.currentUser!.email.toString());

          print("Notification Send Started");
          await _sendNotification.messageNotificationClassifier(chatMessageTypes, userToken:conUserToken ?? "" , currUserName:currUserName ?? "",groupName: groupName,groupMessage: 1);
          print("Notification Send Completed");

          final DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore
              .instance.doc("$_collectionname/${Members[i]['userEmail']}")
              .collection("groups").doc(groupId)
              .get();
           Map<String, dynamic>? userCollection = userSnapshot.data();
           List<dynamic> groups = userCollection!["groups"];
           for(int i=0;i<groups.length;i++){
             if(groupId == groups[i]["groupId"]){
               var item = groups[i];
               print("Groups: $groups");
               print("Item: $item");
               groups.remove(item);
               print("After Removing: $groups");
               groups.insert(0, item);
               print("After Adding: $groups");
             }
           }
        }
      }
    }
    catch (e) {
    print("Error in sending message ${e.toString()}");
    }
  }

  Future<Stream<DocumentSnapshot<Map<String, dynamic>>>?> fetchRealTimeGroupMessages(
      {required String groupId, required String userMail}) async {
    try {
      return FirebaseFirestore.instance.collection(_collectionname).doc(userMail).collection("groups").doc(groupId).snapshots();
    }
    catch (e) {
      print("Error in fetching real time Messages");
      return null;
    }
  }

  Future<void> removeOldGroupMessages({required String groupId, required String userMail}) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.doc("$_collectionname/$userMail").collection("groups").doc(groupId).get();

      final Map<String, dynamic>? groupData = documentSnapshot.data();
      groupData!["Messages"]=[];

      int msgCount = groupData["msgCount"];
      msgCount=0;
      groupData["msgCount"] = msgCount;

      await FirebaseFirestore.instance.doc("$_collectionname/$userMail").collection("groups").doc(groupId)
          .update({
        "Messages": groupData["Messages"],
        "msgCount": groupData["msgCount"]
      }).whenComplete(() => print("Data Send Completed"));
    }
    catch (e) {
      print("error in send Data: ${e.toString()}");
    }
  }

  Future<List<dynamic>> getMembersList({required String groupId}) async{
    try{
      List<dynamic> memberList = [];
      await FirebaseFirestore.instance
          .collection("groups")
          .doc(groupId)
          .get()
          .then((group) => memberList = group["members"]);
      return memberList;
    }
    catch(e){
      print("Error in getting Memebers List: ${e.toString()}");
      return [];
    }
  }

  Future<void> updateGroupMembers({required List<dynamic> membersList, required String groupId, required String uEmail}) async{
    try{
      await FirebaseFirestore.instance.collection("groups").doc(groupId).update({
        "members": membersList,
      });
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.doc("$_collectionname/$uEmail").get();
      final Map<String, dynamic>? userData = documentSnapshot.data();
      List<dynamic>? getGroups = userData!["groups"];
      print("Groups:$getGroups");
      if(getGroups == null){
        getGroups = [];
      }
      getGroups.removeWhere((element) => element["groupId"]==groupId);
      userData["groups"] = getGroups;
      print("After Adding: ${userData["groups"]}");
      await FirebaseFirestore.instance.doc("$_collectionname/$uEmail").update({
        "groups": userData["groups"],
      }).whenComplete(() => print("Data Added in Groups: ${userData["groups"]}"));
      print("Updated Successfully");
      await FirebaseFirestore.instance.collection(_collectionname).doc(uEmail.toString()).collection("groups").doc(groupId).delete().whenComplete(() => "User Deleted Successsfully");
    }
    catch(e){
      print("Error in Updating Members in group ${e.toString()}");
    }
  }

  Future<void> addMembersInGroup({required List<dynamic> membersList,required String GroupId,required String GroupName,required String userMail, required String profile})async{
      await FirebaseFirestore.instance.collection("groups").doc(GroupId).update({
            "members":membersList
      });
      await FirebaseFirestore.instance.collection(_collectionname).doc(userMail).collection("groups").doc(GroupId).set({
        "groupName": GroupName,
        "groupId": GroupId,
        "groupProfile":profile,
        "Messages":[],
        "msgCount":0,
      });
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.doc("$_collectionname/$userMail").get();
      final Map<String, dynamic>? userData = documentSnapshot.data();
      List<dynamic>? getGroups = userData!["groups"];
      print("Groups:$getGroups");
      if(getGroups == null){
        getGroups = [];
      }
      getGroups.insert(0, { "groupName": GroupName, "groupId": GroupId,});
      userData["groups"] = getGroups;
      print("After Adding: ${userData["groups"]}");
      await FirebaseFirestore.instance.doc("$_collectionname/$userMail").update({
        "groups": userData["groups"],
      }).whenComplete(() => print("Data Added in Groups: ${userData["groups"]}"));

  }


  Future<void> addMemberForPrincipalGroup({required Map<String,dynamic> member, required String groupId,required String groupName, required String userMail, required String profile}) async
  {
    List<dynamic> _groupMembers = await getMembersList(groupId: groupId);
    bool isAvailableUsers = false;
    if(_groupMembers.isNotEmpty) {
        for(int i=0;i<_groupMembers.length;i++)
        {
          if(_groupMembers[i]["userName"] == member["userName"]){
            isAvailableUsers = true;
          }
        }
    }
    if(!isAvailableUsers){
      _groupMembers.add(member);
    }
    await FirebaseFirestore.instance.collection("groups").doc(groupId).update({
      "members":_groupMembers
    });
    await FirebaseFirestore.instance.collection(_collectionname).doc(userMail).collection("groups").doc(groupId).set({
      "groupName": groupName,
      "groupId": groupId,
      "groupProfile":profile,
      "Message":[],
      "msgCount":0,
    });
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await FirebaseFirestore.instance.doc("$_collectionname/$userMail").get();
    final Map<String, dynamic>? userData = documentSnapshot.data();
    List<dynamic>? getGroups = userData!["groups"];
    print("Groups:$getGroups");
    if(getGroups == null){
      getGroups = [];
    }
    getGroups.insert(0, { "groupName": groupName, "groupId": groupId,});
    userData["groups"] = getGroups;
    print("After Adding: ${userData["groups"]}");
    await FirebaseFirestore.instance.doc("$_collectionname/$userMail").update({
      "groups": userData["groups"],
    }).whenComplete(() => print("Data Added in Groups: ${userData["groups"]}"));
  }

  Future<void> updateProfileImage({required String email, required String path}) async{
    try{
      await FirebaseFirestore.instance.doc("$_collectionname/$email").update({
        "profile_pic":path
      });
      Map<String,dynamic>? userDetail = await getCurrentAccountAllData(email: email);
      if(userDetail != null){
        List<dynamic> groupData= userDetail["groups"];
        for(int i = 0; i < groupData.length;i++ ){
          final DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance.collection("groups").doc(groupData[i]["groupId"].toString()).get();
          final Map<String,dynamic>? groupDetails = documentSnapshot.data();
          if(groupDetails != null){
            List member = groupDetails["members"];
            for(int j=0;j<member.length;j++){
              if(member[j]["userEmail"] == email){
                member[j]["profile_pic"] = path;
              }
            }
            await FirebaseFirestore.instance.doc("groups/${groupData[i]["groupId"].toString()}").update({
              "members":member
            }).whenComplete(() => print("profile Updated"));
          }
        }
      }
    }
    catch(e){
      print("Error in Uploading Profile Image: ${e.toString()}");
    }
  }

  Future<void> principalMessageToUser({required Map<String, Map<String, String>>sendMessageData,
    required ChatMessageTypes chatMessageTypes}) async{
    try{
      print("Message Data: $sendMessageData");
      List<Map<String,dynamic>> _userList = await getAllUsersListExceptMyAccount(currentUserEmail:FirebaseAuth.instance.currentUser!.email.toString());
      List<dynamic> getOldMessages=[];
      for(int i=0;i<_userList.length;i++){
          getOldMessages = [];
          getOldMessages = _userList[i]["principalMessages"];
          print("Old Messages: $getOldMessages");
          if(getOldMessages == null) getOldMessages=[];
          getOldMessages.add(sendMessageData);
          _userList[i]["principalMessages"] = getOldMessages;
          await FirebaseFirestore.instance.doc("$_collectionname/${_userList[i]["userEmail"]}").update({
            "principalMessages":_userList[i]["principalMessages"]
          });
          final String? conUserToken =_userList[i]["userToken"];
          final String? currUserName = "PRINCIPAL";

          print("Notification Send Started");
          await _sendNotification.messageNotificationClassifier(chatMessageTypes, userToken:conUserToken ?? "" , currUserName:currUserName ?? "");
          print("Notification Send Completed");
      }
    }
    catch(e){
      print("Error In Sending Message To Users ${e.toString()}");
    }
  }

 Future<bool> updateProfile({required Map<String, dynamic> profileInfo, required String email}) async{
    try{
      await FirebaseFirestore.instance.doc("$_collectionname/$email").update(profileInfo);
      return true;
    }
    catch(e){
      print("Error in Updating Profile Information ${e.toString()}");
      return false;
    }
 }

  Future<void> removePrincipalMessages({required String userEmail}) async {
    try {
      final String? currentUserEmail = FirebaseAuth.instance.currentUser!.email;

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.doc("$_collectionname/$currentUserEmail").get();

      final Map<String, dynamic>? connectedUserData = documentSnapshot.data();
      connectedUserData!["principalMessages"]=[];

      await FirebaseFirestore.instance.doc("$_collectionname/$currentUserEmail")
          .update({
        "principalMessages": connectedUserData["principalMessages"],
      }).whenComplete(() => print("Data Send Completed"));
    }
    catch (e) {
      print("error in send Data: ${e.toString()}");
    }
  }

  Future<void> setStatus({required String staus}) async{
    try{
      print("status");
      await FirebaseFirestore.instance.doc("$_collectionname/${FirebaseAuth.instance.currentUser!.email.toString()}").update({
        "status":staus
      });
    }
    catch(e){
      print("Error in Updating Status :${e.toString()}");
    }
  }

  Future<Map<String,dynamic>?> getLatestUserMessages({required String connectionEmail}) async{
    try{
      final String currentUserEmail = FirebaseAuth.instance.currentUser!.email.toString();
      final DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance.doc("$_collectionname/$currentUserEmail").get();
      final Map<String,dynamic> _connectionsList = documentSnapshot.data()!["connections"];
      List<dynamic>? getIncomingMessages = _connectionsList[connectionEmail];
      if(getIncomingMessages != null){
        int messageLength = getIncomingMessages.length;
        print("Message: ${getIncomingMessages[messageLength-1]}");
        if(getIncomingMessages[messageLength-1].keys.first.toString() == ChatMessageTypes.Text.toString()){
          return getIncomingMessages[messageLength-1];
        }
        else if(getIncomingMessages[messageLength-1].keys.first.toString() == ChatMessageTypes.Image.toString()){
          return getIncomingMessages[messageLength-1];
        }
        else if(getIncomingMessages[messageLength-1].keys.first.toString() == ChatMessageTypes.Video.toString()){
          return getIncomingMessages[messageLength-1];
        }
        else if(getIncomingMessages[messageLength-1].keys.first.toString() == ChatMessageTypes.Document.toString()){
          return getIncomingMessages[messageLength-1];
        }
        else if(getIncomingMessages[messageLength-1].keys.first.toString() == ChatMessageTypes.Audio.toString()){
          return getIncomingMessages[messageLength-1];
        }
      }
      else{
        return null;
      }
    }
    catch(e){
      return null;
    }
  }

  Future<Map<String,dynamic>?> getGroupDetails({required String groupId }) async{
    try{
      final String currentUserMail = await FirebaseAuth.instance.currentUser!.email.toString();
      final DocumentSnapshot<Map<String,dynamic>> documentSnapshot = await FirebaseFirestore.instance.doc("$_collectionname/$currentUserMail").collection("groups").doc(groupId).get();
      final Map<String,dynamic>? groupDetails = documentSnapshot.data();
      print("GroupDetails: $groupDetails");
      return groupDetails;
    }
    catch(e){
      print("Error in getting Group Details: ${e.toString()}");
      return null;
    }
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>?> fetchAllUserDetails({required String character}) async{
    try{
      return await FirebaseFirestore.instance.collection(_collectionname).where("userCharacter", isEqualTo:character).snapshots();
    }
    catch(e){
      print("Error in getting user Details : ${e.toString()}");
      return null;
    }
  }

  Future<String?> getProfile({required String email})async{
    try{
      DocumentSnapshot<Map<String, dynamic>> document = await FirebaseFirestore.instance.doc("$_collectionname/$email").get();
      return document.data()!["profile_pic"];
    }
    catch(e){
      print("Error in getting Profile Pic : ${e.toString()}");
      return null;
    }
  }

}