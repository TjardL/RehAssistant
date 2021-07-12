import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ExerciseCardTherapist extends StatefulWidget {
  final name;
  final sets;
  final reps;
  final frequency;
  var done;
  final email;

  final void Function(ExerciseCardTherapist) doneExerciseCallback;

  ExerciseCardTherapist(
      {Key key,
      this.name,
      this.sets,
      this.reps,
      this.frequency,
      this.done,
      this.email, this.doneExerciseCallback})
      : super(key: key);
  @override
  _ExerciseCardTherapistState createState() => _ExerciseCardTherapistState(
      this.name, this.sets, this.reps, this.frequency, this.done, this.email);
  // _ExerciseCardState("Wrist Cycles", 3, 15, 3, 0);
}

class _ExerciseCardTherapistState extends State<ExerciseCardTherapist> {
  final name;
  final sets;
  final reps;
  final frequency;
  var done;
  final email;
  bool deleted= false;
  final databaseReference = FirebaseFirestore.instance;

  _ExerciseCardTherapistState(
      this.name, this.sets, this.reps, this.frequency, this.done, this.email);

  @override
  Widget build(BuildContext context) {
    return deleted?Container():Container(
      height: 150,
      child: Card(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
            side: BorderSide(color: Theme.of(context).primaryColor)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 16),
              Text("Repetitions: $sets Sets x $reps Reps"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Frequency: $frequency / Day"),
                  Spacer(
                    flex: 5,
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Container(
                      width: 60,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          databaseReference
                              .collection('User')
                              .doc('$email')
                              .collection('Exercises')
                              .doc('$name')
                              .set({'deleted': 'true'});
                              setState(() {
                                deleted=true;
                              });

                        },
                        child: Text(
                          "Delete",
                          style: TextStyle(fontSize: 8.5),
                        ),
                      )),
                  SizedBox(
                    width: 16,
                  ),
                  Container(
                    width: 60,
                    child: done
                        ? Container(height: 45, child: Icon(Icons.check))
                        : Container(
                            height: 45,
                            child: RaisedButton(
                                color: Theme.of(context).primaryColor,
                                onPressed: () {
                                  databaseReference
                                      .collection('User')
                                      .doc('$email')
                                      .collection('Exercises')
                                      .doc('$name')
                                      .collection('timesDone')
                                      .doc(
                                          '${DateFormat('d MMM yyyy').format(DateTime.now())}')
                                      .set({
                                    'dateDone':
                                        '${DateFormat('d MMM yyyy').format(DateTime.now())}'
                                  });
                                  setState(() {
                                    done=true;
                                   widget.doneExerciseCallback(widget);
                                  });
                                },
                                child: Text(
                                  "Done",
                                  style: TextStyle(
                                      fontSize: 9.5, color: Colors.white),
                                )),
                          ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
