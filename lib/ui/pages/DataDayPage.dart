import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';
import 'dart:math';

class DataDayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String day = now.day.toString();
    if (day.length == 1) day = '0' + day;
    String month = now.month.toString();
    if (month.length == 1) month = '0' + month;
    String year = now.year.toString();

    //Khai báo ngày dạng dd-mm-yyyy
    String today = day + '-' + month + '-' + year;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(gradient: BACKGROUND),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8, right: 8, top: 4),
          child: CustomScrollView(
            slivers: [
              SliverList(
                  delegate: SliverChildListDelegate([
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '$today',
                    style: TextStyle(fontSize: 36),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                    alignment: Alignment.center,
                    child: Text('Dữ liệu hiện tại', style: TITLE_STYLE)),
                SizedBox(
                  height: 10,
                ),
                StreamBuilder(
                  stream: dataTestRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return CircularProgressIndicator();
                    else {
                      DocumentSnapshot ds = snapshot.data;
                      Map map = ds.data;
                      return _buildTestFromMap(map);
    }
                  },
                ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          FloatingActionButton.extended(
                            onPressed: () async {
                              var random = new Random();
                              Firestore.instance
                                  .collection('test')
                                  .document('read')
                                  .updateData({'status': random.nextInt(1000)});
                            },
                            label: Text('Cập nhật',style: TextStyle(fontSize: 20),),
                          ),
                      ]
                    ),
                SizedBox(
                  height: 30,
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                  Text(
                    'Bơm',
                    style: TITLE_STYLE,
                  ),
                  StreamBuilder(
                    stream: pumpTestRef.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return CircularProgressIndicator();
                      else {
                        DocumentSnapshot ds = snapshot.data;
                        Map map = ds.data;
                        var active = map['active'];
                        return _buildSwitchPump(active);
                      }
                    },
                  ),
                ]),
                SizedBox(
                  height: 30,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Dữ liệu trong ngày',
                    style: TITLE_STYLE,
                  ),
                ),
                SizedBox(height: 10),
                StreamBuilder(
                  stream: orderDataRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return CircularProgressIndicator();
                    else {
                      QuerySnapshot list = snapshot.data;
                      List<DocumentSnapshot> documents = list.documents;
                      List<Map<String, dynamic>> maps =
                          documents.map((e) => e.data).toList();
                      return _buildDataFromMap(maps, today);
                    }
                  },
                )
              ]))
            ],
          ),
        )
      ],
    );
  }
}

_buildDataFromMap(List<Map<String, dynamic>> maps, String today) {
  List<Widget> list = [];
  list.add(DefaultTextStyle(
      style: TextStyle(fontWeight: FontWeight.bold),
      child: Row(
        children: [
          Expanded(child: Text('Thời gian ')),
          Expanded(child: Text('pH ')),
          Expanded(child: Text('TDS(ppm)')),
          Expanded(child: Text('Nhiệt độ (°C)')),
        ],
      )));
  maps.forEach((map) {
    if (map['day'] == today) {
      list.add(DefaultTextStyle(
          style: DATA_STYLE,
          child: Row(
            children: [
              Expanded(child: Text('${map['time']}')),
              Expanded(child: Text('${map['ph']}')),
              Expanded(child: Text('${map['tds']}')),
              Expanded(child: Text('${double.parse(map['temperature'].toString()).toStringAsFixed(2)}')),
            ],
          )));
    }
  });
  return Column(children: list);
}

_buildTestFromMap(Map map) {
  return Column(
    children: [
      DefaultTextStyle(
        style: TextStyle(fontWeight: FontWeight.bold),
        child: Row(
          children: [
            Expanded(
                child: Text(
              'pH',
            )),
            Expanded(
              child: Text(
                'TDS(ppm)',
              ),
            ),
            Expanded(
              child: Text('Nhiệt độ (°C)'),
            ),
          ],
        ),
      ),
      DefaultTextStyle(
        style: DATA_STYLE,
        child: Row(
          children: [
            Expanded(
                child: Text(
              '${double.parse(map['ph'].toString()).toStringAsFixed(2)}',
            )),
            Expanded(
              child: Text('${map['tds'].toString()}'),
            ),
            Expanded(
              child: Text('${double.parse(map['temperature'].toString()).toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    ],
  );
}

_buildSwitchPump(bool active) {
  return Switch(
      activeTrackColor: Colors.lightGreen,
      activeColor: Colors.green,
      value: active,
      onChanged: (value) {
        Firestore.instance
            .collection('test')
            .document('pump')
            .updateData({'active': value});
      });
}
