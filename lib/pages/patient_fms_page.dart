import 'package:flutter/material.dart';

class PatientFMSPage extends StatefulWidget {
  @override
  _PatientFMSPageState createState() => _PatientFMSPageState();
}

class _PatientFMSPageState extends State<PatientFMSPage> {
  bool formActive = false;
  @override
  Widget build(BuildContext context) {
    return formActive
        ? ListView(
            padding: EdgeInsets.all(16),
            children: <Widget>[
              Center(
                  child: Text(
                '1. Exercise: Deep Squat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )),
              SizedBox(height: 8),
              Text(
                  '1. Stand tall with your feet approximately shoulder width apart and toes pointing forward.'),
              SizedBox(height: 8),
              Text(
                  '2. Grasp the dowel in both hands and place it horizontally on top of your head so your shoulders and elbows are at 90 degrees.'),
              SizedBox(height: 8),
              Text(
                  '3. While maintaining an upright torso, and keeping your heels and the dowel in position, descend as deep as possible.'),
              SizedBox(height: 8),
              Text(
                  '4. Hold the descended position for a count of one, then return to the starting position.'),
              SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Container(
                      height: 200, child: Image.asset('images/fms_stufe1.png')),
                  Container(
                      height: 200, child: Image.asset('images/fms_stufe2.png')),
                  Container(
                      height: 200, child: Image.asset('images/fms_stufe3.png')),
                ],
              ),
               Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                         Radio(
                          value: 0,
                          groupValue: '',
                          onChanged: null,
                        ),
                         Text(
                          '1 Point',
                          style:  TextStyle(fontSize: 16.0),
                        ),
                         Radio(
                          value: 1,
                          groupValue: '2',
                          onChanged: null,
                        ),
                         Text(
                          '2 Points',
                          style:  TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                         Radio(
                          value: 2,
                          groupValue: '3',
                          onChanged: null,
                        ),
                         Text(
                          '3 Points',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    RaisedButton(
            onPressed: () {
              setState(() {
                formActive=false;
              });
              //nicht implementiert
            },
            color: Theme.of(context).primaryColor,
            child: Text(
              "Submit",
              style: TextStyle(color: Colors.white),
            ),
          ),
            ],
          )
        : Center(
            child: Container(
              width: 250,
              height: 100,
              child: RaisedButton(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    side: BorderSide(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  setState(() {
                    formActive = true;
                  });
                },
                child: Text(
                  "Start Movement Screen",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 20.0),
                ),
              ),
            ),
          );
  }
}
