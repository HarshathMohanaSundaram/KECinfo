import 'package:chat_app/BackEnd/Firebase/Authentication/signup_auth.dart';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/checking_character.dart';
import 'package:chat_app/BackEnd/Firebase/OnlineUserManagement/cloud_data_management.dart';
import 'package:chat_app/BackEnd/sqflite/local_database_management.dart';
import 'package:chat_app/FrontEnd/MessagesScreen/config.dart';
import 'package:chat_app/FrontEnd/NewUserDetails/new_user_setup.dart';
import 'package:chat_app/FrontEnd/screens/home_screen.dart';
import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/FrontEnd/Authentication/signup.dart';
import 'package:flutter/services.dart';
import 'package:loading_overlay/loading_overlay.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ignore: avoid_print
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                  padding: const EdgeInsets.all(60.0),
                  child: const Image(
                    image: AssetImage("assets/images/tys.png"),
                  )),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, .1),
                borderRadius: BorderRadius.only(topRight: Radius.circular(100)),
              ),
              child: const LoginArea(),
            ),
          )
        ],
      ),
    );
  }
}


class LoginArea extends StatefulWidget {
  const LoginArea({Key? key}) : super(key: key);

  @override
  _LoginAreaState createState() => _LoginAreaState();
}

class _LoginAreaState extends State<LoginArea> {
  final _formkey = GlobalKey<FormState>();
  final _resetFormkey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextEditingController _email=TextEditingController();
  TextEditingController _pwd =TextEditingController();
  TextEditingController _fpwd = TextEditingController();
  LocalDatabase _localDatabase = LocalDatabase();
  final EmailAndPasswordAuth _emailAndPasswordAuth = EmailAndPasswordAuth();
  final CloudStoreDataManagement _cloudStoreDataManagement = CloudStoreDataManagement();
  final CloudStoreCharacter _cloudStoreCharacter = CloudStoreCharacter();
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
                top: 40.0, left: 10.0, bottom: 40.0, right: 10.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, right: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Welcome back !',
                            style: TextStyle(
                                fontFamily: 'MyraidBold',
                                fontSize: 22,
                                color: Color.fromRGBO(74, 61, 84, 1)),
                          ),
                          SizedBox(height:2),
                          Text(
                            'Sign in to continue',
                            style: TextStyle(
                                fontFamily: 'Myraid',
                                fontSize: 16,
                                color: Color.fromRGBO(74, 61, 84, .5)),
                          ),
                        ],
                      ),
                      Text('Log In',
                          style: TextStyle(fontFamily: 'Mistral', fontSize: 28))
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                  child: Container(
                    child: Form(
                      key: _formkey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children:<Widget> [
                          LoginText(
                              icon: Icon(Icons.mail_outline_outlined),
                              label: 'Enter your Mail',
                              validator:(String? value) {
                                if (value!.isEmpty ||!RegExp(r'^[\w-\.]+@(kongu.edu)').hasMatch(value)) {
                                  return "Enter kongu.edu Email ";
                                }
                                return null;
                              },
                             textEditingController: _email,
                          ),
                          PasswordText(
                              icon: Icon(Icons.lock_outline_rounded),
                              label: 'Enter your Password',
                              validator: (String? value) {
                                if (value!.isEmpty ||
                                    !RegExp(r'^[a-z A-Z]').hasMatch(value)) {
                                  return "Please enter password";
                                }
                                return null;
                              },
                            textEditingController: _pwd,
                          ),
                          GestureDetector(
                            onTap: () =>forgotPassword(),
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    color: Color.fromRGBO(0, 180, 255, 1),
                                    fontFamily: 'MyRaid',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(40.0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      color: Colors.white,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async{
                    if(mounted){
                      setState(() {
                        _isLoading = true;
                      });
                    }
                    if(_formkey.currentState!.validate())
                    {
                      print("Login Successful!!");
                      SystemChannels.textInput.invokeMethod('TextInput.hide');
                      final LoginResults _loginResults=await this._emailAndPasswordAuth.loginAuth(email: this._email.text, pwd: this._pwd.text);
                      String msg='';
                      if(_loginResults == LoginResults.LoginCompleted) {
                        final bool userPresentOrNot = await _cloudStoreDataManagement
                            .userRecordPresentOrNot(
                            email: this._email.text);
                        if (userPresentOrNot) {
                          final String userCharacter = await _cloudStoreCharacter
                              .userCharacter(
                              email: this._email.text);
                          final String userName = await _cloudStoreCharacter
                              .userName(
                              email: this._email.text);
                          final String profilePath = await _cloudStoreCharacter.userProfile(email: _email.text);
                          if (userCharacter == "error" ||
                              userName == "error") {
                            msg =
                            "There is some error in Fetching Your Details";
                          }
                          else{
                            await _localDatabase.createTableToStoreImportantData();
                            await _localDatabase.createTableToStoreImportantDataForGroup();
                            Navigator.pushAndRemoveUntil(
                                context, MaterialPageRoute(
                                builder: (_) =>
                                    HomeScreen(
                                      character: userCharacter,
                                      email: _email.text,
                                      userName: userName,
                                      profilepath: profilePath,
                                    )), (route) => false);
                          }
                        }
                        else {
                          Navigator.pushAndRemoveUntil(
                              context, MaterialPageRoute(
                              builder: (_) =>
                                  SetUp()), (
                              route) => false);
                        }
                      }
                      else if(_loginResults== LoginResults.EmailNotVerified){
                        final snackBar = SnackBar(
                          content: Text('Email Not Verified\n Please Verify Your Email'),
                          action: SnackBarAction(
                            label: 'Resent It',
                            onPressed: () async{
                              final ResentVerify resentVerify = await _emailAndPasswordAuth.reSentVerification(email: _email.text, pwd:_pwd.text);
                              if(resentVerify == ResentVerify.VerificationSent)
                              {
                                msg="Verification Link Has beeb Sent to Your email";
                              }
                              else{
                                msg="There is UnExcepted Error in Sending Verification Mail \n Please Try again later";
                              }
                            },
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                      else if(_loginResults== LoginResults.EmailOrPasswordInvalid)
                      {
                        msg="Email and Password Invalid";
                      }
                      else if(_loginResults==LoginResults.UnExceptedErrorOccurs)
                      {
                        msg="UnExcepted Error Occurs";
                      }
                      if (msg!="")
                      {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                      }
                    }
                    if(mounted){
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: Container(
                    child: const Center(
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'MyRaid',
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        )),
                    padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(0, 180, 255, 1),
                        borderRadius: BorderRadius.all(Radius.circular(50.0))),
                    width: double.infinity,
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Dont have an Account? ',style: TextStyle(fontFamily: 'MyRaid',fontSize: 18,color: Color.fromRGBO(0, 0, 0, 0.3)),),
                      GestureDetector(
                        child: const Text('SignUp',style: TextStyle(decoration: TextDecoration.underline,fontFamily: 'MyRaid',fontSize: 18,color: Color.fromRGBO(8, 33, 198, 1),),),
                        onTap: (){
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>Signup()), (route) => false);
                        } ,
                      )
                    ],),
                  padding: const EdgeInsets.only(top: 25.0),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  forgotPassword(){
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.0)
          ),
          elevation: 0.3,
          backgroundColor: Colors.white,
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 4,
            child: Form(
              key: _resetFormkey,
              child: Column(
                children: [
                  Row(
                    children:const [
                      CircleAvatar(
                        radius:20,
                        backgroundImage: AssetImage("assets/images/logo_app_icon.png"),
                      ),
                      SizedBox(width:2),
                      Text(
                          "KECinfo",
                        style: TextStyle(
                          color: royalBlue,
                          fontFamily: "MyRaidBold",
                          fontSize: 20,
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  TextFormField(
                    validator: (String? value) {
                      if (value!.isEmpty ||!RegExp(r'^[\w-\.]+@(kongu.edu)').hasMatch(value)) {
                        return "Enter kongu.edu Email ";
                      }
                      return null;
                    },
                    controller: _fpwd,
                    decoration: const InputDecoration(
                        hintText: "Enter your Mail ",
                        hintStyle: const TextStyle(
                            fontFamily: 'Myraid',
                            fontSize: 16,
                            color: Color.fromRGBO(74, 61, 84, .5)),
                        prefixIcon: Icon(Icons.mail_outline_outlined),
                        prefixIconColor: Colors.black),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: ()async{
                      if(_resetFormkey.currentState!.validate()){
                        String msg = '';
                        final PasswordReset passwordReset = await _emailAndPasswordAuth.passwordReset(email:_fpwd.text);
                        if(passwordReset == PasswordReset.LinkSent){
                          msg = "Password Reset Link has been Sent to ${_fpwd.text}";
                        }
                        else{
                          msg = "Unexcepted error occurs try after Sometime";
                        }
                        _fpwd.clear();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                        Navigator.pop(context);
                      }
                    },
                    child:const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color.fromRGBO(0, 180, 255, 1),
                      child: Icon(Icons.send, color: Colors.white,),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
    );
  }

  Widget LoginText(
      {required String label,
        required Icon icon,
        required String? Function(String?)? validator,
        required TextEditingController textEditingController,
      }
      ){
    return TextFormField(
      validator: validator,
      controller: textEditingController,
      decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(
              fontFamily: 'Myraid',
              fontSize: 16,
              color: Color.fromRGBO(74, 61, 84, .5)),
          prefixIcon: icon,
          prefixIconColor: Colors.black),
    );
  }
}

class PasswordText extends StatefulWidget {
  final TextEditingController textEditingController;
  final String? Function(String?)? validator;
  final Icon icon;
  final String label;
  const PasswordText({Key? key, required this.label,
    required this.icon,
    required this.validator,
    required this.textEditingController,}) : super(key: key);

  @override
  _PasswordTextState createState() => _PasswordTextState();
}

class _PasswordTextState extends State<PasswordText> {
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      controller: widget.textEditingController,
      obscureText:_isObscure,
      decoration: InputDecoration(
        hintText: widget.label,
        hintStyle: const TextStyle(
            fontFamily: 'Myraid',
            fontSize: 16,
            color: Color.fromRGBO(74, 61, 84, .5)),
        prefixIcon: widget.icon,
        prefixIconColor: Colors.black,
        suffixIcon: IconButton(
          icon: Icon(
              _isObscure ? Icons.visibility : Icons.visibility_off,
              color: lightBlue
          ),
          onPressed: () {
            setState(() {
              _isObscure = !_isObscure;
            });
          },
        ),
      ),
    );
  }
}
