import 'package:chat_app/Global_Uses/enum_generation.dart';
import 'package:firebase_auth/firebase_auth.dart';



class EmailAndPasswordAuth{
  Future<SignUpResults> signUpAuth({required String email, required String pwd}) async{
    try{
      final UserCredential userCredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pwd);
      if(userCredential.user!.email != null){
          await userCredential.user!.sendEmailVerification();
          return SignUpResults.SignUpCompleted;
      }
      return SignUpResults.SignUpNotCompleted;
    }
    catch(e){
      print("Error in Email And Password SignUp: ${e.toString()}");
      return SignUpResults.EmailAlreadyPresent;
    }
  }

  Future<LoginResults> loginAuth({required String email, required String pwd}) async{
    try{
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pwd);
      if(userCredential.user!.emailVerified){
        return LoginResults.LoginCompleted;
      }
      else{
        final bool logoutResponse =await logout();
        if(logoutResponse)
        {
            return LoginResults.EmailNotVerified;
        }
        return LoginResults.UnExceptedErrorOccurs;
      }
    }
    catch(e){
      print("Error In Login: ${e.toString()}");
      return LoginResults.EmailOrPasswordInvalid;
    }
  }

  Future<ResentVerify> reSentVerification({required String email, required String pwd}) async{
    try{
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pwd);
      if(userCredential.user!.email != null){
        await userCredential.user!.sendEmailVerification();
        final bool logoutResponse =await logout();
        return ResentVerify.VerificationSent;
      }
      return ResentVerify.VerificationNotSent;
    }
    catch(e){
      print("Error In resent: ${e.toString()}");
      return ResentVerify.VerificationNotSent;
    }
  }

  Future<bool> logout() async{
    try{
      await FirebaseAuth.instance.signOut();
      return true;
    }
    catch(e){
      return false;
    }
  }

  Future<PasswordReset> passwordReset({required String email}) async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return PasswordReset.LinkSent;
    }
    catch(e){
        print("Error in Sending Password Link: ${e.toString()}");
        return PasswordReset.LinkNotSent;
    }
  }

}