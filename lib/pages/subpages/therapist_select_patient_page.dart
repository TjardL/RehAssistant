import 'package:RehAssistant/widgets/small_task_button.dart';
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
  bool showFilter = false;
  bool showArchived = false;
  final databaseReference = FirebaseFirestore.instance;
  void initState() {
    dataFuture = getDataPatients();
    super.initState();
  }

  getDataPatients() async {
    print(widget.emailTherapist);
    await FirebaseFirestore.instance
        .collection("User")
        .where("emailTherapist", isEqualTo: "${widget.emailTherapist}")
        .get()
        .then((QuerySnapshot qs) {
      querySnapshot = qs;
      return qs;
    });
  }

  getPatientItems(QuerySnapshot snapshot) {
    var archiveText;
    showArchived ? archiveText = "" : archiveText = "true";
    return snapshot.docs
        .map((doc) => (doc["archived"] != archiveText)
            ? ListTile(
                title: new Text(doc["name"]),
                subtitle: new Text(doc.id),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("Archive patient"),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: Text("Second"),
                      value: 2,
                    )
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 1:
                        databaseReference
                            .collection('User')
                            .doc('${doc.id}')
                            .set({'archived': 'true'});
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            '${doc["name"]} archived and will not show up here next time.',
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ));
                        break;
                      default:
                        print("def");
                    }
                  },
                ),
                onTap: () {
                  Navigator.pop(context, doc);
                },
              )
            : Container())
        .toList();
  }

  Widget _showFilter() {
    return Column(
      children: [
        Container(
          width: 300,
          child: CheckboxListTile(
              contentPadding: EdgeInsets.all(8),
              title: Text("Show archived patients"),
              value: showArchived,
              onChanged: (val) {
                setState(() {
                  showArchived = !showArchived;
                });
              }),
        ),
        
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Patient"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  showFilter = !showFilter;
                });
              },
              icon: Icon(Icons.filter_alt))
        ],
      ),
      body: FutureBuilder(
          future: dataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  if (showFilter) _showFilter(),
                  ListView(
                    shrinkWrap: true,
                    children: getPatientItems(querySnapshot),
                  ),
                ],
              );
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }
}
