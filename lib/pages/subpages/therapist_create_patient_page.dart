import 'package:RehAssistant/widgets/exercise_card.dart';
import 'package:RehAssistant/widgets/small_task_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TherapistCreatePatientPage extends StatefulWidget {
  @override
  _TherapistCreatePatientPageState createState() =>
      _TherapistCreatePatientPageState();
}

class _TherapistCreatePatientPageState
    extends State<TherapistCreatePatientPage> {
  final databaseReference = FirebaseFirestore.instance;
  String name;
  String email;
  List<ExerciseCard> exercises = [];
  bool valDiary = true;
  bool valQuest = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Create Patient"),
        ),
        body: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  right: 24.0, left: 24, top: 8, bottom: 8),
              child: Column(
                children: <Widget>[
                  TextField(
                    onChanged: (value) => name = value,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        labelText: "Name",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    onChanged: (value) => email = value,
                    style: TextStyle(fontSize: 20),
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        labelText: "E-Mail",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0))),
                  ),
                  CheckboxListTile(
                    title: new Text("Activate Diary"),
                    value: valDiary,
                    activeColor: Theme.of(context).primaryColor,
                    checkColor: Colors.white,
                    onChanged: (bool value) {
                      setState(() {
                        valDiary = value;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: new Text("Activate Questionnaire"),
                    value: valQuest,
                    activeColor: Theme.of(context).primaryColor,
                    checkColor: Colors.white,
                    onChanged: (bool value) {
                      setState(() {
                        valQuest = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(
                  right: 24.0, left: 24, top: 0, bottom: 8),
              child: Column(
                children: <Widget>[
                  SmallTaskButton("Add Exercise", () {
                    createExerciseDialog(context).then((controller) => {
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
                            } catch (e) {
                              print(e);
                            }
                          })
                        });
                  }),
                  SizedBox(height: 8),
                  Container(
                    height: 160,
                    child: new ListView.builder(
                        shrinkWrap: true,
                        itemCount: exercises.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          // return exercises[index];
                          return new ListTile(
                            title: Text("${exercises[index].name}"),
                            // leading: Text("${exercises[index].reps} x ${exercises[index].sets} Sets"),
                            subtitle: Text(
                                "${exercises[index].reps} x ${exercises[index].sets} Sets, ${exercises[index].frequency} / Day"),
                          );
                        }),
                  ),
                  SizedBox(height: 32),
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(8.0),
                    color: Theme.of(context).primaryColor,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => TherapistHomePage()),
                        // );
                        _createUserInDB();
                      },
                      child: Text(
                        "Create",
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  _createUserInDB() {
    databaseReference.collection('User').doc('$email').set(
        {'name': '$name', 'diary': '$valDiary', 'questionnaire': '$valQuest'});

    for (var exercise in exercises) {
      databaseReference
          .collection('User')
          .doc('$email')
          .collection('Exercises')
          .doc('${exercise.name}')
          .set({
        'reps': exercise.reps,
        'sets': exercise.sets,
        'frequency': exercise.frequency,
        'deleted':'false'
      });
    }
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
                  )
                ],
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                elevation: 5.0,
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    // TODO submit
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
