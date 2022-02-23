import 'package:chat_app/FrontEnd/Authentication/login.dart';
import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:loading_overlay/loading_overlay.dart';
import 'package:chat_app/BackEnd/Firebase/Authentication/signup_auth.dart';

class Signup extends StatelessWidget {
  const Signup({Key? key}) : super(key: key);

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
              child: const SignupArea(),
            ),
          )
        ],
      ),
    );
  }
}

class SignupArea extends StatefulWidget {
  const SignupArea({Key? key}) : super(key: key);

  @override
  _SignupAreaState createState() => _SignupAreaState();
}

class _SignupAreaState extends State<SignupArea> {

  bool _isLoading = false;
  TextEditingController _cpwd = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _pwd = TextEditingController();
  final EmailAndPasswordAuth _emailandpasswordauth = EmailAndPasswordAuth();
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
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
                          'Welcome !',
                          style: TextStyle(
                              fontFamily: 'MyraidBold',
                              fontSize: 22,
                              color: Color.fromRGBO(74, 61, 84, 1)),
                        ),
                        SizedBox(height:2),
                        Text(
                          'Create an account to continue',
                          style: TextStyle(
                              fontFamily: 'Myraid',
                              fontSize: 16,
                              color: Color.fromRGBO(74, 61, 84, .5)),
                        ),
                      ],
                    ),
                    const Text('Sign Up',
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
                      children: <Widget>[
                        SignupText(
                            icon: Icon(Icons.mail_outline_outlined),
                            label: 'Enter your Mail',
                            validator:(String? value) {
                              if (value!.isEmpty ||!RegExp(r'^[\w-\.]+@(kongu.edu)').hasMatch(value)) {
                                return "Enter kongu.edu Email ";
                              }else
                              {
                                return null;
                              }
                            },
                          textEditingController: _email
                        ),
                        SignupText(
                          icon: Icon(Icons.lock_outline_rounded),
                          label: 'Enter your Password',
                          validator: (String? value) {
                            if (value!.isEmpty ||!RegExp(r'^[a-z A-Z]').hasMatch(value)) {
                              return "Please enter password";
                            }else
                            {
                              return null;
                            }
                          },
                          textEditingController: _pwd,
                          obscureText: true,
                        ),
                        SignupText(
                          icon: Icon(Icons.lock_outline_rounded),
                          label: 'Confirm Password',
                          validator:(String? value) {
                            if (value=="") {
                              return "Confirm Your Password";
                            }
                            else if(value !=this._pwd.text)
                            {
                              return "Password Not Matched";
                            }
                            else{
                              return null;
                            }
                          },
                          textEditingController:_cpwd,
                          obscureText: true,
                        ),
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
                  if(_formkey.currentState!.validate()){
                    if(mounted){
                      setState(() {
                        _isLoading=true;
                      });
                    }
                    SystemChannels.textInput.invokeMethod("TextInput.hide");
                    final SignUpResults response = await _emailandpasswordauth.signUpAuth(email: _email.text, pwd: _pwd.text);
                    if (response == SignUpResults.SignUpCompleted){
                      Navigator.push(context,MaterialPageRoute(builder:(_) => Login()));
                    }
                    else{
                      final String msg = response == SignUpResults.EmailAlreadyPresent?"Email Already Presented":"Sign Up Not Completed";
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                    }
                  }
                  if(mounted){
                    setState(() {
                      _isLoading=false;
                    });
                  }
                },
                child: Container(
                  child: const Center(
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'MyRaid',
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
                  decoration: const BoxDecoration(
                      color: Color.fromRGBO(8, 33, 198, 1),
                      borderRadius: BorderRadius.all(Radius.circular(50.0))),
                  width: double.infinity,
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an Account? ',style: TextStyle(fontFamily: 'MyRaid',fontSize: 18,color: Color.fromRGBO(0, 0, 0, 0.3)),),
                    GestureDetector(
                      child: const Text('Login',style: TextStyle(decoration: TextDecoration.underline,fontFamily: 'MyRaid',fontSize: 18,color: Color.fromRGBO(8, 33, 198, 1),),),
                      onTap: (){
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>Login()), (route) => false);
                      } ,
                    )
                  ],),
                padding: const EdgeInsets.only(top: 25.0),
              )
            ],
          ),
        )
      ],
    );
  }
}




Widget SignupText(
    {required String label,
      required Icon icon,
      required String? Function(String?)? validator,
      required TextEditingController textEditingController,
      bool obscureText = false
    }
    ){
  return TextFormField(
    validator: validator,
    controller: textEditingController,
    obscureText: obscureText,
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
