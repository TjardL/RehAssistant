import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);

  Future<String> signUp(String email, String password,bool physio);

  Future<User> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;
    return user.uid;
  }

  Future<String> signUp(String email, String password,bool physio) async {
   // AuthResult result = 
   UserCredential res= await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);

if (physio) {
 
   
      await res.user.updateDisplayName("physio");
}
 
    User user = res.user;
    return user.uid;
  }

  Future<User> getCurrentUser() async {
    User user =  _firebaseAuth.currentUser;
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
    User user =  _firebaseAuth.currentUser;
    user.sendEmailVerification();
    print("email sent");
  }

  Future<bool> isEmailVerified() async {
    User user =  _firebaseAuth.currentUser;
    return user.emailVerified;
  }
}