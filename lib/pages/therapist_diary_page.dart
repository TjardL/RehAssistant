import 'package:flutter/material.dart';

class TherapistDiaryPage extends StatefulWidget {
  final List<Map<String, String>> diaryItems;
  // final List<String> symptomsWorse;

  const TherapistDiaryPage({Key key, this.diaryItems}) : super(key: key);
  _TherapistDiaryPageState createState() =>
      _TherapistDiaryPageState(diaryItems);
}

class _TherapistDiaryPageState extends State<TherapistDiaryPage> {
  // final List<String> symptomsBetter;
  // final List<String> symptomsWorse;
  final List<Map<String, String>> diaryItems;

  _TherapistDiaryPageState(this.diaryItems);
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        DataTable(
          headingRowHeight: 75,
          columns: [
            DataColumn(
                label: Text(
              'Symptoms better',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            )),
            DataColumn(
                label: Text(
              'Symptoms worse',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            )),
          ],
          rows:
              // Loops through diaryItems, each iteration assigning the value to element
              diaryItems
                  .map(
                    ((element) => DataRow(
                          cells: <DataCell>[
                            DataCell(Text(element[
                                "better"])), //Extracting from Map element the value
                            DataCell(Text(element["worse"])),
                          ],
                        )),
                  )
                  .toList(),
        ),
      ],
    );
  }

  void dispose() {
    super.dispose();
  }
}
