import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientQuestionnairePage extends StatefulWidget {
   final String email;

  const PatientQuestionnairePage({Key key, this.email}) : super(key: key);

  @override
  _PatientQuestionnairePageState createState() =>
      _PatientQuestionnairePageState(email);
}

class _PatientQuestionnairePageState extends State<PatientQuestionnairePage> {
   final String email;

  double ratingWorst = 1;
  double ratingLeast = 1;
  double ratingAverage = 1;
  double ratingNow = 1;
  double ratingGeneralActivity = 1;
  double ratingSleep = 1;
  double ratingEnjoyment = 1;
  double ratingMood = 1;
  bool formActive = false;
  final databaseReference = FirebaseFirestore.instance;

  _PatientQuestionnairePageState(this.email);
  @override
  Widget build(BuildContext context) {
    return formActive
        ? ListView(
            padding: EdgeInsets.all(16),
            children: <Widget>[
              Text(
                  "Please rate your pain that best describes your pain at its WORST in the last week."),
              Slider(
                value: ratingWorst,
                onChanged: (newRating) {
                  setState(() => ratingWorst = newRating);
                },
                divisions: 9,
                max: 10,
                min: 1,
                label: "$ratingWorst",
              ),
              Text(
                  "Please rate your pain that best describes your pain at its Least in the last week."),
              Slider(
                value: ratingLeast,
                onChanged: (newRating) {
                  setState(() => ratingLeast = newRating);
                },
                divisions: 9,
                max: 10,
                min: 1,
                label: "$ratingLeast",
              ),
              Text(
                  "Please rate your pain that best describes your pain on Average in the last week."),
              Slider(
                value: ratingAverage,
                onChanged: (newRating) {
                  setState(() => ratingAverage = newRating);
                },
                divisions: 9,
                max: 10,
                min: 1,
                label: "$ratingAverage",
              ),
              Text(
                  "Please rate your pain that best describes your pain right now."),
              Slider(
                value: ratingNow,
                onChanged: (newRating) {
                  setState(() => ratingNow = newRating);
                },
                divisions: 9,
                max: 10,
                min: 1,
                label: "$ratingNow",
              ),
              Text(
                  "Check the one number that describes how, during the past week, pain has interfered with your general activity."),
              Slider(
                value: ratingGeneralActivity,
                onChanged: (newRating) {
                  setState(() => ratingGeneralActivity = newRating);
                },
                divisions: 9,
                max: 10,
                min: 1,
                label: "$ratingGeneralActivity",
              ),
              Text(
                  "Check the one number that describes how, during the past week, pain has interfered with your mood."),
              Slider(
                value: ratingMood,
                onChanged: (newRating) {
                  setState(() => ratingMood = newRating);
                },
                divisions: 9,
                max: 10,
                min: 1,
                label: "$ratingMood",
              ),
              Text(
                  "Check the one number that describes how, during the past week, pain has interfered with your sleep."),
              Slider(
                value: ratingSleep,
                onChanged: (newRating) {
                  setState(() => ratingSleep = newRating);
                },
                divisions: 9,
                max: 10,
                min: 1,
                label: "$ratingSleep",
              ),
              Text(
                  "Check the one number that describes how, during the past week, pain has interfered with your enjoyment in life."),
              Slider(
                value: ratingEnjoyment,
                onChanged: (newRating) {
                  setState(() => ratingEnjoyment = newRating);
                },
                divisions: 9,
                max: 10,
                min: 1,
                label: "$ratingEnjoyment",
              ),
              RaisedButton(
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    "Send Form",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    databaseReference
                  .collection('User')
                  .doc('$email')
                  .collection('Questionnaire')
                  .doc('${DateFormat('d MMM yyyy').format(DateTime.now())}')
                  .set({'pain_worst': '$ratingWorst'
                  , 'pain_least': '$ratingLeast'
                  , 'pain_average': '$ratingAverage'
                  , 'pain_now': '$ratingNow'
                  , 'interference_activity': '$ratingGeneralActivity'
                  , 'interference_mood': '$ratingMood'
                  , 'interference_sleep': '$ratingSleep'
                  , 'interference_enjoyment': '$ratingEnjoyment'
                  , 'date': '${DateFormat('d MMM yyyy').format(DateTime.now())}'
                  });
                  setState(() {
                    formActive = false;
                  });
                  
                  }),
            ],
          )
        : Center(
          child: Container(

              width: 250,
              height:100,
              child: RaisedButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Theme.of(context).primaryColor)),
                //color: Theme.of(context).primaryColor,

                onPressed: () {
                  setState(() {
                    formActive = true;
                  });
                },
                child: Text(
                  "Start Questionnaire",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 20.0),
                ),
              ),
            ),
        );
  }
}
