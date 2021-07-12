import 'package:RehAssistant/model/questionnaire_item.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class TherapistQuestionnairePage extends StatefulWidget {
  final List<QuestionnaireItem> data;

  const TherapistQuestionnairePage({Key key, this.data}) : super(key: key);
  @override
  _TherapistQuestionnairePageState createState() =>
      _TherapistQuestionnairePageState(data);
}

class _TherapistQuestionnairePageState
    extends State<TherapistQuestionnairePage> {
  final List<QuestionnaireItem> data;

  _TherapistQuestionnairePageState(this.data);
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Questionnaires from the last 6 months are shown."),
        ),
        Container(
            height: MediaQuery.of(context).size.height*0.6,
            width: MediaQuery.of(context).size.width,
            child:
                // SimpleTimeSeriesChart.withSampleData()),
                SimpleTimeSeriesChart.withData(data)),
      ],
    );
  }
  void dispose() {

    super.dispose();
  }
}

/// Timeseries chart example

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  List <String> _hiddenIDs = [];
  static List<TimePoint> dataActivity = [];
  static List<TimePoint> dataEnjoyment = [];
  static List<TimePoint> dataMood = [];
  static List<TimePoint> dataSleep = [];
  static List<TimePoint> dataAverage = [];
  static List<TimePoint> dataLeast = [];
  static List<TimePoint> dataNow = [];
  static List<TimePoint> dataWorst = [];

  SimpleTimeSeriesChart(this.seriesList, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory SimpleTimeSeriesChart.withData(List<QuestionnaireItem> data) {
    return new SimpleTimeSeriesChart(
      _createData(data),
      // _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,

      // Optionally pass in a [DateTimeFactory] used by the chart. The factory
      // should create the same type of [DateTime] as the data provided. If none
      // specified, the default creates local date time.
      dateTimeFactory: const charts.LocalDateTimeFactory(),
      // domainAxis: charts.DateTimeAxisSpec(
      //   tickFormatterSpec: charts.AutoDateTimeTickFormatterSpec(
      //     day: charts.TimeFormatterSpec(
      //       format: 'dd MMM',
      //       transitionFormat: 'dd MMM',
      //     ),
      //   ),
      // ),
      behaviors: [
        new charts.SeriesLegend(
          defaultHiddenSeries: _hiddenIDs,position: charts.BehaviorPosition.bottom,
          showMeasures: true,
          desiredMaxColumns: 2,
        ),
        // new charts.ChartTitle('Date',
        //       behaviorPosition: charts.BehaviorPosition.bottom,
        //       // titleStyleSpec: chartsCommon.TextStyleSpec(fontSize: 11),
              
        //       titleOutsideJustification:
        //       charts.OutsideJustification.middleDrawArea
        //       ),
        //   new charts.ChartTitle('Subjective Pain',
        //       behaviorPosition: charts.BehaviorPosition.start,
        //       // titleStyleSpec: chartsCommon.TextStyleSpec(fontSize: 11),
        //       titleOutsideJustification:
        //       charts.OutsideJustification.middleDrawArea)
      ],
    );
  }

  static List<charts.Series<TimePoint, DateTime>> _createData(
      List<QuestionnaireItem> dataInput) {
    List<QuestionnaireItem> data = dataInput;
    dataActivity = [];
    dataEnjoyment = [];
    dataMood = [];
    dataSleep = [];
    dataAverage = [];
    dataLeast = [];
    dataNow = [];
    dataWorst = [];
    //  data.sort((a,b) => a.compareTo(b));
    for (var i = 0; i < data.length; i++) {

      if ((data[i].date.year == DateTime.now().year&&data[i].date.month < DateTime.now().month&&DateTime.now().month-data[i].date.month<7)
      ||(data[i].date.year == DateTime.now().year&&data[i].date.month > DateTime.now().month&&data[i].date.month-DateTime.now().month>6)){
dataActivity.add(TimePoint(data[i].date, data[i].interferenceActivity));
      dataEnjoyment.add(TimePoint(data[i].date, data[i].interferenceEnjoyment));
      dataMood.add(TimePoint(data[i].date, data[i].interferenceMood));
      dataSleep.add(TimePoint(data[i].date, data[i].interferenceSleep));
      dataAverage.add(TimePoint(data[i].date, data[i].painAverage));
      dataLeast.add(TimePoint(data[i].date, data[i].painLeast));
      dataNow.add(TimePoint(data[i].date, data[i].painNow));
      dataWorst.add(TimePoint(data[i].date, data[i].painWorst));
      }
      
    }

    return [
      charts.Series<TimePoint, DateTime>(
        id: 'Inference Activity',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimePoint val, _) => val.time,
        measureFn: (TimePoint val, _) => val.score,
        data: dataActivity,
      ),
      charts.Series<TimePoint, DateTime>(
        id: 'Inference Enjoyment',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimePoint val, _) => val.time,
        measureFn: (TimePoint val, _) => val.score,
        data: dataEnjoyment,
      ),
      charts.Series<TimePoint, DateTime>(
        id: 'Inference Mood',
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        domainFn: (TimePoint val, _) => val.time,
        measureFn: (TimePoint val, _) => val.score,
        data: dataMood,
      ),
      charts.Series<TimePoint, DateTime>(
        id: 'Inference Sleep',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TimePoint val, _) => val.time,
        measureFn: (TimePoint val, _) => val.score,
        data: dataSleep,
      ),
      charts.Series<TimePoint, DateTime>(
        id: 'Pain on Average',
        colorFn: (_, __) => charts.MaterialPalette.indigo.shadeDefault,
        domainFn: (TimePoint val, _) => val.time,
        measureFn: (TimePoint val, _) => val.score,
        data: dataAverage,
      ),
      charts.Series<TimePoint, DateTime>(
        id: 'Pain Least',
        colorFn: (_, __) => charts.MaterialPalette.lime.shadeDefault,
        domainFn: (TimePoint val, _) => val.time,
        measureFn: (TimePoint val, _) => val.score,
        data: dataLeast,
      ),
      charts.Series<TimePoint, DateTime>(
        id: 'Pain Now',
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
        domainFn: (TimePoint val, _) => val.time,
        measureFn: (TimePoint val, _) => val.score,
        data: dataNow,
      ),
      charts.Series<TimePoint, DateTime>(
        id: 'Pain Worst',
        colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
        domainFn: (TimePoint val, _) => val.time,
        measureFn: (TimePoint val, _) => val.score,
        data: dataWorst,
      ),
    ];
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final dataExample = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 5),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 6),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 4),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 3),
    ];
    final datatest2 = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 7),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 7),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 7),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 4),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: dataExample,
      ),
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'AveragePain',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: datatest2,
      )
    ];
  }
  
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}

class TimePoint {
  final DateTime time;
  final double score;

  TimePoint(this.time, this.score);
}
