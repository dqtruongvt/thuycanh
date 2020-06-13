import 'package:charts_flutter/flutter.dart' as charts;

class TdsData {
  final double index;
  final double tds;
  final charts.Color barColor;
  TdsData(this.index, this.tds, this.barColor);
}