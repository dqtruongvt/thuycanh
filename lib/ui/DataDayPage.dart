import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';




class DataDayPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(8),

      //Set background for container
      decoration: BoxDecoration(gradient: BACKGROUND),

      child: Column(
        children: <Widget>[
          Flexible(child: _buildTitle(),flex : 1),
          SizedBox(height: 20,),
          Flexible(child: _buildListData(), flex: 4),
          Flexible(child:_buildResultTest(), flex: 3),
          Flexible(child:_buildButtonTest(), flex: 2),
        ],
      ),
    );
  }
}

_buildTitle() {
  DateTime now = DateTime.now();
  return Container(
    alignment: Alignment.center,
    child: Text(
          '${now.day}/${now.month}/${now.year}',
          style: TextStyle(fontSize: 36, color: Colors.black),
        ),
  );
}

_buildListData() {
  return FirebaseAnimatedList(
          query: Database.dataRef,
          itemBuilder: (context, snap, anim, index) {
            var map = snap.value;
            return SizeTransition(
                sizeFactor: anim, child: showData(map, index));
          });
}

showData(Map map, int index) {
  List<Widget> list = List<Widget>();
  if (index == 0){
     list = [];
    //Build list title
    list.add(DefaultTextStyle(
      style: TEXT_STYLE,
      child: Row(
        children: <Widget>[
          Expanded(child: Text('Thời gian'), flex: 3),
          Expanded(child: Text('pH'), flex: 2),
          Expanded(child: Text('tds'), flex: 2),
          Expanded(child: Text('nhiẹt độ'), flex: 3),
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

_buildResultTest() {
  return FirebaseAnimatedList(
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
                  style: TextStyle(fontSize: 20.0, color: Colors.black,fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
                  ));
          });
}

_buildButtonTest() {
  return FirebaseAnimatedList(
          query: Database.testRef,
          itemBuilder: (context, snap, animation, index) {
            bool onTest = snap.value['onTest'];
            String result = onTest ? 'Kết thúc lấy mẫu' : 'Lấy mẫu ngay';
            Icon icon = onTest ? Icon(Icons.pause) : Icon(Icons.play_arrow);

            return IconButton(
              onPressed: () {
                if (!onTest) {
                  Database.testRef.child("data").child('onTest').set(true);
                } else {
                  Database.testRef.child("data").child('onTest').set(false);
                  Database.testRef.child("data").child('ph').set(0);
                  Database.testRef.child("data").child('tds').set(0);
                  Database.testRef.child("data").child('temperature').set(0);
                }
              },
              icon: icon,
              iconSize: 70.0,
              tooltip: result,
              color: Colors.blue,
            );
          });
}
