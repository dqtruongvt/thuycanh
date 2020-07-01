import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';
import 'package:flutter/rendering.dart';

class DataDayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Khai báo ngày hiện tại
    DateTime now = DateTime.now();

    //Khai báo ngày dạng dd/mm/yyyy
    String today = '${now.day}/${now.month}/${now.year}';

    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(8),

        //Set background
        decoration: BoxDecoration(gradient: BACKGROUND),

        child: Column(
          children: <Widget>[
            //Build title
            Container(
              alignment: Alignment.center,
              child: Text(
                '$today',
                style: TextStyle(fontSize: 36, color: Colors.black),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text('Dữ liệu hiện tại', style: TITLE_STYLE),
            SizedBox(
              height: 10,
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
                          Text('pH', style: DATA_TITLE_STYLE),
                          Text('$ph', style: DATA_STYLE),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text('TDS(ppm)', style: DATA_TITLE_STYLE),
                          Text('$tds', style: DATA_STYLE),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text('Nhiệt độ (°C)', style: DATA_TITLE_STYLE),
                          Text(
                            '$tem',
                            style: DATA_STYLE,
                          )
                        ],
                      )
                    ],
                  );
                } else
                  return CircularProgressIndicator(); //Loading
              },
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Bơm',
                  style: TITLE_STYLE,
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
            SizedBox(
              height: 30,
            ),
            Text(
              'Dữ liệu trong ngày',
              style: TITLE_STYLE,
            ),
            SizedBox(
              height: 10,
            ),
            //Build list data
            StreamBuilder(
              stream: Database.dataRef.onValue,
              builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                if (snapshot.hasData) {
                  List<dynamic> list = snapshot.data.snapshot.value;
                  return _buildDataFromList(list, today);
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
        style: DATA_STYLE,
      ));
      phList.add(Text('${ph.toStringAsFixed(2)}', style: DATA_STYLE));
      tdsList.add(Text('${tds.toStringAsFixed(0)}', style: DATA_STYLE));
      temperatureList
          .add(Text('${temperature.toStringAsFixed(2)}', style: DATA_STYLE));
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
          style: TITLE_STYLE,
        );
}
