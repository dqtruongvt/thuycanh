import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';
import 'package:thuycanh/ui/widgets/CropWidget.dart';
import 'package:thuycanh/ui/widgets/MyAlertDialog.dart';
import 'package:thuycanh/ui/widgets/MyButton.dart';
import 'package:toast/toast.dart';

class ManageCropPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(gradient: BACKGROUND),
        ),
        CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  margin: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                          child: MyButton(
                              text: 'TẠO VỤ',
                              onPressed: () {
                                _onCreateCrop(context);
                              })),
                      Expanded(
                          child: MyButton(
                              text: 'KẾT THÚC',
                              onPressed: () {
                                _onFinishCrop(context);
                              })),
                    ],
                  ),
                ),
                SafeArea(
                  child: StreamBuilder(
                    stream: Database.saveRef.child('data').onValue,
                    builder:
                        (BuildContext context, AsyncSnapshot<Event> snapshot) {
                      return snapshot.hasData
                          ? snapshot.data.snapshot.value == null
                              ? Text('Bạn chưa có vụ mùa nào. Dữ liệu trống',
                                  style: TextStyle(
                                      fontSize: 32, color: Colors.white))
                              : _buildCropFromData(snapshot.data.snapshot.value)
                          : CircularProgressIndicator();
                    },
                  ),
                ),
              ]),
            )
          ],
        )
      ],
    );
  }

  _onFinishCrop(BuildContext context) {
    var dialog = MyAlertDialog(
      message: 'Bạn có muốn kết thúc vụ không',
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
    _showDialog(context, dialog);
  }

  void _onCreateCrop(BuildContext context) {
    var dialog = MyAlertDialog(
        message: 'Bạn có muốn tạo vụ mới không',
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
    _showDialog(context, dialog);
  }

  _showDialog(BuildContext context, MyAlertDialog dialog) {
    showDialog(context: context, builder: (context) => dialog);
  }

  _dialogExit({@required BuildContext context}) {
    Navigator.of(context).pop();
  }
}

_buildCropFromData(Map map) {
  List<Widget> list = [];

  for (int i = map.length - 1; i >= 0; i--) {
    var total = map.keys
        .elementAt(i)
        .toString()[map.keys.elementAt(i).toString().length - 1];
    var startId = map.values.elementAt(i)['startId'];
    var endId = map.values.elementAt(i)['endId'];
    list.add(CropWidget(total: total, startId: startId, endId: endId));
  }

  return Column(
    children: list,
  );
}
