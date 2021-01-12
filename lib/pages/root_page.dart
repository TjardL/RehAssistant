import 'package:RehAssistant/pages/therapist_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:RehAssistant/pages/login_page.dart';
import 'package:RehAssistant/services/authentication.dart';
import 'package:RehAssistant/pages/patient_home_page.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class RootPage extends StatefulWidget {
  RootPage({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  bool physio;
  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      user != null
          ? user.getIdToken(refresh: true).then((idToken) {
              setState(() {
                idToken.claims['physio'] == true
                    ? physio = true
                    : physio = false;
                if (user != null) {
                  _userId = user?.uid;
                }
                authStatus = user?.uid == null
                    ? AuthStatus.NOT_LOGGED_IN
                    : AuthStatus.LOGGED_IN;
              });
            })
          : setState(() {
              if (user != null) {
                _userId = user?.uid;
              }
              authStatus = user?.uid == null
                  ? AuthStatus.NOT_LOGGED_IN
                  : AuthStatus.LOGGED_IN;
            });
    });
  }

  Future<bool> currentUserClaims() async {
    final user = await FirebaseAuth.instance.currentUser();

    // If refresh is set to true, a refresh of the id token is forced.
    final idToken = await user.getIdToken(refresh: true);
    return idToken.claims['physio'] == true;
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      user.getIdToken(refresh: true).then((idToken) {
              setState(() {
                idToken.claims['physio'] == true
                    ? physio = true
                    : physio = false;
                _userId = user.uid.toString();
              });
            });
    
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new LoginSignupPage(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          if (physio == true) {
            return new TherapistHomePage(
              userId: _userId,
              auth: widget.auth,
              logoutCallback: logoutCallback,
            );
          } else {
            return new PatientHomePage(
              userId: _userId,
              auth: widget.auth,
              logoutCallback: logoutCallback,
            );
          }
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }
}
