import 'package:flutter/material.dart';

import '../../model/PhData.dart';
import '../../model/TdsData.dart';
import '../../model/TemperatureData.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartWidget extends StatelessWidget {
  final Map map;

  const ChartWidget({Key key, this.map}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<PhData> pHData = [];
    List<TdsData> tdsData = [];
    List<TemperatureData> temData = [];

    var data = map.values.toList();
    data.asMap().forEach((index, value) {
      pHData.add(PhData(index.toDouble(), double.parse(value['ph'].toString()),
          charts.ColorUtil.fromDartColor(Colors.blue)));
      tdsData.add(TdsData(
          index.toDouble(),
          double.parse(value['tds'].toString()),
          charts.ColorUtil.fromDartColor(Colors.red)));
      temData.add(TemperatureData(
          index.toDouble(),
          double.parse(value['temperature'].toString()),
          charts.ColorUtil.fromDartColor(Colors.green)));
    });

    List<charts.Series<PhData, double>> seriesPh = [
      charts.Series(
          id: 'pH',
          data: pHData,
          domainFn: (PhData data, _) => data.index,
          measureFn: (PhData data, _) => data.pH,
          colorFn: (PhData data, _) => data.barColor)
    ];

    List<charts.Series<TdsData, double>> seriesTds = [
      charts.Series(
          id: 'tds',
          data: tdsData,
          domainFn: (TdsData data, _) => data.index,
          measureFn: (TdsData data, _) => data.tds,
          colorFn: (TdsData data, _) => data.barColor)
    ];

    List<charts.Series<TemperatureData, double>> seriesTem = [
      charts.Series(
          id: 'tds',
          data: temData,
          domainFn: (TemperatureData data, _) => data.index,
          measureFn: (TemperatureData data, _) => data.temperature,
          colorFn: (TemperatureData data, _) => data.barColor)
    ];

    return Dialog(
      child: Container(
        child: Column(
          children: <Widget>[
            Flexible(
              child: charts.LineChart(
                seriesPh,
                behaviors: [
                  charts.ChartTitle('pH chart',
                      behaviorPosition: charts.BehaviorPosition.bottom,
                      titleStyleSpec: charts.TextStyleSpec(fontSize: 20),
                      titleOutsideJustification:
                          charts.OutsideJustification.middleDrawArea),
                ],
                animate: true,
              ),
            ),
            Flexible(
              child: charts.LineChart(
                seriesTds,
                behaviors: [
                  charts.ChartTitle('Tds chart',
                      behaviorPosition: charts.BehaviorPosition.bottom,
                      titleStyleSpec: charts.TextStyleSpec(fontSize: 20),
                      titleOutsideJustification:
                          charts.OutsideJustification.middleDrawArea),
                ],
                animate: true,
              ),
            ),
            Flexible(
              child: charts.LineChart(
                seriesTem,
                behaviors: [
                  charts.ChartTitle('Temperature chart',
                      behaviorPosition: charts.BehaviorPosition.bottom,
                      titleStyleSpec: charts.TextStyleSpec(fontSize: 20),
                      titleOutsideJustification:
                          charts.OutsideJustification.middleDrawArea),
                ],
                animate: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
