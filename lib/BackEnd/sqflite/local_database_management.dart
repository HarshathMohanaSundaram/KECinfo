import 'dart:io';
import 'package:chat_app/FrontEnd/model/previous_message_group_structure.dart';
import 'package:chat_app/FrontEnd/model/previous_message_user_structure.dart';
import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase{

  final String _importantTableData = "__Important_Table_Data__";
  final String _colUserName = "User_Name";
  final String _colUserMail = "User_EMail";
  final String _colUserToken = "User_Token";
  final String _colProfileImagePath = "Profile_Image_Path";
  final String _colProfileImageUrl = "Profile_Image_Url";
  final String _colDepartment = "Department";
  final String _colAbout = "About";
  final String _colWallPaper = "Chat_Wallpaper";
  final String _colNotification = "Notification_Status";

  final String _colGroupName = "Group_Name";
  final String _importantTableDataGroup = "__Important_Table_Data_Group__";
  final String _colGroupId = "Group_ID";

  final String _colActualMessage = "Message";
  final String _colMessageType = "Message_Type";
  final String _colMessageDate = "Message_Date";
  final String _colMessageTime = "Message_Time";
  final String _colMessageHolder = "Message_Holder";

  static late LocalDatabase _localDatabase = LocalDatabase._createInstance();
  static late Database _database;

   LocalDatabase._createInstance();
   factory LocalDatabase(){
     _localDatabase = LocalDatabase._createInstance();
     return _localDatabase;
   }

   Future<Database> get database async{
     _database = await initializeDatabase();
     return _database;
   }

   Future<Database> initializeDatabase() async{
      final String desirePath = await getDatabasesPath();
      print("Directory Path: $desirePath");

      final Directory newDirectory = await Directory(desirePath+'/.Databases/').create();
      final String path = newDirectory.path+'/kecinfo_local_storage.db';

      final Database getDatabase = await openDatabase(path, version: 1);
      return getDatabase;
   }

   ///Creating Table
   Future<void> createTableToStoreImportantData() async{
      try{
        final Database db = await database;

          await db.execute(
              "CREATE TABLE $_importantTableData($_colUserName TEXT PRIMARY KEY,$_colUserMail TEXT,$_colUserToken TEXT,$_colProfileImagePath TEXT,$_colProfileImageUrl TEXT,$_colAbout TEXT,$_colDepartment TEXT,$_colWallPaper TEXT,$_colNotification TEXT)"
          );
          print("User Table Created");
        }
      catch(e){
        print("Error in Creating Important Table: ${e.toString()}");
      }
  }

  ///Inserting or Updating Table
  Future<bool> insertOrUpdateThisAccountData({
    required String userName,
    required String userMail,
    required String userToken,
    required String userAbout,
    required String userDepartment,
    String chatWallpaper = '',
    String profileImagePath = '',
    String profileImageUrl = '',
    String purpose = 'insert',
  }) async{
     try{
        final Database db =await database;
        if(purpose != 'insert'){
          final int updateResult = await db.rawUpdate(
            "UPDATE $_importantTableData SET $_colUserToken='$userToken', $_colUserMail='$userMail',$_colAbout = '$userAbout WHERE $_colUserName='$userName'"
          );
          print("UpdateResult $updateResult");
          return true;
        }
        else{
          final Map<String,dynamic> _accountData = Map<String,dynamic>();
          _accountData[_colUserName] = userName;
          _accountData[_colUserMail] = userMail;
          _accountData[_colUserToken] = userToken;
          _accountData[_colProfileImagePath] = profileImagePath;
          _accountData[_colProfileImageUrl] = profileImageUrl;
          _accountData[_colAbout] = userAbout;
          _accountData[_colDepartment]=userDepartment;
          _accountData[_colWallPaper] = chatWallpaper;
          _accountData[_colNotification]='1';
          await db.insert(_importantTableData, _accountData);
          return true;
        }
     }
     catch(e){
       print("Error in Inserting or Updating Account Data ${e.toString()}");
       return false;
     }
  }

  Future<bool> checkEveryUserTable({required String userName}) async {
    final Database db = await database;
    List<Map> maps =
    await db.rawQuery('SELECT * FROM sqlite_master ORDER BY name;');
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        try {
          if(userName==maps[i]['name'].toString()){
            print("user table Exists");
            return true;
          }
        } catch (e) {
          print('Exeption : ' + e.toString());
        }
      }
    }
    return false;
   }
   Future<void> createTableForTheUser({required String userName}) async{
     try{
       final Database db = await database;
       await db.execute(
         "CREATE TABLE $userName($_colActualMessage TEXT,$_colMessageType TEXT,$_colMessageHolder TEXT,$_colMessageDate TEXT,$_colMessageTime TEXT)"
       );
       print("$userName Table Created");
     }
     catch(e){
       print("Error in Create Table For Every User: ${e.toString()}");
     }
   }

   Future<String?> getUserNameForParticularUser({required String userMail}) async{
     try{
       final Database db = await this.database;

       List<Map<String,Object?>> result = await db.rawQuery("SELECT $_colUserName FROM $_importantTableData WHERE $_colUserMail =' $userMail'");

       return result[0][_colUserName].toString();
     }
     catch(e){
        return null;
     }
   }

   Future<String?> getParticularDataFromImportantTable(
  {required String userName,
   required GetFieldForImportantDataLocalDatabase getField}
   )async{
     try{
       final Database db = await database;
       final String ? _particularSearchField = _getFieldNameHelpWithEnumerators(getField);
       List<Map<String, Object?>> getResult = await db.rawQuery(
         "SELECT $_particularSearchField FROM $_importantTableData WHERE $_colUserName = '$userName'"
       );
       return getResult[0].values.first.toString();
     }
     catch(e)
     {
       print("Error in Getting Particular Data From Table ${e.toString()}");
     }
   }

   String? _getFieldNameHelpWithEnumerators(GetFieldForImportantDataLocalDatabase getField){
     switch(getField){
       case GetFieldForImportantDataLocalDatabase.UserEmail:
         return _colUserMail;
       case GetFieldForImportantDataLocalDatabase.Token:
         return _colUserToken;
       case GetFieldForImportantDataLocalDatabase.ProfileImagePath:
         return _colProfileImagePath;
       case GetFieldForImportantDataLocalDatabase.ProfileImageUrl:
         return _colProfileImageUrl;
       case GetFieldForImportantDataLocalDatabase.About:
         return _colAbout;
       case GetFieldForImportantDataLocalDatabase.WallPaper:
         return _colWallPaper;
       case GetFieldForImportantDataLocalDatabase.Notification:
         return _colNotification;
       case GetFieldForImportantDataLocalDatabase.Department:
         return _colDepartment;
     }
   }
  Future<void> insertMessageInUserTable(
      {required String userName,
        required String actualMessage,
        required ChatMessageTypes chatMessageTypes,
        required MessageHolderType messageHolderType,
        required String messageDateLocal,
        required String messageTimeLocal}) async {
    try {
      final Database db = await database;

      Map<String, String> tempMap = Map<String, String>();

      tempMap[_colActualMessage] = actualMessage;
      tempMap[_colMessageType] = chatMessageTypes.toString();
      tempMap[_colMessageHolder] = messageHolderType.toString();
      tempMap[_colMessageDate] = messageDateLocal;
      tempMap[_colMessageTime] = messageTimeLocal;

      final int rowAffected = await db.insert(userName, tempMap);
      print('Row Affected: $rowAffected');
    } catch (e) {
      print('Error in Insert Message In User Table: ${e.toString()}');
    }
  }

  Future<void> createTableToStoreImportantDataForGroup() async{
    try{
      final Database db = await database;

      await db.execute(
          "CREATE TABLE $_importantTableDataGroup($_colGroupName TEXT PRIMARY KEY,$_colGroupId TEXT,$_colProfileImagePath TEXT,$_colProfileImageUrl TEXT,$_colWallPaper TEXT,$_colNotification TEXT)"
      );
      print("Group Table Created");
    }
    catch(e){
      print("Error in Creating Important Table: ${e.toString()}");
    }
  }

  Future<bool> insertOrUpdateThisGroupData({
    required String groupName,
    required String groupId,
    String chatWallpaper = '',
    String profileImagePath = '',
    String profileImageUrl = '',
    String purpose = 'insert',
  }) async{
    try{
      final Database db =await database;
      if(purpose != 'insert'){
        final int updateResult = await db.rawUpdate(
            "UPDATE $_importantTableDataGroup SET $_colGroupId='$groupId' WHERE $_colUserName='$groupName'"
        );
        print("UpdateResult $updateResult");
        return true;
      }
      else{
        final Map<String,dynamic> _accountData = Map<String,dynamic>();
        _accountData[_colGroupName] = groupName;
        _accountData[_colGroupId] = groupId;
        _accountData[_colProfileImagePath] = profileImagePath;
        _accountData[_colProfileImageUrl] = profileImageUrl;
        _accountData[_colWallPaper] = chatWallpaper;
        _accountData[_colNotification]='1';
        await db.insert(_importantTableDataGroup, _accountData);
        return true;
      }
    }
    catch(e){
      print("Error in Inserting or Updating Account Data ${e.toString()}");
      return false;
    }
  }

  Future<void> createTableForTheGroupMessage({required String groupName}) async{
    try{
      final Database db = await database;
      await db.execute(
          "CREATE TABLE $groupName($_colActualMessage TEXT,$_colMessageType TEXT,$_colMessageHolder TEXT,$_colMessageDate TEXT,$_colMessageTime TEXT)"
      );
      print("$groupName Table Created");
    }
    catch(e){
      print("Error in Create Table For Every User: ${e.toString()}");
    }
  }

  Future<void> insertMessageInGroupTable(
      { required String groupName,
        required String actualMessage,
        required ChatMessageTypes chatMessageTypes,
        required String messageHolderName,
        required String messageDateLocal,
        required String messageTimeLocal}) async {
    try {
      final Database db = await database;

      Map<String, String> tempMap = Map<String, String>();

      tempMap[_colActualMessage] = actualMessage;
      tempMap[_colMessageType] = chatMessageTypes.toString();
      tempMap[_colMessageHolder] = messageHolderName.toString();
      tempMap[_colMessageDate] = messageDateLocal;
      tempMap[_colMessageTime] = messageTimeLocal;

      final int rowAffected = await db.insert(groupName, tempMap);
      print('Row Affected: $rowAffected');
    } catch (e) {
      print('Error in Insert Message In User Table: ${e.toString()}');
    }
  }

  Future<List<PreviousMessageGroupStructure>> getAllPreviousGroupMessages({required String groupName}) async{
    try{
      final Database db =  await database;
      final result = await db.rawQuery("SELECT * FROM $groupName");

      print(result);
      List<PreviousMessageGroupStructure> takePreviousMessage = [];
      for(int i=0;i<result.length;i++){
        Map<String,dynamic> tempMap = result[i];
        takePreviousMessage.add(PreviousMessageGroupStructure.toJson(tempMap));
      }
      return takePreviousMessage;
    }
    catch(e){
        print("Error is: ${e.toString()}");
        return [];
    }
  }

  Future<List<PreviousMessageUserStructure>> getAllPreviousUserMessages({required String userName}) async{
     try{
       final Database db = await database;

       final result= await db.rawQuery("SELECT * FROM $userName");

       print(result);
       List<PreviousMessageUserStructure> takePreviousMessage =[];
       for(int i=0;i<result.length;i++){
         Map<String,dynamic> tempMap = result[i];
         takePreviousMessage.add(PreviousMessageUserStructure.toJson(tempMap));
       }
        return takePreviousMessage;
     }
     catch(e){
       print("Error is: ${e.toString()}");
       return [];
     }
  }

  Future<int> _countTotalMessagesUnderATable(String _tableName) async {
    final Database db = await database;

    final List<Map<String, Object?>> countTotalMessagesWithOneAdditionalData =
    await db.rawQuery("""SELECT COUNT(*) FROM $_tableName""");

    return int.parse(
        countTotalMessagesWithOneAdditionalData[0].values.first.toString());
  }

  Future<Map<String, dynamic>?> fetchLatestUserMessage(String _tableName) async {
    final Database db = await database;

    final int totalMessages = await _countTotalMessagesUnderATable(_tableName);

    if (totalMessages == 0) return null;

    final List<Map<String, Object?>>? result = await db.rawQuery(
        """SELECT $_colActualMessage, $_colMessageType, $_colMessageTime, $_colMessageDate FROM $_tableName LIMIT 1 OFFSET ${totalMessages - 1}""");

    print("Result is: $result");
    final Map<String, dynamic> map = Map<String, dynamic>();

    if (result != null && result.length > 0) {
      final String _time = result[0][_colMessageTime].toString();

      print("Now: $_time");

      map.addAll({
        result[0][_colMessageType].toString():{
          result[0][_colActualMessage].toString():_time.toString()
        }
      });
    }
    else{
      return null;
    }

    print("Map is: $map");

    return map;
  }

}