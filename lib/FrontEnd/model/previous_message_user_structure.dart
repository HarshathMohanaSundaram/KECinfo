import 'package:chat_app/Global_Uses/enum_generation.dart';

class PreviousMessageUserStructure {
  late String actualMessage;
  late String messageDate;
  late String messageTime;
  late bool messageHolder;
  late ChatMessageTypes messageType;

  PreviousMessageUserStructure({required String actualMessage,
    required String messageType,
    required String messageDate,
    required String messageTime,
    required String messageHolder}) {
    this.actualMessage = actualMessage;
    this.messageType = _getChatMessageTypePerfectly(messageType);
    this.messageTime = messageTime;
    this.messageDate = messageDate;
    this.messageHolder = _getChatMessageHolderType(messageHolder);
  }

  factory PreviousMessageUserStructure.toJson(Map<String, dynamic> map) {
    return PreviousMessageUserStructure(
        actualMessage: map["Message"],
        messageType: map["Message_Type"],
        messageDate: map["Message_Date"],
        messageTime: map["Message_Time"],
        messageHolder: map["Message_Holder"]);
  }

  ChatMessageTypes _getChatMessageTypePerfectly(String messageType) {
    if (messageType == ChatMessageTypes.Text.toString())
      return ChatMessageTypes.Text;
    else if (messageType == ChatMessageTypes.Image.toString())
      return ChatMessageTypes.Image;
    else if (messageType == ChatMessageTypes.Video.toString())
      return ChatMessageTypes.Video;
    else if (messageType == ChatMessageTypes.Audio.toString()) {
      return ChatMessageTypes.Audio;
    } else if (messageType == ChatMessageTypes.Document.toString()) {
      return ChatMessageTypes.Document;
    } else{
      return ChatMessageTypes.None;
    }
  }

  bool _getChatMessageHolderType(String messageHolderTypeString) {
    return messageHolderTypeString == MessageHolderType.Me.toString()?false:true;
  }
}