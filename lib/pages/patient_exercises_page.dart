import "package:flutter/material.dart";
import "package:RehAssistant/widgets/exercise_card.dart";
import 'package:intl/intl.dart';

class PatientExercisesPage extends StatefulWidget {
  final List<ExerciseCard> exercises;

  final Map<String, List<DateTime>> exDates;
  const PatientExercisesPage({Key key, this.exercises, this.exDates}) : super(key: key);
  @override
  _PatientExercisesPageState createState() =>
      _PatientExercisesPageState(exercises,exDates);
}

class _PatientExercisesPageState extends State<PatientExercisesPage> {
  final List<ExerciseCard> exercises;
  DateTime now ;
  DateTime today ;
  final Map<String, List<DateTime>> exDates;
  @override
  initState(){
    now = new DateTime.now();
    today =  DateTime(now.year, now.month, now.day);
    super.initState();
  }
  _PatientExercisesPageState(this.exercises, this.exDates);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new ListView.builder(
            padding: EdgeInsets.all(24),
            itemCount: exercises.length,
            itemBuilder: (BuildContext ctxt, int index) {
              List<DateTime> tmpList = exDates[exercises[index].name];

              if(tmpList.contains(today)){
                
                  exercises[index].done = true;
                
              }
              return exercises[index];
            }));
  }
}
