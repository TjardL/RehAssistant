import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectPatientPage extends StatefulWidget {
  final String emailTherapist;

  const SelectPatientPage({Key key, this.emailTherapist}) : super(key: key);
  @override
  _SelectPatientPageState createState() => _SelectPatientPageState();
}

class _SelectPatientPageState extends State<SelectPatientPage> {
  Future dataFuture;
  QuerySnapshot querySnapshot;
  final databaseReference = Firestore.instance;
  void initState() {
    
    dataFuture = getDataPatients();
    super.initState();
  }
  getDataPatients()async{
    print(widget.emailTherapist);
    await Firestore.instance.collection("User").where("emailTherapist", isEqualTo: "${widget.emailTherapist}").getDocuments().then((QuerySnapshot qs) {
      querySnapshot = qs;
      return qs;
    });

    
  }

  getPatientItems(QuerySnapshot snapshot) {
    return snapshot.documents
        .map((doc) => new ListTile(title: new Text(doc["name"]), subtitle: new Text(doc.documentID),
        onTap: (){
          Navigator.pop(context, doc);
        },))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
        title: Text("Select Patient"),
          ),
        body: 
        FutureBuilder(
          future: dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView(
                children:
                  
                  
                  getPatientItems(querySnapshot),
                
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
      
    );
  }
}