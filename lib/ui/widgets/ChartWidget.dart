import 'package:flutter/material.dart';

import '../../model/PhData.dart';
import '../../model/TdsData.dart';
import '../../model/TemperatureData.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ChartWidget extends StatelessWidget {
  final List<PhData> phData;
  final List<TdsData> tdsData;
  final List<TemperatureData> temperatureData;
  const ChartWidget({Key key, this.phData, this.tdsData, this.temperatureData})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<charts.Series<PhData, double>> seriesPh = [
      charts.Series(
          id: 'pH',
          data: phData,
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
          data: temperatureData,
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
                  charts.ChartTitle('Biểu đồ pH',
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
                  charts.ChartTitle('Biểu đồ TDS(ppm)',
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
                  charts.ChartTitle('Biểu đồ nhiệt độ(°C)',
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
