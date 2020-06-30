import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';
import 'package:flutter/rendering.dart';

class DataDayPage extends StatefulWidget {
  @override
  _DataDayPageState createState() => _DataDayPageState();
}

class _DataDayPageState extends State<DataDayPage> {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(8),

        //Set background for container
        decoration: BoxDecoration(gradient: BACKGROUND),

        child: Column(
          children: <Widget>[
            //Build title
            Container(
              alignment: Alignment.center,
              child: Text(
                '${now.day}/${now.month}/${now.year}',
                style: TextStyle(fontSize: 36, color: Colors.black),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Dữ liệu hiện tại',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
            StreamBuilder(
              stream: Database.testRef.onValue,
              builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                if (snapshot.hasData) {
                  Map map = snapshot.data.snapshot.value;
                  var ph = map['ph'];
                  var tds = map['tds'];
                  var tem = map['temperature'];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text('pH',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('$ph', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text('TDS(ppm)',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('$tds', style: TextStyle(fontSize: 20)),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text('Nhiệt độ (°C)',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(
                            '$tem',
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      )
                    ],
                  );
                } else
                  return CircularProgressIndicator();
              },
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                Text(
                  'Bơm',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                StreamBuilder(
                  stream: Database.ref.child('Pump').onValue,
                  builder:
                      (BuildContext context, AsyncSnapshot<Event> snapshot) {
                    return snapshot.hasData
                        ? Switch(
                            value: snapshot.data.snapshot.value,
                            onChanged: (value) {
                              Database.ref.child('Pump').set(value);
                            },
                            activeTrackColor: Colors.lightGreenAccent,
                            activeColor: Colors.green,
                          )
                        : CircularProgressIndicator();
                  },
                ),
              ],
            ),
            Text(
              'Dữ liệu trong ngày',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),

            //Build list data
            StreamBuilder(
              stream: Database.dataRef.onValue,
              builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                if (snapshot.hasData) {
                  String toDay = '${now.day}/${now.month}/${now.year}';
                  List<dynamic> list = snapshot.data.snapshot.value;
                  return _buildDataFromList(list, toDay);
                } else
                  return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}

_buildDataFromList(List<dynamic> list, String toDay) {
  List<Widget> timeList = [];
  List<Widget> phList = [];
  List<Widget> tdsList = [];
  List<Widget> temperatureList = [];
  timeList.add(Text(
    'Thời gian',
    style: TextStyle(fontWeight: FontWeight.bold),
  ));

  phList.add(Text('pH', style: TextStyle(fontWeight: FontWeight.bold)));
  tdsList.add(Text('TDS(ppm)', style: TextStyle(fontWeight: FontWeight.bold)));
  temperatureList.add(
      Text('Nhiệt độ (°C)', style: TextStyle(fontWeight: FontWeight.bold)));

  var hasData = false;

  list.asMap().forEach((key, value) {
    var day = value['day'];

    if (day == toDay) {
      hasData = true;
      var time = value['time'];
      var ph = double.parse(value['ph'].toString());
      var tds = double.parse(value['tds'].toString());
      var temperature = double.parse(value['temperature'].toString());
      timeList.add(Text(
        '$time',
        style: TextStyle(fontSize: 20),
      ));
      phList.add(
          Text('${ph.toStringAsFixed(2)}', style: TextStyle(fontSize: 20)));
      tdsList.add(
          Text('${tds.toStringAsFixed(0)}', style: TextStyle(fontSize: 20)));
      temperatureList.add(Text('${temperature.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 20)));
    }
  });

  return hasData
      ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              children: timeList,
            ),
            Column(
              children: phList,
            ),
            Column(
              children: tdsList,
            ),
            Column(
              children: temperatureList,
            ),
          ],
        )
      : Text(
          'Hôm nay không có dữ liệu. Dữ liệu trống',
          style: TextStyle(fontSize: 25),
        );
}
