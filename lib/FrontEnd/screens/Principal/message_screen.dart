import 'dart:io';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/BackEnd/sqflite/local_database_management.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:chat_app/FrontEnd/model/previous_message_user_structure.dart';
import 'package:chat_app/Global_Uses/show_toast_messages.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_app/FrontEnd/Preview/image_preview_screen.dart';
import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:animations/animations.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:circle_list/circle_list.dart';
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';


class PrincipalMessageScreen extends StatefulWidget {
   @override
   _PrincipalMessageScreenState createState() => _PrincipalMessageScreenState();
}

class _PrincipalMessageScreenState extends State<PrincipalMessageScreen> {
  bool _isLoading = false;
  bool _writeTextPresent = false;
  final FToast _fToast = FToast();
  final Dio dio = Dio();
  final userName="PRINCIPAL";
  final String _message = "Message";
  final String _time = "MessageTime";
  final String _date = "MessageDate";
  String profile = "https://firebasestorage.googleapis.com/v0/b/chatapp-2417b.appspot.com/o/KecProfile%2Fklogo.png?alt=media&token=a8c112c6-ce55-40cd-8a80-c7bccbb0e416";
  CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
  LocalDatabase _localDatabase = LocalDatabase();
  List<Map<String,String>>_allConversationMessages = [];
  List<bool>_conversationMessageHolder = [];
  List<ChatMessageTypes>_chatMessageCategoryHolder = [];
  TextEditingController _typeText = TextEditingController();
  final AudioPlayer _justAudioPlayer = AudioPlayer();
  double _audioDownloadProgress = 0;
  late double _curAudioPlayingTime;
  int _lastAudioPlayingIndex = 0;
  double _audioPlaySpeed = 1.0;
  String _totalDuration = '0:00';
  String _loadingTime = "0:00";
  double _chatBoxHeight = 0.0;
  IconData _iconData = Icons.play_arrow_rounded;
  final Record _record = Record();
  String _hintText = "Type a Message...";
  late Directory _audioDirectory;
  _takePermissionForStorage() async{
    var status = await Permission.storage.request();
    if(status == PermissionStatus.granted){
      showToast("Thanks For Storage Permission", _fToast, toastColor: Colors.white, fontSize: 16.0);
      _makeDirectoryForRecordings();
    } else {
      showToast("Some Problem arrive", _fToast, toastColor: Colors.red,
          fontSize: 16.0);
    }
  }
  _makeDirectoryForRecordings() async{
    final Directory? directory =await getExternalStorageDirectory();
    _audioDirectory = await Directory(directory!.path+'/Recordings/').create();
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

  _loadPreviousStoredUserMessages() async {
    try {
      List<
          PreviousMessageUserStructure> _storedPreviousMessages = await _localDatabase
          .getAllPreviousUserMessages(userName: userName);

      for (int i = 0; i < _storedPreviousMessages.length; i++) {
        final PreviousMessageUserStructure _previousMessage = _storedPreviousMessages[i];

        if (mounted) {
          setState(() {
            _allConversationMessages.add({
              _message:_previousMessage.actualMessage,
              _time:_previousMessage.messageTime,
              _date:_previousMessage.messageDate,
            });
            _chatMessageCategoryHolder.add(_previousMessage.messageType);
            _conversationMessageHolder.add(_previousMessage.messageHolder);
          });
        }
      }
    }
    catch (e) {
      print("Previous Message Fetching Error in ChatScreen: ${e.toString()}");
    }
  }

  @override
  void initState() {
    _fToast.init(context);
    _takePermissionForStorage();
    _createTableForPrincipal();
    _loadPreviousStoredUserMessages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      topRight: Radius.circular(30.0),
                    )
                ),
                child: LoadingOverlay(
                  isLoading: _isLoading,
                  child: ListView.builder(
                      itemCount: _allConversationMessages.length,
                      itemBuilder: (context, int index){
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
                  ),
                )
            ),
          ),
          _messageTyper(context)
        ],
      ),
    );
  }

  Widget _messageTyper(BuildContext context){
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 100,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50), topRight: Radius.circular(50)),
          color: royalBlue),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(10),
                child: Transform.rotate(
                    angle: 10,
                    child: Container(
                        color: Colors.transparent,
                        child: IconButton(
                            onPressed: _differentChatOptions,
                            padding: EdgeInsets.zero,
                            constraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                            icon: const Icon(
                              MdiIcons.paperclip,
                              color: Colors.white,
                              size: 28,
                            ))))),
            Expanded(
              child: Container(
                color: Colors.transparent,
                child: TextFormField(
                  controller:_typeText,
                  cursorColor: Colors.white,
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'MyRaid',
                      letterSpacing: .5),
                  minLines: 1,
                  maxLines: 10,
                  maxLength: 1000,
                  onChanged: (writeText){
                    bool _isEmpty = false;
                    writeText.isEmpty? _isEmpty = true : _isEmpty = false;
                    if(mounted)
                    {
                      setState(() {
                        _writeTextPresent = !_isEmpty;
                      });
                    }
                  },
                  decoration:InputDecoration(
                      helperStyle:
                      TextStyle(color: Colors.white, fontFamily: 'MyRaid'),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      hintText: _hintText,
                      hintStyle:
                      TextStyle(fontFamily: 'MyRaid', color: Colors.white)),
                ),
              ),
            ),
            Container(
                color: Colors.transparent,
                padding: const EdgeInsets.all(10),
                child: Container(
                    color: Colors.transparent,
                    child: IconButton(
                        onPressed: () {
                          _writeTextPresent?_sendText() : _voiceTake();
                        },
                        padding: EdgeInsets.zero,
                        constraints:
                        const BoxConstraints(minWidth: 0, minHeight: 0),
                        icon: Icon(
                          _writeTextPresent?MdiIcons.send:MdiIcons.microphone,
                          color: Colors.white,
                          size: 28,
                        )))),
          ],
        ),
      ),
    );
  }
  void _sendText() async{
    if(_writeTextPresent){
      if(mounted){
        setState(() {
          _isLoading=true;
        });
      }
    }
    final String _messageTime =
        "${DateTime.now().hour}:${DateTime.now().minute}";
    final String _messageDate = "${DateTime.now().toString().split(" ")[0].toString()}";
    await _cloudStoreDataManagement.principalMessageToUser(
        sendMessageData: {
          ChatMessageTypes.Text.toString():{
            _message:_typeText.text,
            _time: _messageTime,
            _date:_messageDate
          }
        },
      chatMessageTypes: ChatMessageTypes.Text
    );

    if(mounted){
      setState(() {
        _allConversationMessages.add({
          _message:_typeText.text,
          _time: _messageTime,
          _date:_messageDate,
        });
        _conversationMessageHolder.add(false);
        _chatMessageCategoryHolder.add(ChatMessageTypes.Text);
      });
    }

    await _localDatabase.insertMessageInUserTable(
        userName: userName,
        actualMessage: _typeText.text,
        chatMessageTypes: ChatMessageTypes.Text,
        messageHolderType: MessageHolderType.Me,
        messageDateLocal: _messageDate,
        messageTimeLocal: _messageTime);
    if(mounted){
      setState(() {
        _typeText.clear();
        _isLoading = false;
      });
    }
  }
  void _voiceTake() async{
    if(!await Permission.microphone.status.isGranted){
      final microphoneStatus = await Permission.microphone.request();
      if(microphoneStatus != PermissionStatus.granted){
        showToast("Microphone Permission is Required to Record Voice",_fToast);
      }
    }
    else{
      if(await _record.isRecording()){
        if(mounted){
          setState(() {
            _hintText="Type a Message...";
          });
        }
        final String? recordedFilePath = await _record.stop();
        _voiceSend(recordedFilePath.toString());
      }
      else{
        if(mounted){
          setState(() {
            _hintText="Recording...";
          });
        }
        await _record
            .start(
          path: '${_audioDirectory.path}${DateTime.now()}.mp3',
        )
            .then((value) => print("Recording"));
      }
    }
  }

  _differentChatOptions() {
    showDialog(context: context, builder:(_) => AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40.0)
      ),
      elevation: 0.3,
      backgroundColor: Colors.white,
      content:SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height / 2.7,
        child: Center(
          child: CircleList(
            initialAngle: 55,
            outerRadius: MediaQuery.of(context).size.width / 3.2,
            innerRadius: MediaQuery.of(context).size.width / 10,
            showInitialAnimation: true,
            innerCircleColor: Colors.white70,
            outerCircleColor: Colors.black12,
            origin: Offset(0, 0),
            rotateMode: RotateMode.allRotate,
            centerWidget: const Center(
                child: Image(
                  color: royalBlue,
                  image: AssetImage('assets/images/logo_white.png'),
                  fit: BoxFit.cover,
                )
            ),
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),),
                child: GestureDetector(
                  child: const FittedBox(
                    fit: BoxFit.cover,
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: lightBlue,
                    ),
                  ),
                  onTap: () async {
                    final _pickedImage = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
                    if(_pickedImage !=null ){
                      _addSelectedMediaToChat(_pickedImage.path);
                    }
                  },
                  onLongPress: () async{
                    final XFile? _pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
                    if(_pickedImage !=null ){
                      _addSelectedMediaToChat(_pickedImage.path);
                    }
                  },
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    ),
                child: GestureDetector(
                  onTap: () async {
                      if(mounted){
                        setState(() {
                          _isLoading = true;
                        });
                      }

                      final _pickVideo = await ImagePicker().pickVideo(
                          source: ImageSource.camera,
                          maxDuration: Duration(seconds: 30));
                      if(_pickVideo != null){
                        final String? _path = await VideoThumbnail.thumbnailFile(
                          video: _pickVideo.path,
                          thumbnailPath: (await getTemporaryDirectory()).path, /// path_provider
                          imageFormat: ImageFormat.JPEG,
                          quality: 100,
                        );
                        File thumbnailfile = File(_path!);

                        _addSelectedMediaToChat(
                          _pickVideo.path,
                          chatMessageTypeTake: ChatMessageTypes.Video,
                          thumbnailPath: thumbnailfile.path,
                        );
                      }
                      if(mounted){
                        setState(() {
                          _isLoading=false;
                        });
                      }
                  },
                  onLongPress: () async {
                    if(mounted){
                      setState(() {
                        _isLoading = true;
                      });
                    }

                    final _pickVideo = await ImagePicker().pickVideo(
                        source: ImageSource.gallery,
                        maxDuration: Duration(seconds: 30));
                    if(_pickVideo != null){
                      final String? _path = await VideoThumbnail.thumbnailFile(
                        video: _pickVideo.path,
                        thumbnailPath: (await getTemporaryDirectory()).path, /// path_provider
                        imageFormat: ImageFormat.JPEG,
                        quality: 100,
                      );
                      File thumbnailfile = File(_path!);

                      _addSelectedMediaToChat(
                        _pickVideo.path,
                        chatMessageTypeTake: ChatMessageTypes.Video,
                        thumbnailPath: thumbnailfile.path,
                      );
                    }
                    if(mounted){
                      setState(() {
                        _isLoading=false;
                      });
                    }
                  },
                  child:const FittedBox(
                    fit:BoxFit.cover,
                    child: Icon(
                      Icons.video_collection,
                      color: lightBlue,
                    ),
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    ),
                child: GestureDetector(
                  onTap: () async {
                    await _pickFileStorage();
                  },
                  child:const FittedBox(
                    fit: BoxFit.cover,
                    child: Icon(
                      Entypo.documents,
                      color: lightBlue,
                    ),
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                ),
                child: GestureDetector(
                    child:const FittedBox(
                      fit:BoxFit.cover,
                      child: Icon(
                        Icons.music_note_rounded,
                        color: lightBlue,
                      ),
                    ),
                    onTap: () async {
                      final List<String> _allowedExtensions = [
                        'mp3',
                        'mp4',
                        'm4a',
                        'wav',
                        'ogg'
                      ];
                      final FilePickerResult? _audioFilePickerResult =
                      await FilePicker.platform.pickFiles(
                          type: FileType.audio
                      );
                      Navigator.pop(context);

                      if(_audioFilePickerResult != null){
                        _audioFilePickerResult.files.forEach((element) {
                          print('Name:${element.path}');
                          print('Extension:${element.extension}');
                          if(_allowedExtensions.contains(element.extension)){
                            _voiceSend(element.path.toString(), audioExtension: '.${element.extension}');
                          }
                        });
                      }
                    }
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _textConversationMessage(BuildContext context,int index) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            margin: (_conversationMessageHolder[index])
                ?EdgeInsets.only(
                right: MediaQuery.of(context).size.width/3,
                left: 5.0,
                top:15.0
            )
                : EdgeInsets.only(
                left: MediaQuery.of(context).size.height/3,
                right: 5.0,
                top:10.0
            ),
            alignment: (_conversationMessageHolder[index])
                ?Alignment.centerLeft
                :Alignment.centerRight,
            child: Column(
              children: [
                ElevatedButton(
                  style:ElevatedButton.styleFrom(
                      primary: _conversationMessageHolder[index]
                          ?lightBlue
                          :fadedWhite,
                      elevation: 0.0,
                      padding:EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft:_conversationMessageHolder[index]
                                ?Radius.circular(0.0)
                                :Radius.circular(15.0),
                            topRight:Radius.circular(15.0),
                            bottomLeft: Radius.circular(15.0),
                            bottomRight: _conversationMessageHolder[index]
                                ?Radius.circular(0.0)
                                :Radius.circular(15.0),
                          )
                      )
                  ),
                  child: Text(
                    _allConversationMessages[index][_message].toString(),
                    style: TextStyle(
                        fontSize: 16.0,
                        fontFamily: "Myraid",
                        color:_conversationMessageHolder[index]
                            ?Colors.white
                            :Colors.black,
                    ),
                  ),
                  onPressed:(){},
                  onLongPress: (){},
                )
              ],
            ),
          ),
          _conversationMessageTime(_allConversationMessages[index][_time].toString(), index),
        ]
    );
  }

  Widget _timeReFormat(String _willReturnTime) {
    if(int.parse(_willReturnTime.split(':')[0])<10)
    {
      _willReturnTime =_willReturnTime.replaceRange(
          0, _willReturnTime.indexOf(":"), '0${_willReturnTime.split(':')[0]}');
    }
    if(int.parse(_willReturnTime.split(':')[1])<10)
    {
      _willReturnTime = _willReturnTime.replaceRange(
          _willReturnTime.indexOf(":")+1,
          _willReturnTime.length,
          '0${_willReturnTime.split(':')[1]}'
      );
    }
    return Text(
      _willReturnTime,
      style: const TextStyle(color: Colors.lightBlue),
    );
  }

  Widget _mediaConversationManagement(BuildContext context, int index) {
    return Column(
      children: [
        Container(
          height:MediaQuery.of(context).size.height * 0.3,
          margin: (_conversationMessageHolder[index])
              ?EdgeInsets.only(
            right: MediaQuery.of(context).size.width/3,
            left: 5.0,
            top:30.0,
          )
              : EdgeInsets.only(
            left: MediaQuery.of(context).size.width/3,
            right: 5.0,
            top:15.0,
          ),
          alignment: (_conversationMessageHolder[index])
              ?Alignment.centerLeft
              :Alignment.centerRight,
          child: OpenContainer(
            openColor:const Color.fromRGBO(60, 80, 100, 1),
            closedColor: _conversationMessageHolder[index]
                        ?lightBlue
                        :fadedWhite,
            middleColor: const Color.fromRGBO(60, 80, 100, 1),
            closedElevation: 0.0,
            closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
            ),
            transitionDuration: Duration(milliseconds: 400),
            transitionType: ContainerTransitionType.fadeThrough,
            openBuilder: (context, openWidget){
              return ImageViewScreen(
                  imagePath:(_chatMessageCategoryHolder[index] == ChatMessageTypes.Image)?_allConversationMessages[index][_message].toString():_allConversationMessages[index][_message].toString().split("+")[0],
                  imageProviderCategory: ImageProviderCategory.FileImage
              );
            },
            closedBuilder: (context, closeWidget) => Stack(
                children:[
                  Container(
                    alignment: Alignment.center,
                    child: PhotoView(
                      imageProvider: FileImage(File((_chatMessageCategoryHolder[index] == ChatMessageTypes.Image)?_allConversationMessages[index][_message].toString():_allConversationMessages[index][_message].toString().split("+")[0])),
                      loadingBuilder: (context,event) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorBuilder: (context, obj, stackTrace) =>const Center(
                        child: Text("Image Not Found",
                          style: TextStyle(
                              fontSize: 23.0,
                              color: Colors.red,
                              fontFamily: "Lobster",
                              letterSpacing: 1.0
                          ),
                        ),
                      ),
                      enableRotation: true,
                      minScale: PhotoViewComputedScale.covered,
                    ),
                  ),
                  if(_chatMessageCategoryHolder[index] == ChatMessageTypes.Video)
                    Center(
                      child: IconButton(
                        iconSize: 100.0,
                        icon:const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        onPressed:() async{
                          final OpenResult openResult = await OpenFile.open(_allConversationMessages[index][_message].toString().split("+")[1]);
                          openFileResultStatus(openResult: openResult);
                        } ,
                      ),
                    )
                ]
            ),
          ),
        ),
        _conversationMessageTime(_allConversationMessages[index][_time].toString(), index),
      ],
    );
  }

  Widget _conversationMessageTime(String time, int index) {
    return Container(
      alignment:_conversationMessageHolder[index]
          ?Alignment.centerLeft
          :Alignment.centerRight,
      margin: _conversationMessageHolder[index]
          ? const EdgeInsets.only(
        left: 5.0,
        bottom:5.0,
        top:5.0,
      )
          :const EdgeInsets.only(
        right: 5.0,
        bottom:5.0,
        top:5.0,
      ),
      child: _timeReFormat(time),
    );
  }
  void _addSelectedMediaToChat(String path,
      {ChatMessageTypes chatMessageTypeTake = ChatMessageTypes.Image,
        String thumbnailPath = ''}) {
    Navigator.pop(context);
    final String _messageTime = "${DateTime.now().hour}:${DateTime.now().minute}";
    final String _messageDate = "${DateTime.now().toString().split(" ")[0].toString()}";
    if(mounted){
      setState(() {
        if(chatMessageTypeTake == ChatMessageTypes.Image){
          _allConversationMessages.add({
            _message: File(path).path,
            _time: _messageTime,
            _date:_messageDate,
          });
        }
        else{
          _allConversationMessages.add({
            _message:"$thumbnailPath+${File(path).path}",
            _time:_messageTime,
            _date:_messageDate
          });
        }
        _chatMessageCategoryHolder.add(
            chatMessageTypeTake == ChatMessageTypes.Image?
            ChatMessageTypes.Image
                :ChatMessageTypes.Video
        );
        _conversationMessageHolder.add(false);
      });
    }
    if(chatMessageTypeTake == ChatMessageTypes.Image)
      _sendImage(File(path).path);
    else{
      _sendVideo(videoPath: File(path).path, thumbnailPath: thumbnailPath);
    }
  }
  Future<void> _sendImage(String imageFilepath) async{
    if(mounted){
      setState(() {
        _isLoading=true;
      });
    }

    final String _messageTime = "${DateTime.now().hour}:${DateTime.now().minute}";

    final String _messageDate = "${DateTime.now().toString().split(" ")[0].toString()}";

    final String? downloadImagePath = await _cloudStoreDataManagement.uploadMediaToStorage(
        File(imageFilepath), reference:'principalImages/');

    if(downloadImagePath!=null){
      await _cloudStoreDataManagement.principalMessageToUser(
          sendMessageData: {
            ChatMessageTypes.Image.toString():{
              _message:downloadImagePath.toString(),
              _time:_messageTime,
              _date:_messageDate
            }
          },
        chatMessageTypes: ChatMessageTypes.Image
      );

      await _localDatabase.insertMessageInUserTable(
          userName: userName,
          actualMessage: imageFilepath,
          chatMessageTypes: ChatMessageTypes.Image,
          messageHolderType: MessageHolderType.Me,
          messageDateLocal: _messageDate,
          messageTimeLocal: _messageTime);
    }

    if(mounted){
      setState(() {
        _isLoading=false;
      });
    }
  }
  Future<void> _sendVideo(
      {required String videoPath, required thumbnailPath}) async {
    if (mounted) {
      setState(() {
        this._isLoading = true;
      });
    }
    final String _messageDate = "${DateTime.now().toString().split(" ")[0]}";
    final String _messageTime =
        "${DateTime.now().hour}:${DateTime.now().minute}";

    final String? downloadedVideoPath = await _cloudStoreDataManagement
        .uploadMediaToStorage(File(videoPath), reference: 'principalVideos/');

    final String? downloadedVideoThumbnailPath = await _cloudStoreDataManagement
        .uploadMediaToStorage(File(thumbnailPath),
        reference: 'principalVideosThumbnail/');

    if (downloadedVideoPath != null) {
      await _cloudStoreDataManagement.principalMessageToUser(
          sendMessageData: {
            ChatMessageTypes.Video.toString(): {
              _message:"${downloadedVideoPath.toString()}+${downloadedVideoThumbnailPath.toString()}",
              _time:_messageTime,
              _date:_messageDate
            }
          },
          chatMessageTypes: ChatMessageTypes.Video);

      await _localDatabase.insertMessageInUserTable(
          userName: userName,
          actualMessage:"${thumbnailPath.toString()}+${videoPath.toString()}",
          chatMessageTypes: ChatMessageTypes.Video,
          messageHolderType: MessageHolderType.Me,
          messageDateLocal: _messageDate,
          messageTimeLocal: _messageTime);
    }

    if (mounted) {
      setState(() {
        this._isLoading = false;
      });
    }
  }

  void openFileResultStatus({required OpenResult openResult}){
    if(openResult.type == ResultType.permissionDenied)
      showToast("Permission Denied To Open File", _fToast, toastColor: Colors.red,fontSize: 16.0);
    else if(openResult.type == ResultType.noAppToOpen)
      showToast("No App Found to Open", _fToast, toastColor: Colors.amber,fontSize: 16.0);
    else if(openResult.type == ResultType.error)
      showToast("Error in Opening File", _fToast, toastColor: Colors.red,fontSize: 16.0);
    else if(openResult.type == ResultType.fileNotFound)
      showToast("Sorry File Not Found", _fToast, toastColor: Colors.red,fontSize: 16.0);
  }

  Widget _documentConversationManagement(BuildContext context, int index) {
    return Column(
      children: [
        Container(
          height: _allConversationMessages[index][_message].toString().contains(".pdf")?
          MediaQuery.of(context).size.height *0.3
              :70.0,
          margin: _conversationMessageHolder[index]
              ? EdgeInsets.only(
              right:MediaQuery.of(context).size.width *0.3,
              left:5.0,
              top:30.0)
              : EdgeInsets.only(
              left:MediaQuery.of(context).size.width *0.3,
              right:5.0,
              top:15.0),
          alignment: _conversationMessageHolder[index]
              ?Alignment.centerLeft
              :Alignment.centerRight,
          child:Container(
            alignment: Alignment.center,
            decoration:BoxDecoration(
              shape: BoxShape.rectangle,
              color: _allConversationMessages[index][_message].toString().contains('.pdf')
                  ? Colors.white
                  : _conversationMessageHolder[index]
                  ? const Color.fromRGBO(60, 80, 100, 1)
                  : const Color.fromRGBO(102, 102, 255, 1),
              borderRadius:BorderRadius.circular(20.0),
            ),
            child: _allConversationMessages[index][_message].toString().contains(".pdf")
                ?Stack(
              children: [
                Center(
                    child: Text(
                      "Loading Error",
                      style: TextStyle(
                        fontFamily: 'Lobster',
                        color: Colors.red,
                        fontSize: 20.0,
                        letterSpacing: 1,
                      ),
                    )
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child:PdfView(
                    path:
                    _allConversationMessages[index][_message].toString(),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    child: Icon(
                        Icons.open_in_new_rounded,
                        size:40.0,
                        color:Colors.blue
                    ),
                    onTap: () async{
                      final OpenResult openResult = await OpenFile.open(
                          _allConversationMessages[index][_message]!
                      );
                      openFileResultStatus(openResult: openResult);
                    },
                  ),
                )
              ],
            )
                :GestureDetector(
              onTap: ()async{
                final OpenResult openResult = await OpenFile.open(
                    _allConversationMessages[index][_message]!
                );
                openFileResultStatus(openResult: openResult);
              },
              onLongPress: ()async{},
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 20.0,),
                    Icon(
                      Entypo.document,
                      color:Colors.white,
                    ),
                    SizedBox(width: 20.0,),
                    Expanded(
                      child: Text(
                        _allConversationMessages[index][_message].toString().split("/").last,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Lora',
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        _conversationMessageTime(_allConversationMessages[index][_time].toString(), index)
      ],
    );
  }

  Future<void> _pickFileStorage() async{
    List<String> _allowedExtensions =[
      'pdf',
      'doc',
      'docx',
      'xlx',
      'ppt',
      'pptx',
      'C',
      'cpp',
      'py',
      'text',
      'java',
      'js',
    ];

    try{
      final FilePickerResult? filePickerResult =
      await FilePicker.platform.pickFiles(
          type:FileType.custom,
          allowedExtensions: _allowedExtensions
      );
      if(filePickerResult != null && filePickerResult.files.length > 0){
        Navigator.pop(context);
        filePickerResult.files.forEach((file) async{
          print(file.path);
          if(_allowedExtensions.contains(file.extension)){
            if(mounted){
              setState(() {
                _isLoading=true;
              });
            }
            final String _messageTime = "${DateTime.now().hour}:${DateTime.now().minute}";
            final String _messageDate = "${DateTime.now().toString().split(" ")[0]}";
            final String? downloadedDocumentPath =
            await _cloudStoreDataManagement.uploadMediaToStorage(
                File(File(file.path.toString()).path),fileName: File(file.path.toString()).path.toString().split("/").last.split(".")[0].toString(),
                reference: "principalDocuments/");

            if(downloadedDocumentPath != null){
              await _cloudStoreDataManagement.principalMessageToUser(
                  sendMessageData: {
                    ChatMessageTypes.Document.toString():
                    {
                      _message:"${downloadedDocumentPath}+.${file.extension}",
                      _time:_messageTime,
                      _date:_messageDate
                    }
                  },
                chatMessageTypes: ChatMessageTypes.Document
              );
              if(mounted){
                setState(() {
                  _allConversationMessages.add({
                    _message:File(file.path.toString()).path,
                    _time:_messageTime,
                    _date:_messageDate
                  });
                });
                _chatMessageCategoryHolder.add(ChatMessageTypes.Document);
                _conversationMessageHolder.add(false);
              }
            }
            await _localDatabase.insertMessageInUserTable(
                userName: userName,
                actualMessage: File(file.path.toString()).path.toString(),
                chatMessageTypes: ChatMessageTypes.Document,
                messageHolderType: MessageHolderType.Me,
                messageDateLocal: _messageDate,
                messageTimeLocal: _messageTime);
          }
          else{
            showToast("Not Supported Format", _fToast,toastColor: Colors.red,fontSize: 16.0);
          }
        });
      }
      if(mounted){
        setState(() {
          _isLoading = false;
        });
      }
    }
    catch(e)
    {
    }
  }

  Widget _audioConversationManagement(BuildContext context, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onLongPress: ()async{},
          child: Container(
            margin: _conversationMessageHolder[index]?
            EdgeInsets.only(
              right: MediaQuery.of(context).size.width/3,
              left: 5.0,
              top: 5.0,
            ):
            EdgeInsets.only(
              left: MediaQuery.of(context).size.width/3,
              right: 5.0,
              top: 5.0,
            ),
            alignment: _conversationMessageHolder[index]?
            Alignment.centerLeft
                :Alignment.centerRight,
            child: Container(
              height: 70.0,
              width: 250.0,
              decoration: BoxDecoration(
                  color: _conversationMessageHolder[index]?
                  const Color.fromRGBO(255,1,1,0.8)
                      :const Color.fromRGBO(0,0,0,0.25),
                  borderRadius: _conversationMessageHolder[index]?
                  const BorderRadius.only(
                      topRight: Radius.circular(40.0),
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0)
                  )
                      :const BorderRadius.only(
                      topLeft: Radius.circular(40.0),
                      bottomLeft: Radius.circular(40.0),
                      bottomRight: Radius.circular(40.0)
                  )
              ),
              child: Row(
                children: [
                  SizedBox(
                    width:20.0,
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
                            margin: EdgeInsets.only(top:26.0),
                            child: LinearPercentIndicator(
                              percent: _justAudioPlayer.duration == null
                                  ? 0.0
                                  : _lastAudioPlayingIndex == index
                                  ? _curAudioPlayingTime /
                                  _justAudioPlayer
                                      .duration!.inMicroseconds
                                      .ceil() >= 1.0 ?1.0:_curAudioPlayingTime /
                                  _justAudioPlayer
                                      .duration!.inMicroseconds
                                      .ceil()
                                  : 0,
                              backgroundColor: Colors.black26,
                              progressColor:Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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
                      child: _lastAudioPlayingIndex != index
                          ? CircleAvatar(
                          radius: 23.0,
                          backgroundImage:
                          ExactAssetImage(
                            "assets/images/vicky.jpg",
                          )
                      )
                          : Text(
                        '${_audioPlaySpeed.toString().contains('.0') ? _audioPlaySpeed.toString().split('.')[0] : _audioPlaySpeed}x',
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
              ),
            ),
          ),
        ),
        _conversationMessageTime(_allConversationMessages[index][_time].toString(), index),
      ],
    );
  }

  void _voiceSend(String recordedFilePath, {String audioExtension=".mp3"})async {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if(_justAudioPlayer.duration !=null){
      if(mounted){
        setState(() {
          _justAudioPlayer.stop();
          _iconData = Icons.play_arrow_rounded;
        });
      }
    }

    await _justAudioPlayer.setFilePath(recordedFilePath);

    if(_justAudioPlayer.duration!.inMinutes > 20){
      showToast("Audio File Duration Can't greater than 20 minutes", _fToast);
    }
    else{
      if(mounted){
        setState(() {
          _isLoading=true;
        });
      }

      final String _messageTime = "${DateTime.now().hour}:${DateTime.now().minute}";
      final String _messageDate = "${DateTime.now().toString().split(" ")[0]}";

      final String? downloadVoicePath =
      await _cloudStoreDataManagement.uploadMediaToStorage(File(recordedFilePath),
          reference: "principalVoices/");

      if(downloadVoicePath!=null){
        await _cloudStoreDataManagement.principalMessageToUser(
            sendMessageData: {
              ChatMessageTypes.Audio.toString():{
                _message:downloadVoicePath.toString(),
                _time:_messageTime,
                _date:_messageDate
              }
            },
          chatMessageTypes: ChatMessageTypes.Audio
        );
        if(mounted){
          setState(() {
            _allConversationMessages.add({
              _message:recordedFilePath,
              _time:_messageTime,
              _date:_messageDate
            });
            _chatMessageCategoryHolder.add(ChatMessageTypes.Audio);
            _conversationMessageHolder.add(false);
          });
        }
        await _localDatabase.insertMessageInUserTable(
            userName: userName,
            actualMessage: recordedFilePath.toString(),
            chatMessageTypes: ChatMessageTypes.Audio,
            messageHolderType: MessageHolderType.Me,
            messageDateLocal: _messageDate,
            messageTimeLocal: _messageTime
        );
      }
      if(mounted){
        setState(() {
          _isLoading=false;
        });
      }
    }
  }

  _chatMicrophoneOnTapAction(int index) async{
    try{
      _justAudioPlayer.positionStream.listen((event) {
        if(mounted){
          setState(() {
            _curAudioPlayingTime = event.inMicroseconds.ceilToDouble();
            _loadingTime = '${event.inMinutes}:${event.inSeconds > 59 ? event.inSeconds % 60 : event.inSeconds}';
          });
        }
      });

      _justAudioPlayer.playerStateStream.listen((event){
        if(event.processingState == ProcessingState.completed){
          _justAudioPlayer.stop();
          if(mounted){
            setState(() {
              _loadingTime='0:00';
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
      else{
        print(_justAudioPlayer.processingState);
        if(_justAudioPlayer.processingState == ProcessingState.idle){
          await _justAudioPlayer.setFilePath(_allConversationMessages[index][_message].toString());
          if(mounted){
            setState(() {
              _lastAudioPlayingIndex =index;
              _totalDuration =
              "${_justAudioPlayer.duration!.inMinutes} : ${_justAudioPlayer.duration!.inSeconds}";
              _iconData = Icons.pause;
            });
          }

          await _justAudioPlayer.play();
        }
        else if(_justAudioPlayer.playing){
          if(mounted){
            setState(() {
              _iconData = Icons.play_arrow_rounded;
            });
          }
          await _justAudioPlayer.pause();
        }
        else if(_justAudioPlayer.processingState == ProcessingState.ready){
          if(mounted){
            setState(() {
              _iconData = Icons.pause;
            });
          }
          await _justAudioPlayer.play();
        }
        else if(_justAudioPlayer.processingState == ProcessingState.completed){}
      }
    }
    catch(e){
      print("Audio Playing Error");
      showToast("May Be Audio File Not Found", _fToast);
    }
  }

  _chatMicrophoneOnLongPressAction() async{
    if(_justAudioPlayer.playing){
      await _justAudioPlayer.stop();
      if(mounted){
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