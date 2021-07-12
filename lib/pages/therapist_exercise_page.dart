import 'package:RehAssistant/widgets/exercise_card_therapist.dart';
import 'package:RehAssistant/widgets/small_task_button.dart';
import "package:flutter/material.dart";
import "package:RehAssistant/widgets/exercise_card.dart";
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
    show CalendarCarousel;
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/classes/event_list.dart';

class TherapistExercisesPage extends StatefulWidget {
  final List<ExerciseCardTherapist> exercises;
  final VoidCallback addExerciseCallback;
  
  final Map<String, List<DateTime>> exDates;
  const TherapistExercisesPage(
      {Key key, this.exercises, this.addExerciseCallback, this.exDates})
      : super(key: key);
  @override
  _TherapistExercisesPageState createState() =>
      _TherapistExercisesPageState(exercises, exDates);
}


class _TherapistExercisesPageState extends State<TherapistExercisesPage> {
  bool visibilityCal = false;
  final List<ExerciseCardTherapist> exercises;

  final Map<String, List<DateTime>> exDates;
  _TherapistExercisesPageState(this.exercises, this.exDates);

  Set<DateTime> dateSet = {};
  Set<DateTime> teilweiseDate = {};
  @override
  void initState() {
    _calcDates();
    super.initState();
  }

  void _calcDates() {
    Set<DateTime> tempDate = {};
    // Set<DateTime> successDate = {};
    print(exDates);
    exDates.forEach((_, list) {
      dateSet.addAll(list);
    });

    exDates.forEach((_, list) {
      tempDate = {};
      tempDate = dateSet.difference(list.toSet());
      dateSet = dateSet.intersection(list.toSet());
      teilweiseDate.addAll(tempDate);
      print(dateSet);
      print(teilweiseDate);
    });
  }

  void _changed(bool visibility, String field) {
    setState(() {
      if (field == "cal") {
        visibilityCal = visibility;
      }
    });
  }
  List<DateTime> getDaysInBeteween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }
  DateTime _currentDate2 = DateTime.now();
  static Widget _presentIcon(String day) => Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.all(
            Radius.circular(1000),
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      );
  static Widget _absentIcon(String day) => Container(
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.all(
            Radius.circular(1000),
          ),
        ),
        child: Center(
          child: Text(
            day,
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
      );

  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {},
  );

  CalendarCarousel _calendarCarouselNoHeader;

  var len;
  double cHeight;
  List<DateTime> listDone = [];
  List<DateTime> listTeilweiseDone= [];
  @override
  Widget build(BuildContext context) {
    listDone = dateSet.toList();
    listTeilweiseDone = teilweiseDate.toList();
    len = listDone.length;
    cHeight = MediaQuery.of(context).size.height;
    for (int i = 0; i < len; i++) {
      _markedDateMap.add(
        listDone[i],
        new Event(
          date: listDone[i],
          title: 'Event 5',
          icon: _presentIcon(
            listDone[i].day.toString(),
          ),
        ),
      );
    }
    len = listTeilweiseDone.length;
    for (int i = 0; i < len; i++) {
      _markedDateMap.add(
        listTeilweiseDone[i],
        new Event(
          date: listTeilweiseDone[i],
          title: 'Event 5',
          icon: _absentIcon(
            listTeilweiseDone[i].day.toString(),
          ),
        ),
      );
    }

    _calendarCarouselNoHeader = CalendarCarousel<Event>(
      height: cHeight * 0.54,
      weekendTextStyle: TextStyle(
        color: Colors.red,
      ),
      todayButtonColor: Colors.blue[200],
      markedDatesMap: _markedDateMap,
      markedDateShowIcon: true,
      markedDateIconMaxShown: 1,
      markedDateMoreShowTotal:
          null, // null for not showing hidden events indicator
      markedDateIconBuilder: (event) {
        return event.icon;
      },
    );

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(24),
        children: <Widget>[
          SmallTaskButton(
            visibilityCal ? "Hide Calendar" : "Show Calendar",
            () {
              visibilityCal ? _changed(false, "cal") : _changed(true, "cal");
            },
          ),
          visibilityCal
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _calendarCarouselNoHeader,
                      markerRepresent(Colors.orange, "Some Exercises done"),
                      markerRepresent(Colors.green, "Exercises done"),
                    ],
                  ),
                )
              : new Container(),
          Divider(),
          SmallTaskButton("Add exercise", () {
            widget.addExerciseCallback();
          }),
          new ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 8),
              itemCount: exercises.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return exercises[index];
              }),
        ],
      ),
    );
  }

  Widget markerRepresent(Color color, String data) {
    return new ListTile(
      leading: new CircleAvatar(
        backgroundColor: color,
        radius: cHeight * 0.022,
      ),
      title: new Text(
        data,
      ),
    );
  }
}
