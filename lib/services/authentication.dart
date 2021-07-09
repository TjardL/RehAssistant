import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password,bool physio);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> signUp(String email, String password,bool physio) async {
   // AuthResult result = 
   AuthResult res= await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

if (physio) {
  UserUpdateInfo info = new UserUpdateInfo();
    info.displayName = "physio";
   
      await res.user.updateProfile(info);
}
 
    FirebaseUser user = res.user;
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
  //   try {
  //   await widget.auth.signOut();
  //   widget.onSignedOut();
    
  // } catch (e) {
  //   print(e);
  // }
    return _firebaseAuth.signOut();
    
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }
}