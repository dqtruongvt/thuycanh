import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';
import 'package:thuycanh/model/PhData.dart';
import 'package:thuycanh/model/TdsData.dart';
import 'package:thuycanh/model/TemperatureData.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:toast/toast.dart';

class ManageCropPage extends StatefulWidget {
  @override
  _ManageCropPageState createState() => _ManageCropPageState();
}

class _ManageCropPageState extends State<ManageCropPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(gradient: BACKGROUND),
          child: SafeArea(
            child: Column(children: <Widget>[
              StreamBuilder(
                stream: Database.saveRef.child('data').onValue,
                builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
                  return snapshot.hasData
                      ? snapshot.data.snapshot.value == null
                          ? Text('Bạn chưa có vụ mùa nào. Dữ liệu trống',
                              style:
                                  TextStyle(fontSize: 32, color: Colors.white))
                          : _buildCropFromData(snapshot.data.snapshot.value)
                      : CircularProgressIndicator();
                },
              ),
              Container(
                margin: EdgeInsets.all(8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: _buildFlatButton(
                            content: 'TẠO VỤ',
                            onPressed: () {
                              _onCreateCrop(context);
                            })),
                    Expanded(
                        child: _buildFlatButton(
                            content: 'KẾT THÚC',
                            onPressed: () {
                              _onFinishCrop(context);
                            })),
                  ],
                ),
              ),
            ]),
          )),
    );
  }

  _onFinishCrop(BuildContext context) {
    _buildAlertDialog(
      context: context,
      content: 'Bạn có muốn kết thúc vụ không',
      onNo: () => _dialogExit(context: context),
      onYes: () {
        _dialogExit(context: context);

        Database.cropRef.once().then((snapCrop) {
          Map map = snapCrop.value;
          var endId = map.length - 1;
          Database.saveRef.once().then((snapSave) {
            Map data = snapSave.value;
            var total = data['totalCrop'];
            var onCrop = data['onCrop'];

            if (!onCrop) {
              Toast.show("Bạn chưa tạo vụ mới", context);
            } else {
              Database.saveRef
                  .child('data/crop_$total')
                  .update({'endId': endId});
              Database.saveRef
                  .child('startId')
                  .runTransaction((mutableData) async {
                mutableData.value = endId + 1;
                return mutableData;
              });
              Database.saveRef.child('onCrop').set(false);
            }
          });
        });
      },
    );
  }

  void _onCreateCrop(BuildContext context) {
    _buildAlertDialog(
        context: context,
        content: 'Bạn có muốn tạo vụ mới không',
        onNo: () => _dialogExit(context: context),
        onYes: () {
          _dialogExit(context: context);

          Database.saveRef.once().then((snap) {
            Map value = snap.value;
            var startId = value['startId'];
            var endId = value['endId'];

            var onCrop = value['onCrop'];

            if (onCrop) {
              Toast.show("Mùa vụ của bạn chưa kết thúc", context);
            } else {
              Database.saveRef
                  .child('totalCrop')
                  .runTransaction((mutableData) async {
                mutableData.value = (mutableData.value ?? 0) + 1;
                return mutableData;
              }).then((result) => Database.saveRef
                          .child('data/crop_${result.dataSnapshot.value}')
                          .set({
                        'startId': startId,
                        'endId': endId,
                      }));

              Database.saveRef.child('onCrop').set(true);
            }
          });
        });
  }

  _buildFlatButton(
          {@required String content,
          @required VoidCallback onPressed,
          Color color = Colors.blue,
          double textSize = 10,
          Color textColor = Colors.white,
          double height = 50,
          double width = 200}) =>
      FlatButton(
          onPressed: onPressed,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(8),
                height: height,
                width: width,
                color: color,
                child: Text(
                  content,
                  style: TextStyle(color: textColor, fontSize: textSize),
                )),
          ));

  _buildAlertDialog({
    @required String content,
    @required VoidCallback onNo,
    @required VoidCallback onYes,
    @required BuildContext context,
  }) {
    var dialog = AlertDialog(
      content: Text(content),
      actions: <Widget>[
        _buildFlatButton(
            content: 'Có',
            onPressed: onYes,
            height: 40,
            width: 75,
            color: Colors.blue),
        _buildFlatButton(
            content: 'Không',
            onPressed: onNo,
            height: 40,
            width: 75,
            color: Colors.blue),
      ],
    );
    showDialog(
        context: context, builder: (_) => dialog, barrierDismissible: true);
  }

  _dialogExit({@required BuildContext context}) {
    Navigator.of(context).pop();
  }
}

_buildCropFromData(Map map) {
  List<Widget> list = [];
  map.forEach((key, value) {
    var total = key.toString()[key.toString().length - 1];
    var startId = value['startId'];

    var endId = value['endId'];
    list.add(CropWidget(total: total, startId: startId, endId: endId));
  });
  return Column(
    children: list,
  );
}

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
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            MaterialButton(
                onPressed: () {
                  Database.saveRef
                      .child('data/crop_${widget.total}')
                      .once()
                      .then((snap) {
                    Database.cropRef.once().then((snap2) {
                      Map data = snap.value;

                      var startId = int.parse(data['startId'].toString());
                      var endId = int.parse(data['endId'].toString());
                      if (endId == -1) endId = data.length - 1;

                      Map map = snap2.value;
                      Map sortMap = {};
                      sortMap.addAll(_sortMapByDay(map));
                      var index = -1;
                      Map result = Map();
                      sortMap.forEach((key, value) {
                        index++;
                        if (startId <= index && index <= endId) {
                          result[key] = value;
                        }
                      });
                      List<PhData> pHData = [];
                      List<TdsData> tdsData = [];
                      List<TemperatureData> temData = [];
                      var dataChart = result.values.toList();
                      dataChart.asMap().forEach((index, value) {
                        pHData.add(PhData(
                            index.toDouble(),
                            double.parse(value['ph'].toString()),
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
                            measureFn: (TemperatureData data, _) =>
                                data.temperature,
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
                                        behaviorPosition:
                                            charts.BehaviorPosition.bottom,
                                        titleStyleSpec:
                                            charts.TextStyleSpec(fontSize: 20),
                                        titleOutsideJustification: charts
                                            .OutsideJustification
                                            .middleDrawArea),
                                  ],
                                  animate: true,
                                ),
                              ),
                              Flexible(
                                child: charts.LineChart(
                                  seriesTds,
                                  behaviors: [
                                    charts.ChartTitle('Tds chart',
                                        behaviorPosition:
                                            charts.BehaviorPosition.bottom,
                                        titleStyleSpec:
                                            charts.TextStyleSpec(fontSize: 20),
                                        titleOutsideJustification: charts
                                            .OutsideJustification
                                            .middleDrawArea),
                                  ],
                                  animate: true,
                                ),
                              ),
                              Flexible(
                                child: charts.LineChart(
                                  seriesTem,
                                  behaviors: [
                                    charts.ChartTitle('Temperature chart',
                                        behaviorPosition:
                                            charts.BehaviorPosition.bottom,
                                        titleStyleSpec:
                                            charts.TextStyleSpec(fontSize: 20),
                                        titleOutsideJustification: charts
                                            .OutsideJustification
                                            .middleDrawArea),
                                  ],
                                  animate: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      showDialog(context: context, builder: (_) => dialog);
                    });
                  });
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(8),
                      height: 40,
                      width: 80,
                      color: Colors.black,
                      child: Text(
                        'Biểu đồ ',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      )),
                )),
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

_sortMapByDay(Map map) {
  List<dynamic> keys = map.keys.toList();
  keys.sort((a, b) => a.compareTo(b));
  var sortMap = {};
  keys.forEach((key) {
    sortMap[key] = map[key];
  });
  return sortMap;
}

_buildDataFromList(Map map, int startId, int endId) {
  var sortMap = {};
  sortMap.addAll(_sortMapByDay(map));
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
      index++;
      if (endId == -1) {
        if (index >= startId) {
          dayList.add(Text(
            '${_reverseDate(key)}',
            style: TextStyle(fontSize: 20),
          ));
          phList.add(Text(
              '${double.parse(value['ph'].toString()).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20)));
          tdsList.add(Text(
              '${double.parse(value['tds'].toString()).toStringAsFixed(0)}',
              style: TextStyle(fontSize: 20)));
          temperatureList.add(Text(
              '${double.parse(value['temperature'].toString()).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20)));
        }
      } else if (startId <= index && endId >= index) {
        dayList.add(Text(
          '${_reverseDate(key)}',
          style: TextStyle(fontSize: 20),
        ));
        phList.add(Text(
            '${double.parse(value['ph'].toString()).toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20)));
        tdsList.add(Text(
            '${double.parse(value['tds'].toString()).toStringAsFixed(0)}',
            style: TextStyle(fontSize: 20)));
        temperatureList.add(Text(
            '${double.parse(value['temperature'].toString()).toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20)));
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

_reverseDate(String day) {
  String dd = day.substring(8);
  String mm = day.substring(5, 7);
  String yyyy = day.substring(0, 4);
  return dd + '/' + mm + '/' + yyyy;
}
