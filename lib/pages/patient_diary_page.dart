import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PatientDiaryPage extends StatefulWidget {
  final String email;

  const PatientDiaryPage({Key key, this.email}) : super(key: key);
  @override
  _PatientDiaryPageState createState() => _PatientDiaryPageState(email);
}

class _PatientDiaryPageState extends State<PatientDiaryPage> {
  final String email;
  String txtWorse;
  String txtBetter;
  final databaseReference = FirebaseFirestore.instance;
  _PatientDiaryPageState(this.email);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        children: <Widget>[
          Text(
            "Please reflect on your day, have there been specific activities that have made the symptoms better or worse?",
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Text("Activities / Situations that made Symptoms worse:"),
          SizedBox(height: 8),
          TextField(
            onChanged: (value) => txtWorse = value,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0))),
          ),
          SizedBox(height: 16),
          Text("Activities / Situations that made Symptoms better:"),
          SizedBox(height: 8),
          TextField(
            onChanged: (value) => txtBetter = value,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0))),
          ),
          SizedBox(height: 16),
          RaisedButton(
            onPressed: () {
              databaseReference
                  .collection('User')
                  .doc('$email')
                  .collection('Diary')
                  .doc('${DateFormat('d MMM yyyy').format(DateTime.now())}')
                  .set({'symptoms_worse': '$txtWorse', 'symptoms_better': '$txtBetter'});
            },
            color: Theme.of(context).primaryColor,
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
