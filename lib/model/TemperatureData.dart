import 'package:charts_flutter/flutter.dart' as charts;

class TemperatureData {
  final double index;
  final double temperature;
  final charts.Color barColor;
  TemperatureData(this.index, this.temperature, this.barColor);
}