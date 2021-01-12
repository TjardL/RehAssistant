import 'package:RehAssistant/main.dart';
import 'package:RehAssistant/pages/patient_diary_page.dart';
import 'package:RehAssistant/pages/patient_exercises_page.dart';
import 'package:RehAssistant/pages/patient_fms_page.dart';
import 'package:RehAssistant/pages/patient_questionnaire_page.dart';
import 'package:RehAssistant/services/notification_helper.dart';
import 'package:RehAssistant/widgets/small_task_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:RehAssistant/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:RehAssistant/widgets/exercise_card.dart";
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class PatientHomePage extends StatefulWidget {
  PatientHomePage({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  _PatientHomePageState createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  String name;
  String email;
  int tasksDone;
  int runStreak;
  PageController controller;
  int getPageIndex = 0;
  Future dataFuture;
  final databaseReference = Firestore.instance;
  List<ExerciseCard> exercises = [];
  Map<String, List<DateTime>> exDates = {};
  List<DateTime> tempDate = [];
  @override
  void initState() {

    print(email);
    controller = PageController();
    // getData("tjard123@gmail.com");
    SetReminderAction(
        time: new DateTime.now().toIso8601String(),
        name:
            'Time to fill out the Diary and complete Exercises you haven´t done today.',
        repeat: RepeatInterval.Daily);

    scheduleNotificationPeriodically(
        flutterLocalNotificationsPlugin,
        '0',
        'Time to fill out the Diary and complete Exercises you haven´t done today.',
        RepeatInterval.Daily);
    super.initState();
    dataFuture = getData();
  }

  //Ab hier queries
  getData() async {
  FirebaseUser user = await widget.auth.getCurrentUser();
  email = user.email;

    try {
      List responses =
          await Future.wait([getGeneralData(email), getExerciseData(email)]);
    } catch (e) {
      print(e.toString());
    }
  }

  getGeneralData(String email) async {
    await databaseReference
        .collection('User')
        .document('$email')
        .get()
        .then((DocumentSnapshot ds) {
      name = ds['name'];
      tasksDone = ds['task_done']?? 0;
      runStreak = ds['runstreak']?? 0;
      return ds;
    });
  }

  getExerciseData(String email) async {
    // defiened as class fields, for clarity purposes as comments here:
    // final databaseReference = Firestore.instance;
    // List<ExerciseCard> exercises = [];
    // Map<String, List<DateTime>> exDates = {};
    // List<DateTime> tempDate = [];
    await databaseReference
        .collection('User')
        .document('$email')
        .collection('Exercises')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) async {
        exercises.add(
          ExerciseCard(
              name: "${f.documentID}",
              sets: f["sets"],
              reps: f["reps"],
              frequency: f["frequency"],
              done: false,
              email: email),
        );

        await databaseReference
            .collection('User')
            .document('$email')
            .collection('Exercises')
            .document("${f.documentID}")
            .collection("timesDone")
            .getDocuments()
            .then((QuerySnapshot snapshot) {
          tempDate = [];
          snapshot.documents.forEach((g) {
            tempDate.add(DateFormat('d MMM yyyy').parse(g.documentID));
          });
          exDates["${f.documentID}"] = tempDate;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RehAssistant'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              widget.auth.signOut();
              signOut();
            },
          )
        ],
      ),
      body: FutureBuilder(
          future: dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return PageView(
                controller: controller,
                children: <Widget>[
                  _buildPatientHomePage(),
                  PatientExercisesPage(
                    exercises: exercises,
                    exDates: exDates,
                  ),
                  PatientQuestionnairePage(email: email),
                  PatientDiaryPage(email: email),
                  //PatientFMSPage(),
                ],
                onPageChanged: _whenPageChanges,
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
      bottomNavigationBar: _createBottomNavigationBar(),
    );
  }

  _whenPageChanges(int pageIndex) {
    setState(() {
      this.getPageIndex = pageIndex;
    });
  }

  _buildPatientHomePage() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 48, top: 32, right: 64, bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome, $name!',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Due tasks today:',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 16),
              //Hier muss ein Stream builder hin
              SmallTaskButton("Exercises", () {}),
              SizedBox(height: 8),
              SmallTaskButton("Diary", () {}),

              // await FirebaseAuth.instance.signOut();
            ],
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 48, top: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Activity Log',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Total Tasks done: $tasksDone',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Runstreak: $runStreak',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  _createBottomNavigationBar() {
    return CupertinoTabBar(
      //type: BottomNavigationBarType.fixed,
      currentIndex: getPageIndex, // this will be set when a new tab is tapped
      items: [
        BottomNavigationBarItem(
          icon: new Icon(Icons.home),
          title: new Text('Home'),
        ),
        BottomNavigationBarItem(
          icon: new Image(
            image: AssetImage("images/exercise_icon.png"),
            height: 22,
          ),
          title: new Text('Exercises'),
        ),
        BottomNavigationBarItem(
            icon: new Icon(Icons.assignment), title: Text('Questionnaire')),
        BottomNavigationBarItem(
            icon: new Icon(Icons.book), title: Text('Diary')),
        //BottomNavigationBarItem(
        //  icon: new Icon(Icons.trending_up), title: Text('Movement Screen')),
      ],
      onTap: _onTapChangePage,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  _onTapChangePage(int pageIndex) {
    controller.animateToPage(pageIndex,
        duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  Future<void> scheduleNotificationPeriodically(
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
      String id,
      String body,
      RepeatInterval interval) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      id,
      'Reminder notifications',
      'Remember about it',
      icon: 'smile_icon',
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    //await flutterLocalNotificationsPlugin.periodicallyShow(
    // 0, 'Reminder', body, interval, platformChannelSpecifics);
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
