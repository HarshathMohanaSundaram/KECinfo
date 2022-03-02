import 'dart:io';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/BackEnd/sqflite/local_database_management.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:chat_app/FrontEnd/model/previous_message_user_structure.dart';
import 'package:chat_app/Global_Uses/show_toast_messages.dart';
import 'package:chat_app/FrontEnd/Preview/image_preview_screen.dart';
import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:animations/animations.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class PrincipalScreen extends StatefulWidget {
  @override
  _PrincipalScreenState createState() => _PrincipalScreenState();
}

class _PrincipalScreenState extends State<PrincipalScreen> {
  bool _isLoading = false;
  final String _message = "Message";
  final String _time = "MessageTime";
  final String _date = "MessageDate";
  final FToast _fToast = FToast();
  final Dio dio = Dio();
  String profile = "https://firebasestorage.googleapis.com/v0/b/chatapp-2417b.appspot.com/o/KecProfile%2Fklogo.png?alt=media&token=a8c112c6-ce55-40cd-8a80-c7bccbb0e416";
  LocalDatabase _localDatabase = LocalDatabase();
  List<Map<String, String>>_allConversationMessages = [ ];
  List<bool>_conversationMessageHolder = [];
  List<ChatMessageTypes>_chatMessageCategoryHolder = [];
  final AudioPlayer _justAudioPlayer = AudioPlayer();
  double _audioDownloadProgress = 0;
  late double _curAudioPlayingTime;
  int _lastAudioPlayingIndex = 0;
  double _audioPlaySpeed = 1.0;
  String _totalDuration = '0:00';
  String _loadingTime = "0:00";
  double _chatBoxHeight = 0.0;
  final userName = "PRINCIPAL";
  final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
  IconData _iconData = Icons.play_arrow_rounded;
  final Record _record = Record();
  late Directory _audioDirectory;

  _takePermissionForStorage() async {
    var status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      showToast(
          "Thanks For Storage Permission", _fToast, toastColor: Colors.white,bgColor: Colors.black, fontSize: 16.0);
      _makeDirectoryForRecordings();
    } else {
      showToast("Some Problem arrive", _fToast, toastColor: Colors.red,
          fontSize: 16.0);
    }
  }

  _makeDirectoryForRecordings() async {
    final Directory? directory = await getExternalStorageDirectory();
    _audioDirectory =
    await Directory(directory!.path + '/Recordings/').create();
  }

  _createTableForPrincipal() async{
    final String? pro = await _cloudStoreDataManagement.getProfile(email: "principal@kongu.edu");
    if(pro != null){
      if(mounted){
        setState(() {
          profile = pro;
        });
      }
    }
    await _localDatabase.createTableForTheUser(userName: userName);
  }
  Future<void> _fetchIncomingMessages() async {
    final Stream<DocumentSnapshot<Map<String, dynamic>>>? realTimeSnapshot =
    await _cloudStoreDataManagement.fetchRealTimeMessages();
    realTimeSnapshot!.listen((documentSnapshot) async {
      await _checkingForIncomingMessages(documentSnapshot.data());
    });
  }

  Future<void> _checkingForIncomingMessages(Map<String, dynamic>? documentSnapshot) async{
    final List<dynamic> _MessagesList = documentSnapshot!["principalMessages"];
    if(_MessagesList != null){
      await _cloudStoreDataManagement.removePrincipalMessages(userEmail:FirebaseAuth.instance.currentUser!.email.toString());
      _MessagesList.forEach((everyMessage) {
        if(everyMessage.keys.first.toString() == ChatMessageTypes.Text.toString()){
          Future.microtask(() => _manageIncomingTextMessages(everyMessage.values.first));
        }
        else if(everyMessage.keys.first.toString() == ChatMessageTypes.Audio.toString()){
          Future.microtask(() => _manageIncomingMediaMessages(everyMessage.values.first,ChatMessageTypes.Audio));
        }
        else if(everyMessage.keys.first.toString() == ChatMessageTypes.Image.toString()){
          Future.microtask(() => _manageIncomingMediaMessages(everyMessage.values.first,ChatMessageTypes.Image));
        }
        else if(everyMessage.keys.first.toString() == ChatMessageTypes.Video.toString()){
          Future.microtask(() => _manageIncomingMediaMessages(everyMessage.values, ChatMessageTypes.Video));
        }
        else if(everyMessage.keys.first.toString() == ChatMessageTypes.Document.toString()){
          Future.microtask(() => _manageIncomingMediaMessages(everyMessage.values.first, ChatMessageTypes.Document));
        }
      });
    }
    print("Get Incoming Messages: $_MessagesList");
  }

  _manageIncomingTextMessages(var textMessage)async {
    await _localDatabase.insertMessageInUserTable(
        userName: userName,
        actualMessage: textMessage[_message].toString(),
        chatMessageTypes: ChatMessageTypes.Text,
        messageHolderType: MessageHolderType.User,
        messageDateLocal: textMessage[_date],
        messageTimeLocal: textMessage[_time]);
    if(mounted){
      setState(() {
        _allConversationMessages.add({
          _message:textMessage[_message].toString(),
          _time:textMessage[_time].toString(),
          _date:textMessage[_date].toString()
        });
        _chatMessageCategoryHolder.add(ChatMessageTypes.Text);
        _conversationMessageHolder.add(true);
      });
    }
  }

  _manageIncomingMediaMessages(var mediaMessage,ChatMessageTypes chatMessageType) async{

    String refName = "";
    String extension = "";
    late String thumbnailFileRemotePath;
    String videoThumbnailLocalPath="";

    String actualFileRemotePath = chatMessageType == ChatMessageTypes.Video || chatMessageType == ChatMessageTypes.Document
        ?mediaMessage[_message].toString().split("+")[0]
        : mediaMessage[_message].toString();

    if(chatMessageType == ChatMessageTypes.Image){
      refName = "/Images/";
      extension = ".png";
    }
    else if(chatMessageType == ChatMessageTypes.Video){
      refName = "/Videos/";
      extension = ".mp4";
      thumbnailFileRemotePath=
      mediaMessage[_message].toString().split("+")[1];
    }
    else if(chatMessageType == ChatMessageTypes.Document){
      refName = "/Documents";
      extension=mediaMessage[_message].toString().split("+")[1];
    }
    else if(chatMessageType == ChatMessageTypes.Audio){
      refName = "/Audio/";
      extension =".mp3";
    }

    if(mounted){
      setState(() {
        _isLoading=true;
      });
    }

    final Directory? directory = await getExternalStorageDirectory();
    print("Directory Path: ${directory!.path}");

    final storageDirectory = await Directory(directory.path + refName).create();

    final String mediaFileLocalPath =
        "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}$extension";

    if(chatMessageType == ChatMessageTypes.Video){
      final storageDirectory = await Directory(directory.path+"/.Thumbnails/").create();

      videoThumbnailLocalPath =
      "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}.png";
    }
    try{
      print("Media File Saved Path: $mediaFileLocalPath");

      await dio
          .download(actualFileRemotePath, mediaFileLocalPath)
          .whenComplete(() async{
        if(chatMessageType == ChatMessageTypes.Video){
          await dio
              .download(thumbnailFileRemotePath, videoThumbnailLocalPath)
              .whenComplete(()async{
            await _storeAndShowIncomingMessageData(
                mediaFileLocalPath:
                "$videoThumbnailLocalPath+$mediaFileLocalPath",
                chatMessageType:chatMessageType,
                mediaMessage:mediaMessage
            );
          });
        }
        else{
          await _storeAndShowIncomingMessageData(
              mediaFileLocalPath:mediaFileLocalPath,
              chatMessageType:chatMessageType,
              mediaMessage:mediaMessage
          );
        }
      });
    }
    catch(e){
      print("Error in Media Downloading: ${e.toString()}");
    }
  }
  Future<void>_storeAndShowIncomingMessageData(
      {required String mediaFileLocalPath,
        required ChatMessageTypes chatMessageType,
        required mediaMessage,
      }) async{
    try{

      await _localDatabase.insertMessageInUserTable(
          userName: userName,
          actualMessage: mediaFileLocalPath,
          chatMessageTypes: chatMessageType,
          messageHolderType: MessageHolderType.User,
          messageDateLocal: mediaMessage[_date].toString(),
          messageTimeLocal: mediaMessage[_time].toString());

      if(mounted){
        setState(() {
          _allConversationMessages.add({
            _message: mediaFileLocalPath,
            _time:mediaMessage[_time].toString(),
            _date:mediaMessage[_date]
          });
          _chatMessageCategoryHolder.add(chatMessageType);
          _conversationMessageHolder.add(true);

        });
      }
    }
    catch(e){
      print("Error in Store and show Incoming Messages ${e.toString()}");
    }
    finally{
      if(mounted){
        setState(() {
          _isLoading=false;
        });
      }
    }
  }

  _loadPreviousStoredUserMessages() async{
    try{
      List<PreviousMessageUserStructure> _storedPreviousMessages = await _localDatabase.getAllPreviousUserMessages(userName: userName);

      for(int i=0;i<_storedPreviousMessages.length;i++){
        final PreviousMessageUserStructure _previousMessage = _storedPreviousMessages[i];

        if(mounted){
          setState(() {
            _allConversationMessages.add({
              _message:_previousMessage.actualMessage,
              _time:_previousMessage.messageTime,
              _date:_previousMessage.messageDate
            });
            _chatMessageCategoryHolder.add(_previousMessage.messageType);
            _conversationMessageHolder.add(_previousMessage.messageHolder);
          });
        }

      }
    }
    catch(e){
      print("Previous Message Fetching Error in ChatScreen: ${e.toString()}");
    }
    finally{
      await _fetchIncomingMessages();
    }
  }

  @override
  void initState() {
    _fToast.init(context);
    _takePermissionForStorage();
    _loadPreviousStoredUserMessages();
    _createTableForPrincipal();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Messages: ${_allConversationMessages}");
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: LoadingOverlay(
            isLoading: _isLoading,
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                    width: double.maxFinite,
                    height: MediaQuery
                        .of(context)
                        .size
                        .height,
                    //color: Colors.amber,
                    child:(_allConversationMessages.isNotEmpty)? ListView.builder(
                          itemCount: _allConversationMessages.length,
                          itemBuilder: (context, int index) {
                            if (_chatMessageCategoryHolder[index] ==
                                ChatMessageTypes.Text)
                              return principalChat(time: _allConversationMessages[index][_time].toString(), date:_allConversationMessages[index][_date].toString(), chatMessageTypes: ChatMessageTypes.Text, index: index);
                            else if (_chatMessageCategoryHolder[index] ==
                                ChatMessageTypes.Image)
                              return principalChat(time: _allConversationMessages[index][_time].toString(), date: _allConversationMessages[index][_date].toString(), chatMessageTypes: ChatMessageTypes.Image, index: index);
                            else if (_chatMessageCategoryHolder[index] ==
                                ChatMessageTypes.Video)
                              return principalChat(time: _allConversationMessages[index][_time].toString(), date:_allConversationMessages[index][_date].toString(), chatMessageTypes: ChatMessageTypes.Video, index: index);
                            else if (_chatMessageCategoryHolder[index] ==
                                ChatMessageTypes.Document)
                              return principalChat(time: _allConversationMessages[index][_time].toString(), date:_allConversationMessages[index][_date].toString(), chatMessageTypes: ChatMessageTypes.Document, index: index);
                            else if (_chatMessageCategoryHolder[index] ==
                                ChatMessageTypes.Audio)
                              return principalChat(time: _allConversationMessages[index][_time].toString(), date: _allConversationMessages[index][_date].toString(), chatMessageTypes: ChatMessageTypes.Audio, index: index);
                            return Center();
                          }
                      )
                      : const Center(
                        child: Text(
                          "Principal Appears Here",
                          style: TextStyle(
                            fontFamily: "MyRaidBold",
                            color: lightBlue,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
              ],
            ),
          ),
        )
    );
  }

  void openFileResultStatus({required OpenResult openResult}) {
    if (openResult.type == ResultType.permissionDenied)
      showToast(
          "Permission Denied To Open File", _fToast, toastColor: Colors.red,
          fontSize: 16.0);
    else if (openResult.type == ResultType.noAppToOpen)
      showToast("No App Found to Open", _fToast, toastColor: Colors.amber,
          fontSize: 16.0);
    else if (openResult.type == ResultType.error)
      showToast("Error in Opening File", _fToast, toastColor: Colors.red,
          fontSize: 16.0);
    else if (openResult.type == ResultType.fileNotFound)
      showToast("Sorry File Not Found", _fToast, toastColor: Colors.red,
          fontSize: 16.0);
  }

  _chatMicrophoneOnTapAction(int index) async {
    try {
      _justAudioPlayer.positionStream.listen((event) {
        if (mounted) {
          setState(() {
            _curAudioPlayingTime = event.inMicroseconds.ceilToDouble();
            _loadingTime = '${event.inMinutes}:${event.inSeconds > 59
                ? event.inSeconds % 60
                : event.inSeconds}';
          });
        }
      });

      _justAudioPlayer.playerStateStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          _justAudioPlayer.stop();
          if (mounted) {
            setState(() {
              _loadingTime = '0:00';
              _iconData = Icons.play_arrow_rounded;
            });
          }
        }
      });

      if (_lastAudioPlayingIndex != index) {
        await _justAudioPlayer.setFilePath(
            _allConversationMessages[index][_message].toString());

        if (mounted) {
          setState(() {
            _lastAudioPlayingIndex = index;
            _totalDuration =
            "${_justAudioPlayer.duration!.inMinutes} : ${_justAudioPlayer
                .duration!.inSeconds > 59 ? _justAudioPlayer.duration!
                .inSeconds % 60 : _justAudioPlayer.duration!.inSeconds}";
            _iconData = Icons.pause;
            _audioPlaySpeed = 1.0;
            _justAudioPlayer.setSpeed(_audioPlaySpeed);
          });
        }
        await _justAudioPlayer.play();
      }
      else {
        print(_justAudioPlayer.processingState);
        if (_justAudioPlayer.processingState == ProcessingState.idle) {
          await _justAudioPlayer.setFilePath(
              _allConversationMessages[index][_message].toString());
          if (mounted) {
            setState(() {
              _lastAudioPlayingIndex = index;
              _totalDuration =
              "${_justAudioPlayer.duration!.inMinutes} : ${_justAudioPlayer
                  .duration!.inSeconds}";
              _iconData = Icons.pause;
            });
          }

          await _justAudioPlayer.play();
        }
        else if (_justAudioPlayer.playing) {
          if (mounted) {
            setState(() {
              _iconData = Icons.play_arrow_rounded;
            });
          }
          await _justAudioPlayer.pause();
        }
        else if (_justAudioPlayer.processingState == ProcessingState.ready) {
          if (mounted) {
            setState(() {
              _iconData = Icons.pause;
            });
          }
          await _justAudioPlayer.play();
        }
        else
        if (_justAudioPlayer.processingState == ProcessingState.completed) {}
      }
    }
    catch (e) {
      print("Audio Playing Error");
      showToast("May Be Audio File Not Found", _fToast);
    }
  }

  _chatMicrophoneOnLongPressAction() async {
    if (_justAudioPlayer.playing) {
      await _justAudioPlayer.stop();
      if (mounted) {
        setState(() {
          print("Audio Play Completed");
          _justAudioPlayer.stop();
          if (mounted) {
            setState(() {
              _loadingTime = '0:00';
              _iconData = Icons.play_arrow_rounded;
              _lastAudioPlayingIndex = -1;
            });
          }
        });
      }
    }
  }

  Widget principalChat({required String time, required String date,required ChatMessageTypes chatMessageTypes, required int index}){
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Container(
        decoration: const BoxDecoration(
            color: fadedWhite,
            borderRadius: BorderRadius.all(Radius.circular(30))),
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  child: FittedBox(
                      fit: BoxFit.cover,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(0)),
                        child:Image(
                          image: NetworkImage(profile),
                        ),
                      )),
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Principal',
                        style: TextStyle(
                            color: royalPurple,
                            fontFamily: 'MyRaidBold',
                            fontSize: 16),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        date + '  |  ' + time+ ' || '+chatMessageTypes.toString().split(".").last ,
                        style: const TextStyle(
                            color: fadedPurple,
                            fontFamily: 'MyRaid',
                            fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),
            if (chatMessageTypes == ChatMessageTypes.Text)
              Row(
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _allConversationMessages[index][_message].toString(),
                        style: const TextStyle(
                            fontFamily: 'MyRaid',
                            color: fadedPurple,
                            fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            if (chatMessageTypes == ChatMessageTypes.Image)
              LayoutBuilder(
                  builder: (context, constraints) => Container(
                    height: 100,
                    width: constraints.maxWidth,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(50),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(50))),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child:GestureDetector(
                        onTap: (){
                          Navigator.push(context,MaterialPageRoute(builder: (_) => ImageViewScreen(
                              imagePath: _allConversationMessages[index][_message].toString(),
                              imageProviderCategory: ImageProviderCategory.FileImage)));
                        },
                        child: Image(image: FileImage(File(_allConversationMessages[index][_message].toString()))),
                      ),
                    ),
                  )),
            if(chatMessageTypes == ChatMessageTypes.Video)
              LayoutBuilder(
                  builder: (context, constraints) => Container(
                    height: 100,
                    width: constraints.maxWidth,
                    clipBehavior: Clip.hardEdge,
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(50),
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(50))),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: GestureDetector(
                          onTap: ()async{
                            final OpenResult openResult = await OpenFile.open(_allConversationMessages[index][_message].toString().split("+")[1]);
                            openFileResultStatus(openResult: openResult);
                          },
                          child: Image(
                              image:FileImage(
                                  File(_allConversationMessages[index][_message].toString().split("+")[0])))),
                    ),
                  )),
            if(chatMessageTypes == ChatMessageTypes.Audio)
              LayoutBuilder(
                  builder: (context, constraints) => Container(
                      width: constraints.maxWidth,
                      height: 50,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.transparent,
                        border: Border.fromBorderSide(
                            BorderSide(color: fadedPurple, width: 0.5)),
                      ),
                      child:Row(
                        children: [
                          SizedBox(
                            width: 20.0,
                          ),
                          GestureDetector(
                            onLongPress: () => _chatMicrophoneOnLongPressAction(),
                            onTap: () => _chatMicrophoneOnTapAction(index),
                            child: Icon(
                              _lastAudioPlayingIndex == index
                                  ? _iconData
                                  : Icons.play_arrow_rounded,
                              color: Color.fromRGBO(255, 255, 255, 1.0),
                              size: 35.0,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(top: 26.0),
                                    child: LinearPercentIndicator(
                                      percent: _justAudioPlayer.duration == null
                                          ? 0.0
                                          : _lastAudioPlayingIndex == index
                                          ? _curAudioPlayingTime /
                                          _justAudioPlayer
                                              .duration!.inMicroseconds
                                              .ceil() >= 1.0
                                          ? 1.0
                                          : _curAudioPlayingTime /
                                          _justAudioPlayer
                                              .duration!.inMicroseconds
                                              .ceil()
                                          : 0,
                                      backgroundColor: Colors.black26,
                                      progressColor: Colors.white,
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0, right: 7.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              _lastAudioPlayingIndex == index
                                                  ? _loadingTime
                                                  : '0:00',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                              _lastAudioPlayingIndex == index
                                                  ? _totalDuration
                                                  : '',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: GestureDetector(
                              child:Text(
                                '${_audioPlaySpeed.toString().contains('.0')
                                    ? _audioPlaySpeed.toString().split('.')[0]
                                    : _audioPlaySpeed}x',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18.0),
                              ),
                              onTap: () {
                                print('Audio Play Speed Tapped');
                                if (mounted) {
                                  setState(() {
                                    if (_audioPlaySpeed != 2.0)
                                      _audioPlaySpeed += 0.5;
                                    else
                                      _audioPlaySpeed = 0.5;

                                    _justAudioPlayer.setSpeed(_audioPlaySpeed);
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      )
                  )
              ),
            if (chatMessageTypes == ChatMessageTypes.Document)
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                      width: constraints.maxWidth,
                      height: 50,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: Colors.transparent,
                        border: Border.fromBorderSide(
                            BorderSide(color: fadedPurple, width: 0.5)),
                      ),
                      child: GestureDetector(
                        onTap: ()async{
                          final OpenResult openResult = await OpenFile.open(
                              _allConversationMessages[index][_message]!
                          );
                          openFileResultStatus(openResult: openResult);
                        },
                        child: Row(
                          children: [
                            Container(
                              height: constraints.maxHeight,
                              padding: const EdgeInsets.all(10),
                              color: fadedPurple,
                              child: const Icon(
                                MdiIcons.fileDocumentOutline,
                                color: Colors.white,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                      child:FittedBox(
                                        child: Text(_allConversationMessages[index][_message].toString().split("/").last.split(".").first,
                                            style: TextStyle(
                                                color: fadedPurple,
                                                overflow: TextOverflow.ellipsis,
                                                fontFamily: 'MyRaidBold',
                                                fontSize: 14)),
                                      )),
                                ),
                              ),
                            ),
                            Container(
                                height: constraints.maxHeight,
                                color: fadedPurple,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: FittedBox(
                                      child: Text(_allConversationMessages[index][_message].toString().split("/").last.split(".").last,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'MyRaid',
                                              fontSize: 14)),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                      ));
                },
              )
          ],
        ),
      ),
    );
  }
}
