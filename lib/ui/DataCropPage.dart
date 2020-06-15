import 'package:flutter/material.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:thuycanh/model/PhData.dart';
import 'package:thuycanh/model/TdsData.dart';
import 'package:thuycanh/model/TemperatureData.dart';

// ignore: must_be_immutable
class DataCropPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(gradient: BACKGROUND),
        child: Column(
          children: <Widget>[
            //Build list data
            Flexible(
                child: FutureBuilder<Map>(
                  future: getData(),
                  builder: (context, snap) {
                    var map = snap.data ?? {};
                    return _buildDataFromMap(map);
                  },
                ),
                flex: 9),

            //Build button show chart
            Flexible(
                child: FutureBuilder<Map>(
                    future: getData(),
                    builder: (context, snap) {
                      var map = snap.data ?? {};
                      return _buildChartFromMap(context, map);
                    }),
                flex: 1)
          ],
        ));
  }
}

Future<Map> getData() async {
  Map map = Map();
  Map count = Map();
  var snap = await Database.getDataRef();
  (snap.value as List<dynamic>).forEach((item) {
    var day = item['day'];
    var ph = double.parse(item['ph'].toString());
    var tds = double.parse(item['tds'].toString());
    var temperature = double.parse(item['temperature'].toString());

    //Xử lí dữ liệu
    if (map[day] == null) {
      map[day] = {'ph': ph, 'tds': tds, 'temperature': temperature};
    } else {
      (map[day] as Map)['ph'] = (map[day] as Map)['ph'] + ph;
      (map[day] as Map)['tds'] = (map[day] as Map)['tds'] + tds;
      (map[day] as Map)['temperature'] =
          (map[day] as Map)['temperature'] + temperature;
    }
    if (count[day] == null) {
      count[day] = {'ph': 1, 'tds': 1, 'temperature': 1};
    } else {
      (count[day] as Map)['ph'] = (count[day] as Map)['ph'] + 1;
      (count[day] as Map)['tds'] = (count[day] as Map)['tds'] + 1;
      (count[day] as Map)['temperature'] =
          (count[day] as Map)['temperature'] + 1;
    }
  });
  var days = map.keys.toList();
  days.forEach((day) {
    (map[day] as Map)['ph'] =
        (map[day] as Map)['ph'] / (count[day] as Map)['ph'];
    (map[day] as Map)['tds'] =
        (map[day] as Map)['tds'] / (count[day] as Map)['tds'];
    (map[day] as Map)['temperature'] =
        (map[day] as Map)['temperature'] / (count[day] as Map)['temperature'];
  });

//Save data in firebase
  map.forEach((day, value) {
    Database.ref.child('crop/data').child(fromDate(day)).set(value);
  });
  return map;
}

_buildDataFromMap(Map map) {
  List<Widget> list = [];
  list.add(DefaultTextStyle(
    style: TEXT_STYLE,
    child: Row(
      children: <Widget>[
        Expanded(child: Text('Ngày'), flex: 2),
        Expanded(child: Text('pH'), flex: 1),
        Expanded(child: Text('tds'), flex: 1),
        Expanded(child: Text('nhiệt độ'), flex: 2),
      ],
    ),
  ));
  map.forEach((key, value) {
    list.add(DefaultTextStyle(
      style: TEXT_STYLE,
      child: Row(
        children: <Widget>[
          Expanded(child: Text('$key'), flex: 2),
          Expanded(child: Text('${value['ph']}'), flex: 1),
          Expanded(child: Text('${value['tds']}'), flex: 1),
          Expanded(
            child: Text('${value['temperature']}'),
            flex: 2,
          ),
        ],
      ),
    ));
  });
  return Container(
    padding: EdgeInsets.all(8),
    child: Column(
      children: list,
    ),
  );
}

_buildChartFromMap(BuildContext context, Map map) {
  List<PhData> pHData = [];
  List<TdsData> tdsData = [];
  List<TemperatureData> temData = [];
  var data = map.values.toList();
  data.asMap().forEach((index, value) {
    pHData.add(PhData(index.toDouble(), value['ph'],
        charts.ColorUtil.fromDartColor(Colors.blue)));
    tdsData.add(TdsData(index.toDouble(), value['tds'],
        charts.ColorUtil.fromDartColor(Colors.red)));
    temData.add(TemperatureData(index.toDouble(), value['temperature'],
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

  var dialog = Dialog(
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

  return FlatButton(
    onPressed: () {
      showDialog(context: context, builder: (_) => dialog);
    },
    child: Container(
      child: Text('Show chart'),
      alignment: Alignment.center,
      color: Colors.blue,
      width: 200,
      height: 50,
    ),
  );
}
