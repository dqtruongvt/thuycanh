import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:thuycanh/ui/helper/Helper.dart';
import 'package:thuycanh/database/Database.dart';
import 'package:thuycanh/ui/widgets/ChartWidget.dart';
import 'package:thuycanh/ui/widgets/MyButton.dart';

import '../../configure/Configure.dart';

class CropWidget extends StatefulWidget {
  final String total;
  final int startId;
  final int endId;

  const CropWidget({Key key, this.total, this.startId, this.endId})
      : super(key: key);
  @override
  _CropWidgetState createState() => _CropWidgetState();
}

class _CropWidgetState extends State<CropWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Divider(
          height: 20,
          thickness: 5,
          color: Colors.grey,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              "Mùa ${widget.total}",
              style: TITLE_STYLE,
            ),
            MyButton(
              text: "Biểu đồ",
              height: 40,
              width: 80,
              onPressed: () {
                Database.saveRef
                    .child('data/crop_${widget.total}')
                    .once()
                    .then((snapSave) {
                  Database.cropRef.once().then((snapCrop) {
                    Map data = snapSave.value;

                    var startId = int.parse(data['startId'].toString());
                    var endId = int.parse(data['endId'].toString());

                    Map map = snapCrop.value;
                    Map sortMap = {};
                    if (endId == -1) endId = map.length - 1;
                    sortMap.addAll((map));
                    var index = -1;
                    Map result = Map();
                    sortMap.forEach((key, value) {
                      index++;
                      if (startId <= index && index <= endId) {
                        result[key] = value;
                      }
                    });

                    var dialog = ChartWidget(
                      map: result,
                    );
                    showDialog(context: context, builder: (_) => dialog);
                  });
                });
              },
            ),
          ],
        ),
        StreamBuilder(
          stream: Database.cropRef.onValue,
          builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
            return snapshot.hasData
                ? _buildDataFromList(
                    snapshot.data.snapshot.value, widget.startId, widget.endId)
                : CircularProgressIndicator();
          },
        ),
        StreamBuilder(
            stream: Database.saveRef
                .child('data/crop_${widget.total}/endId')
                .onValue,
            builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
              return snapshot.hasData
                  ? snapshot.data.snapshot.value == -1
                      ? Text(
                          "Mùa ${widget.total} chưa kết thúc",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        )
                      : Text(
                          "Mùa ${widget.total} đã kết thúc",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        )
                  : CircularProgressIndicator();
            }),
        Divider(
          height: 20,
          thickness: 5,
          color: Colors.grey,
        )
      ],
    );
  }
}

_buildDataFromList(Map map, int startId, int endId) {
  var sortMap = {};
  sortMap.addAll(Helper().sortMapByDay(map));
  List<Widget> dayList = [];
  List<Widget> phList = [];
  List<Widget> tdsList = [];
  List<Widget> temperatureList = [];
  dayList.add(Text(
    'Ngày',
    style: TextStyle(fontWeight: FontWeight.bold),
  ));

  phList.add(Text(
    'pH',
    style: TextStyle(fontWeight: FontWeight.bold),
  ));

  tdsList.add(Text(
    'TDS(ppm)',
    style: TextStyle(fontWeight: FontWeight.bold),
  ));

  temperatureList.add(Text(
    'Nhiệt độ (°C)',
    style: TextStyle(fontWeight: FontWeight.bold),
  ));

  if (map.length - startId >= 0) {
    var index = -1;
    sortMap.forEach((key, value) {
      var ph = double.parse(value['ph'].toString());
      var tds = double.parse(value['tds'].toString());
      var tem = double.parse(value['temperature'].toString());
      index++;
      if (endId == -1) {
        if (index >= startId) {
          dayList.add(Text(
            '${Helper().reverseDate(key)}',
            style: DATA_STYLE,
          ));
          phList.add(Text('${ph.toStringAsFixed(2)}', style: DATA_STYLE));
          tdsList.add(Text('${tds.toStringAsFixed(0)}', style: DATA_STYLE));
          temperatureList
              .add(Text('${tem.toStringAsFixed(2)}', style: DATA_STYLE));
        }
      } else if (startId <= index && endId >= index) {
        dayList.add(Text(
          '${Helper().reverseDate(key)}',
          style: DATA_STYLE,
        ));
        phList.add(Text('${ph.toStringAsFixed(2)}', style: DATA_STYLE));
        tdsList.add(Text('${tds.toStringAsFixed(0)}', style: DATA_STYLE));
        temperatureList
            .add(Text('${tem.toStringAsFixed(2)}', style: DATA_STYLE));
      }
    });
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(
        children: dayList,
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
  );
}
