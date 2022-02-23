enum SignUpResults{
  SignUpCompleted,
  EmailAlreadyPresent,
  SignUpNotCompleted
}

enum LoginResults{
  LoginCompleted,
  EmailOrPasswordInvalid,
  EmailNotVerified,
  UnExceptedErrorOccurs
}

enum PasswordReset{
  LinkSent,
  LinkNotSent
}

enum ConnectionStateName{
  Connect,
  Pending,
  Accept,
  Message,
}

enum ConnectionStateType{
  ButtonOnlyName,
  ButtonBorderColor,
  ButtonNameWidget
}

enum OtherConnectionStatus{
  Request_Pending,
  Invitation_Came,
  Invitation_Accepted,
  Request_Accepted
}

enum ChatMessageTypes{
  Notify,
  None,
  Text,
  Image,
  Video,
  Document,
  Audio,
}

enum ImageProviderCategory{
  FileImage,
  ExactAssetImage,
  NetworkImage
}

enum MessageHolderType{
  Me,
  User,
}

enum GetFieldForImportantDataLocalDatabase{
  UserEmail,
  Token,
  ProfileImagePath,
  ProfileImageUrl,
  About,
  WallPaper,
  Notification,
  Department,
}

enum PreviousMessageColTypes {
  ActualMessage,
  MessageDate,
  MessageTime,
  MessageHolder,
  MessageType,
}