import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';

class DataDayPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(8),

      //Set background for container
      decoration: BoxDecoration(gradient: BACKGROUND),

      child: Column(
        children: <Widget>[
          //Build title
          Flexible(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  '${now.day}/${now.month}/${now.year}',
                  style: TextStyle(fontSize: 36, color: Colors.black),
                ),
              ),
              flex: 1),
          SizedBox(
            height: 20,
          ),

          //Build list data
          Flexible(
              child: FirebaseAnimatedList(
                  query: Database.dataRef,
                  itemBuilder: (context, snap, anim, index) {
                    var map = snap.value;
                    String day = now.day.toString() +
                        "/" +
                        now.month.toString() +
                        "/" +
                        now.year.toString();
                    return (map['day'].toString() == day)
                        ? SizeTransition(
                            sizeFactor: anim, child: _showData(map, index))
                        : _bulidTextDataEmpty(index);
                  }),
              flex: 4),

          //Build result test
          Flexible(
              child: FirebaseAnimatedList(
                  query: Database.testRef,
                  itemBuilder: (context, snap, animation, index) {
                    String tds = snap.value['tds'].toString();
                    String ph = snap.value['ph'].toString();
                    String temperature = snap.value['temperature'].toString();
                    bool onTest = snap.value['onTest'];
                    if (!onTest) {
                      return Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          'Bạn chưa lấy mẫu ấn vào nút play để lấy mẫu ngay bạn sẽ kết quả sau vài phút',
                          style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      );
                    } else if (tds == '0' && ph == '0' && temperature == '0') {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else
                      return Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'pH : $ph     tds:$tds    Nhiệt độ:$temperature ',
                            style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ));
                  }),
              flex: 3),

          //Build button test
          Flexible(
              child: FirebaseAnimatedList(
                  query: Database.testRef,
                  itemBuilder: (context, snap, animation, index) {
                    bool onTest = snap.value['onTest'];
                    String result =
                        onTest ? 'Kết thúc lấy mẫu' : 'Lấy mẫu ngay';
                    Icon icon =
                        onTest ? Icon(Icons.pause) : Icon(Icons.play_arrow);

                    return IconButton(
                      onPressed: () {
                        if (!onTest) {
                          Database.testRef
                              .child("data")
                              .child('onTest')
                              .set(true);
                        } else {
                          Database.testRef
                              .child("data")
                              .child('onTest')
                              .set(false);
                          Database.testRef.child("data").child('ph').set(0);
                          Database.testRef.child("data").child('tds').set(0);
                          Database.testRef
                              .child("data")
                              .child('temperature')
                              .set(0);
                        }
                      },
                      icon: icon,
                      iconSize: 70.0,
                      tooltip: result,
                      color: Colors.blue,
                    );
                  }),
              flex: 2),
        ],
      ),
    );
  }
}

_bulidTextDataEmpty(int index) {
  List<Widget> list = List<Widget>();
  if (index == 0)
    list.add(Text(
      'Hôm nay bạn chưa bơm lần nào. Dữ liệu trống',
      textAlign: TextAlign.left,
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ));
  return Column(children: list);
}

_showData(Map map, int index) {
  List<Widget> list = List<Widget>();
  if (index == 0) {
    list = [];
    //Build list title
    list.add(DefaultTextStyle(
      style: TEXT_STYLE,
      child: Row(
        children: <Widget>[
          Expanded(child: Text('Thời gian'), flex: 3),
          Expanded(child: Text('pH'), flex: 2),
          Expanded(child: Text('tds'), flex: 2),
          Expanded(child: Text('nhiệt độ'), flex: 3),
        ],
      ),
    ));
  }

  list.add(DefaultTextStyle(
    style: TEXT_STYLE,
    child: Row(
      children: <Widget>[
        Expanded(child: Text('${map['time']}'), flex: 3),
        Expanded(child: Text('${map['ph']}'), flex: 2),
        Expanded(child: Text('${map['tds']}'), flex: 2),
        Expanded(
          child: Text('${map['temperature']}'),
          flex: 3,
        ),
      ],
    ),
  ));

  return Column(
    children: list,
  );
}
