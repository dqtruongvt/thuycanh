import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';
import 'package:thuycanh/model/Data.dart';
import 'package:flutter/rendering.dart';

class DataDayPage extends StatefulWidget {
  @override
  _DataDayPageState createState() => _DataDayPageState();
}

class _DataDayPageState extends State<DataDayPage> {
  List<Data> data;
  @override
  void initState() {
    data = List<Data>();
    super.initState();
    Database.dataRef.onChildAdded.listen((event) {
      fetchData(event.snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    print(data);
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
          Flexible(child: _buildData(data), flex: 4),

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

  void fetchData(DataSnapshot snapshot) {
    DateTime now = DateTime.now();
    String day = '${now.day}/${now.month}/${now.year}';
    if (day == snapshot.value['day']) {
      setState(() {
        data.add(Data(
          snapshot.value['day'].toString(),
          snapshot.value['time'].toString(),
          double.parse(snapshot.value['ph'].toString()),
          double.parse(snapshot.value['tds'].toString()),
          double.parse(snapshot.value['temperature'].toString()),
        ));
      });
    }
  }
}

_buildData(List<Data> data) {
  List<Widget> list = [];
  data.asMap().forEach((index, value) {
    if (index == 0) {
      list.add(DefaultTextStyle(
        style: TEXT_STYLE,
        child: Row(
          children: <Widget>[
            Expanded(child: Text('Thời gian'), flex: 2),
            Expanded(child: Text('pH'), flex: 1),
            Expanded(child: Text('tds'), flex: 1),
            Expanded(child: Text('nhiệt độ'), flex: 2),
          ],
        ),
      ));
    }
    list.add(DefaultTextStyle(
      style: TEXT_STYLE,
      child: Row(
        children: <Widget>[
          Expanded(child: Text('${value.time}'), flex: 2),
          Expanded(child: Text('${value.ph}'), flex: 1),
          Expanded(child: Text('${value.tds}'), flex: 1),
          Expanded(
            child: Text('${value.temperature}'),
            flex: 2,
          ),
        ],
      ),
    ));
  });

  return data.isNotEmpty
      ? Container(
          padding: EdgeInsets.all(8),
          child: Column(
            children: list,
          ),
        )
      : Text('Hôm nay bạn chưa bơm lần nào. Dữ liệu rỗng',
          style: TextStyle(fontSize: 30));
}
