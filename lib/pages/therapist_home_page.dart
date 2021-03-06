import 'package:RehAssistant/helper/dash_counter.dart';
import 'package:RehAssistant/model/questionnaire_item.dart';
import 'package:RehAssistant/pages/purchase_page.dart';
import 'package:RehAssistant/pages/subpages/therapist_create_patient_page.dart';
import 'package:RehAssistant/pages/subpages/therapist_select_patient_page.dart';
import 'package:RehAssistant/pages/therapist_diary_page.dart';
import 'package:RehAssistant/pages/therapist_exercise_page.dart';
import 'package:RehAssistant/pages/therapist_questionnaire_page.dart';
import 'package:RehAssistant/services/dash_purchases.dart';
import 'package:RehAssistant/widgets/exercise_card.dart';
import 'package:RehAssistant/widgets/exercise_card_therapist.dart';
import 'package:RehAssistant/widgets/small_task_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:RehAssistant/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final databaseReference = FirebaseFirestore.instance;
  Future dataFuture;
  List<ExerciseCardTherapist> exercises = [];
  List<QuestionnaireItem> questionnaireItems = [];
  List<String> diaryItemsBetter = [];
  List<String> diaryItemsWorse = [];
  List<Map<String, String>> diaryItems = [];
  String name = "none";
  String email = "";
  String emailTherapist;
  PageController controller;
  int getPageIndex = 0;
  Map<String, List<DateTime>> exDates = {};
  List<DateTime> tempDate = [];
  int exercisesDone = 0;
  int exercisesDoneMax = 0;
  @override
  void initState() {
    controller = PageController(
        // initialPage: 1
        );

    dataFuture = getData(email, true);
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
              PurchasePage(),
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
    this.getPageIndex = pageIndex;
    //causes stutter, but without colors dont refresh, solution PROVIDER
    setState(() {});
  }

  //Ab hier queries
  getData(String email, bool first) async {
    User user = await widget.auth.getCurrentUser();
    emailTherapist = user.email;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (first) email = prefs.getString('lastPatient') ?? "";

    if (email != "") {
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
  }

  _calcExercisesDone() {
    Set<DateTime> temp = {};
    List<DateTime> temp2 = [];
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
      } else {
        exercisesDoneMax = temp2[0].difference(DateTime.now()).inDays.abs() + 1;
        exercisesDone = temp.length;
      }
    });
  }

  getGeneralData(String email) async {
    await databaseReference
        .collection('User')
        .doc('$email')
        .get()
        .then((DocumentSnapshot ds) {
      name = ds['name'];

      return ds;
    });
  }

  getExerciseData(String email) async {
    exercises = [];
    exDates = {};
    await databaseReference
        .collection('User')
        .doc('$email')
        .collection('Exercises')
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((f) async {
        print('${f.data}}');
        if (f["deleted"] != "true") {
          exercises.add(
            ExerciseCardTherapist(
                name: "${f.id}",
                sets: f["sets"],
                reps: f["reps"],
                frequency: f["frequency"],
                done: false,
                email: email,
                doneExerciseCallback: doneExerciseCallback),
          );
        }

        await databaseReference
            .collection('User')
            .doc('$email')
            .collection('Exercises')
            .doc("${f.id}")
            .collection("timesDone")
            .get()
            .then((QuerySnapshot snapshot) {
          tempDate = [];
          snapshot.docs.forEach((g) {
            tempDate.add(DateFormat('d MMM yyyy').parse(g.id));
          });
          exDates["${f.id}"] = tempDate;
        });
        _calcExercisesDone();
      });
    });
  }

  getQuestionnaireData(String email) async {
    questionnaireItems = [];
    await databaseReference
        .collection('User')
        .doc('$email')
        .collection('Questionnaire')
        .orderBy("date")
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((f) {
        print('${f.data}}');
        questionnaireItems.add(
          QuestionnaireItem(
            date: DateFormat('d MMM yyyy').parse(f.id),
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
        .doc('$email')
        .collection('Diary')
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((f) {
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
                'Welcome back!',
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
                if (name != "none") {
                  createExerciseDialog(context)
                      .then((controller) => {addExercise(controller)});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'No patient is selected.',
                    ),
                    backgroundColor: Theme.of(context).accentColor,
                  ));
                }
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
                'Exercises done: $exercisesDone/$exercisesDoneMax days',
                style: TextStyle(fontSize: 18.0),
              ),

              /*FutureBuilder(
                  future: dataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Text(
                        'Exercises done: 1/10',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      );
                    } else {
                      return Text(
                        'Exercises done: 0/10',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      );
                    }
                  }),*/

              SizedBox(height: 16),
              Text(
                'Entries in Diary: ${diaryItems.length}',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Questionnaire filled out: ${questionnaireItems.length}',
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
      MaterialPageRoute(
          builder: (context) =>
              SelectPatientPage(emailTherapist: emailTherapist)),
    );
    if (ds != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('lastPatient', email);
      setState(() {
        name = ds['name'];
        email = ds.id;

        getData(email, false);
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

      email = ds.id;

      await getData(email, false);
    }
  }

  void addExerciseCallback() {
    if (name != "none") {
      createExerciseDialog(context)
          .then((controller) => addExercise(controller));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'No patient is selected.',
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ));
    }
  }

  void doneExerciseCallback(ExerciseCardTherapist card) {
    exercises[exercises.indexOf(card)].done = true;
  }

  addExercise(List<TextEditingController> controller) {
    setState(() {
      try {
        exercises.add(
          ExerciseCardTherapist(
            name: controller[0].text.toString(),
            sets: controller[2].text.toString(),
            reps: controller[1].text.toString(),
            frequency: controller[3].text.toString(),
            done: false,
            email: email,
          ),
        );
        databaseReference
            .collection('User')
            .doc('$email')
            .collection('Exercises')
            .doc('${exercises[exercises.length - 1].name}')
            .set({
          'reps': exercises[exercises.length - 1].reps,
          'sets': exercises[exercises.length - 1].sets,
          'frequency': exercises[exercises.length - 1].frequency,
          'deleted': 'false'
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
          label: 'Home',
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
            icon: new Icon(Icons.assignment), label: 'Questionnaire'),
        BottomNavigationBarItem(icon: new Icon(Icons.book), label: 'Diary'),
        BottomNavigationBarItem(icon: new Icon(Icons.book), label: 'Purchase'),
      ],
      onTap: _onTapChangePage,
      activeColor: Theme.of(context).primaryColor,
    );
  }

  _onTapChangePage(int pageIndex) {
    controller.animateToPage(pageIndex,
        duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<List<TextEditingController>> createExerciseDialog(
      BuildContext context) {
    final _formKey = GlobalKey<FormState>();
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
            content: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name',
                    ),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Value is empty';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: repController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Reps',
                    ),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Value is empty';
                      }
                      try {
                        int.parse(text);
                      } catch (e) {
                        return "Value is not a number";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: setController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Sets',
                    ),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Value is empty';
                      }
                      try {
                        int.parse(text);
                      } catch (e) {
                        return "Value is not a number";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: freqController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Frequency / Day',
                    ),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return 'Value is empty';
                      }
                      try {
                        int.parse(text);
                      } catch (e) {
                        return "Value is not a number";
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    //  submit
                    controller.add(nameController);
                    controller.add(repController);
                    controller.add(setController);
                    controller.add(freqController);
                    Navigator.of(context).pop(controller);
                  }
                },
                child: Text('Submit'),
              )
            ],
          );
        });
  }
}
