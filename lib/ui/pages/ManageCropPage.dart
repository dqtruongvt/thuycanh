import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';
import 'package:thuycanh/model/PhData.dart';
import 'package:thuycanh/model/TdsData.dart';
import 'package:thuycanh/model/TemperatureData.dart';
import 'package:thuycanh/ui/widgets/ChartWidget.dart';
import 'package:thuycanh/ui/widgets/MyAlertDialog.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:toast/toast.dart';

class ManageCropPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(decoration: BoxDecoration(gradient: BACKGROUND)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomScrollView(
            slivers: [
              SliverList(
                  delegate: SliverChildListDelegate([
                StreamBuilder(
                    stream: saveRef.snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Text(
                          'Bạn chưa có vụ mùa nào được tạo',
                          style: TITLE_STYLE,
                        );
                      } else {
                        QuerySnapshot querySnapshot = snapshot.data;
                        List<Map<String, dynamic>> crops =
                            querySnapshot.documents.map((e) => e.data).toList();
                        return _buildDataFromListCrop(crops, context);
                      }
                    }),
              ]))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20, bottom: 20),
          child: Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 20),
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        var dialog = MyAlertDialog(
                          message: 'Bạn có muốn tạo vụ mới không',
                          onNo: () => Navigator.of(context).pop(),
                          onYes: () {
                            Navigator.of(context).pop();
                            firestore.runTransaction((transaction) async {
                              var document =
                                  await transaction.get(saveCaculateRef);
                              var map = document.data;
                              var onCrop = map['onCrop'];
                              var total = map['total'];
                              var startId = map['startId'];
                              var endId = map['endId'];
                              if (onCrop) {
                                Toast.show(
                                    "Mùa vụ của bạn chưa kết thúc", context);
                              } else {
                                total++;
                                transaction.update(saveCaculateRef, {
                                  'total': FieldValue.increment(1),
                                  'onCrop': true
                                });
                                saveRef.document(total.toString()).setData(
                                    {'startId': startId, 'endId': endId});
                              }
                            });
                          },
                        );
                        showDialog(
                            context: context, builder: (context) => dialog);
                      },
                      label: Text('TẠO VỤ'),
                      icon: Icon(Icons.add),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {
                      var dialog = MyAlertDialog(
                        message: 'Bạn có muốn kết thúc vụ không',
                        onNo: () => Navigator.of(context).pop(),
                        onYes: () {
                          Navigator.of(context).pop();

                          firestore.runTransaction((transaction) async {
                            var cropDocuments = await cropRef.getDocuments();
                            var endId = cropDocuments.documents.length - 1;
                            var saveSnap = await saveCaculateRef.get();
                            var map = saveSnap.data;
                            var total = map['total'];
                            var onCrop = map['onCrop'];
                            if (!onCrop) {
                              Toast.show("Bạn chưa tạo vụ mới", context);
                            } else {
                              saveRef
                                  .document(total.toString())
                                  .updateData({'endId': endId});
                              saveCaculateRef.updateData(
                                  {'onCrop': false, 'startId': endId + 1});
                            }
                          });
                        },
                      );
                      showDialog(
                          context: context, builder: (context) => dialog);
                    },
                    label: Text('KẾT THÚC'),
                    icon: Icon(Icons.offline_pin),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ],
              )),
        ),
      ],
    );
  }
}

_buildDataFromListCrop(List<Map<String, dynamic>> crops, BuildContext context) {
  List<Widget> list = [];
  for (var i = crops.length; i >= 1; i--) {
    var crop = crops[i - 1];
    var total = i;
    var startId = crop['startId'];
    var endId = crop['endId'];

    list.addAll([
      Divider(thickness: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Mùa $total', style: TITLE_STYLE),
          endId == -1
              ? Text('Chưa kết thúc',
                  style: TextStyle(color: Colors.red, fontSize: 20))
              : Text(
                  'Đã kết thúc',
                  style: TextStyle(color: Colors.green, fontSize: 20),
                ),
          FloatingActionButton.extended(
            onPressed: () async {
              QuerySnapshot query = await orderCropRef.getDocuments();
              List<PhData> phData = [];
              List<TdsData> tdsData = [];
              List<TemperatureData> temperatureData = [];
              var docs = query.documents;

              //Tinh data cho 3 gia tri do thi
              docs.forEach((doc) {
                var index = docs.indexOf(doc).toDouble();

                phData.add(PhData(
                    index,
                    double.parse(doc.data['ph'].toString()),
                    charts.ColorUtil.fromDartColor(Colors.blue)));
                tdsData.add(TdsData(
                    index,
                    double.parse(doc.data['tds'].toString()),
                    charts.ColorUtil.fromDartColor(Colors.green)));
                temperatureData.add(TemperatureData(
                    docs.indexOf(doc).toDouble(),
                    double.parse(doc.data['temperature'].toString()),
                    charts.ColorUtil.fromDartColor(Colors.red)));
              });
              var dialog = ChartWidget(
                  phData: phData,
                  tdsData: tdsData,
                  temperatureData: temperatureData);
              showDialog(context: context, builder: (context) => dialog);
            },
            label: Text('Biểu đồ'),
            icon: Icon(Icons.show_chart),
          )
        ],
      ),
      SizedBox(
        height: 20,
      ),
      StreamBuilder(
        stream: orderCropRef.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return CircularProgressIndicator();
          else {
            List<Map<String, dynamic>> listData =
                snapshot.data.documents.map((e) => e.data).toList();
            List<String> listId =
                snapshot.data.documents.map((e) => e.documentID).toList();

            return (endId == -1)
                ? _buildData(listData.sublist(startId), listId.sublist(startId))
                : _buildData(listData.sublist(startId, endId + 1),
                    listId.sublist(startId, endId + 1));
          }
        },
      ),
      Divider(thickness: 5)
    ]);
  }
  return Column(
    children: list,
  );
}

_buildData(List<Map<String, dynamic>> listData, List<String> listId) {
  List<Widget> list = [];
  list.add(DefaultTextStyle(
      style: TextStyle(fontWeight: FontWeight.bold),
      child: Row(
        children: [
          Expanded(child: Text('Ngày')),
          Expanded(child: Text('pH')),
          Expanded(child: Text('TDS(ppm)')),
          Expanded(child: Text('Nhiệt độ (°C)')),
        ],
      )));
  listData.forEach((map) {
    list.add(DefaultTextStyle(
        style: DATA_STYLE,
        child: Row(
          children: [
            Expanded(child: Text('${listId[listData.indexOf(map)]}')),
            Expanded(child: Text('${map['ph']}')),
            Expanded(child: Text('${map['tds']}')),
            Expanded(child: Text('${map['temperature']}')),
          ],
        )));
  });
  return Column(
    children: list,
  );
}
