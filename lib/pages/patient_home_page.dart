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
import "package:RehAssistant/helper/datetime_extension.dart";

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
  int runStreak = 0;
  PageController controller;
  int getPageIndex = 0;
  Future dataFuture;
  final databaseReference = FirebaseFirestore.instance;
  List<ExerciseCard> exercises = [];
  Map<String, List<DateTime>> exDates = {};
  List<DateTime> tempDate = [];
  int exercisesDone = 0;
  int exercisesDoneMax = 0;
  bool showDiary = true;
  bool showQuestionnaire = true;
  @override
  void initState() {
    
    print(email);
    controller = PageController();
    // getData("tjard123@gmail.com");
    SetReminderAction(
        time: new DateTime.now().toIso8601String(),
        name:
            'Time to fill out the Diary and complete Exercises you haven´t done today.',
        repeat: RepeatInterval.daily);

    scheduleNotificationPeriodically(
        flutterLocalNotificationsPlugin,
        '0',
        'Time to fill out the Diary and complete Exercises you haven´t done today.',
        RepeatInterval.daily);
    super.initState();
    dataFuture = getData();
  }

  //Ab hier queries
  getData() async {
    User user = await widget.auth.getCurrentUser();
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
        
        .doc('$email')
        .get()
        .then((DocumentSnapshot ds) {
      if (ds.exists) {
        name = ds['name'] ?? "";

        if (ds['diary'] == "true") {
          showDiary = true;
        } else {
          showDiary = false;
        }
        if (ds['questionnaire'] == "true") {
          showQuestionnaire = true;
        } else {
          showQuestionnaire = false;
        }
      } else {
        name =
            "this account has not been yet linked to a account created by your therapist. You registered with another e-mail or your therapist has added the wrong e-mail";
      }

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
        .doc('$email')
        .collection('Exercises')
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((f) async {
        exercises.add(
          ExerciseCard(
              name: "${f.id}", 

              sets: f["sets"],
              reps: f["reps"],
              frequency: f["frequency"],
              done: false,
              email: email),
        );

        // await databaseReference
        //     .collection('User')
        //     .doc('$email')
        //     .collection('Exercises')
        //     .doc("${f.documentID}")
        //     .collection("timesDone")
        //     .get()
        //     .then((QuerySnapshot snapshot) {
        //   tempDate = [];
        //   snapshot.docs.forEach((g) {
        //     tempDate.add(DateFormat('d MMM yyyy').parse(g.documentID));
        //   });
        //   exDates["${f.documentID}"] = tempDate;
        // });

        _calcExercisesDone();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
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
                  if (showDiary) PatientDiaryPage(email: email),
                  if (showQuestionnaire) PatientQuestionnairePage(email: email),

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

  _calcExercisesDone() {
    Set<DateTime> temp = {};
    List<DateTime> temp2 = [];
    runStreak = 0;
    exDates.forEach((key, value) {
      temp.addAll(value);

      temp.toSet().toList();
    });
    temp2 = temp.toList();
    temp2.sort((a, b) => a.compareTo(b));
    print(temp);
    print("EXTIME ${temp.length}");
    setState(() {
      if (temp.isEmpty ?? true) {
        exercisesDoneMax = 0;
        exercisesDone = 0;
        runStreak = 0;
      } else {
        //calc runStreak
        for (int i = temp2.length - 1; i >= 0; i--) {
          print(temp2[i]);
          if (temp2[i].isSameDate(DateTime.now())) {
            runStreak++;
          } else {
            break;
          }
        }

        exercisesDoneMax = temp2[0].difference(DateTime.now()).inDays.abs() + 1;
        exercisesDone = temp.length;
      }
    });
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
                'Exercises done: $exercisesDone/$exercisesDoneMax days',
                style: TextStyle(fontSize: 18.0),
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
          label:'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          // new Image(
          //   image: Icon(Icons.fitness_center),
          //   //AssetImage(getPageIndex==1?"images/exercise_icon_blue.png":"images/exercise_icon.png"),
          //   height: 22,
          // ),
          label: 'Exercises',
        ),
        BottomNavigationBarItem(
            icon: new Icon(Icons.assignment), label:'Questionnaire'),
        BottomNavigationBarItem(
            icon: new Icon(Icons.book), label:'Diary'),
      ],
      onTap: _onTapChangePage,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  _onTapChangePage(int pageIndex) {
    controller.animateToPage(pageIndex,
        duration: Duration(milliseconds: 400), 
        curve: Curves.easeIn);
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
    var platformChannelSpecifics = NotificationDetails();
    //await flutterLocalNotificationsPlugin.periodicallyShow(
    // 0, 'Reminder', body, interval, platformChannelSpecifics);
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
