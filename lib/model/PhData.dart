import 'package:charts_flutter/flutter.dart' as charts;

class PhData {
  final double index;
  final double pH;
  final charts.Color barColor;
  PhData(this.index, this.pH, this.barColor);
}