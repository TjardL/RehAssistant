import 'package:RehAssistant/model/questionnaire_item.dart';
import 'package:RehAssistant/pages/subpages/therapist_create_patient_page.dart';
import 'package:RehAssistant/pages/subpages/therapist_select_patient_page.dart';
import 'package:RehAssistant/pages/therapist_diary_page.dart';
import 'package:RehAssistant/pages/therapist_exercise_page.dart';
import 'package:RehAssistant/pages/therapist_questionnaire_page.dart';
import 'package:RehAssistant/widgets/exercise_card.dart';
import 'package:RehAssistant/widgets/small_task_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:RehAssistant/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TherapistHomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  const TherapistHomePage(
      {Key key, this.auth, this.logoutCallback, this.userId})
      : super(key: key);
  @override
  _TherapistHomePageState createState() => _TherapistHomePageState();
}

class _TherapistHomePageState extends State<TherapistHomePage> {
  final databaseReference = Firestore.instance;
  Future dataFuture;
  List<ExerciseCard> exercises = [];
  List<QuestionnaireItem> questionnaireItems = [];
  List<String> diaryItemsBetter = [];
  List<String> diaryItemsWorse = [];
  List<Map<String, String>> diaryItems = [];
  String name;
  String email = "tjard123@gmail.com";
  int tasksDone;
  int runStreak;
  PageController controller;
  int getPageIndex = 0;
  Map<String, List<DateTime>> exDates = {};
  List<DateTime> tempDate = [];
  @override
  void initState() {
    controller = PageController(
        // initialPage: 1
        );

    dataFuture = getData(email);
    super.initState();
    // _navigateAndDisplaySelectionInit(context);
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  // pageView = PageView(controller:controller, children: <Widget>[], );
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
                  _buildTherapistHomePage(),
                  TherapistExercisesPage(
                    exercises: exercises,
                    exDates: exDates,
                    addExerciseCallback: addExerciseCallback,
                  ),
                  TherapistQuestionnairePage(data: questionnaireItems),
                  TherapistDiaryPage(
                    diaryItems: diaryItems,
                  ),
                  // PatientQuestionnairePage(),
                  // PatientDiaryPage()
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

  //Ab hier queries
  getData(String email) async {
    try {
     // await _navigateAndDisplaySelectionInit(context);
      List responses = await Future.wait([
        getGeneralData(email),
        getExerciseData(email),
        getQuestionnaireData(email),
        getDiaryData(email)
      ]);
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
      tasksDone = ds['task_done'];
      runStreak = ds['runstreak'];

      return ds;
    });
  }

  getExerciseData(String email) async {
    exercises = [];
    await databaseReference
        .collection('User')
        .document('$email')
        .collection('Exercises')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) async {
        print('${f.data}}');
        exercises.add(
          ExerciseCard(
            name: "${f.documentID}",
            sets: f["sets"],
            reps: f["reps"],
            frequency: f["frequency"],
            done: false,
          ),
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

  getQuestionnaireData(String email) async {
    questionnaireItems = [];
    await databaseReference
        .collection('User')
        .document('$email')
        .collection('Questionnaire')
        .orderBy("date")
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        print('${f.data}}');
        questionnaireItems.add(
          QuestionnaireItem(
            date: DateFormat('d MMM yyyy').parse(f.documentID),
            interferenceActivity: double.parse(f["interference_activity"]),
            interferenceEnjoyment: double.parse(f["interference_enjoyment"]),
            interferenceMood: double.parse(f["interference_mood"]),
            interferenceSleep: double.parse(f["interference_sleep"]),
            painAverage: double.parse(f["pain_average"]),
            painLeast: double.parse(f["pain_least"]),
            painNow: double.parse(f["pain_now"]),
            painWorst: double.parse(f["pain_worst"]),
          ),
        );
      });
    });
  }

  getDiaryData(String email) async {
    diaryItems = [];
    await databaseReference
        .collection('User')
        .document('$email')
        .collection('Diary')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      snapshot.documents.forEach((f) {
        diaryItems.add(
            {"better": f["symptoms_better"], "worse": f["symptoms_worse"]});
        // diaryItemsBetter.add(f["symptoms_better"]);
        // diaryItemsWorse.add(f["symptoms_worse"]);
      });
    });
  }

  _buildTherapistHomePage() {
    return ListView(
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        // RaisedButton(
        //     child: Text(
        //       'Logout',
        //       style: TextStyle(
        //         fontSize: 18.0,
        //         color: Colors.white,
        //       ),
        //     ),
        //     onPressed: () {
        //       widget.auth.signOut();
        //       signOut();
        //     }),
        Padding(
          padding:
              const EdgeInsets.only(left: 48, top: 24, right: 64, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Welcome back, Dr.X!',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              SmallTaskButton("Create Patient", () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TherapistCreatePatientPage()));
              }),
              SizedBox(height: 16),
              SmallTaskButton("Select Patient", () {
                _navigateAndDisplaySelection(context);
              })
            ],
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 48, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Active Patient: $name',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              SmallTaskButton("Add Exercise", () {
                createExerciseDialog(context)
                    .then((controller) => {addExercise(controller)});
              }),
              SizedBox(height: 16),
              SmallTaskButton("Change Tasks", () {}),
            ],
          ),
        ),
        Divider(),
        Padding(
          padding: const EdgeInsets.only(left: 48, top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Activity Log of Patient',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Exercises done: 5/10',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Entries in Diary: 3',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Questionnaire filled out: 2',
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

  _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final DocumentSnapshot ds = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => SelectPatientPage()),
    );
    if (ds != null) {
      setState(() {
        name = ds['name'];
        tasksDone = ds['task_done'];
        runStreak = ds['runstreak'];
        email = ds.documentID;
        getData(email);
      });
    }
  }

  _navigateAndDisplaySelectionInit(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final DocumentSnapshot ds = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => SelectPatientPage()),
    );
    if (ds != null) {
      name = ds['name'];
      tasksDone = ds['task_done'];
      runStreak = ds['runstreak'];
      email = ds.documentID;
      await getData(email);
    }
  }

  void addExerciseCallback() {
    print('moin');

    createExerciseDialog(context).then((controller) => addExercise(controller));
  }

  addExercise(List<TextEditingController> controller) {
    setState(() {
      try {
        exercises.add(
          ExerciseCard(
            name: controller[0].text.toString(),
            sets: controller[2].text.toString(),
            reps: controller[1].text.toString(),
            frequency: controller[3].text.toString(),
            done: false,
          ),
        );
        databaseReference
            .collection('User')
            .document('$email')
            .collection('Exercises')
            .document('${exercises[exercises.length - 1].name}')
            .setData({
          'reps': exercises[exercises.length - 1].reps,
          'sets': exercises[exercises.length - 1].sets,
          'frequency': exercises[exercises.length - 1].frequency
        });
      } catch (e) {
        print(e);
      }
    });
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
      ],
      onTap: _onTapChangePage,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  _onTapChangePage(int pageIndex) {
    controller.animateToPage(pageIndex,
        duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<List<TextEditingController>> createExerciseDialog(
      BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController repController = TextEditingController();
    TextEditingController setController = TextEditingController();
    TextEditingController freqController = TextEditingController();
    List<TextEditingController> controller = [];
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Create Exercise"),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Name'),
                ),
                TextField(
                  controller: repController,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Reps'),
                ),
                TextField(
                  controller: setController,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Sets'),
                ),
                TextField(
                  controller: freqController,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Frequency / Day'),
                )
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                onPressed: () {
                  controller.add(nameController);
                  controller.add(repController);
                  controller.add(setController);
                  controller.add(freqController);
                  Navigator.of(context).pop(controller);
                },
                child: Text('Submit'),
              )
            ],
          );
        });
  }
}