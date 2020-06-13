import 'package:flutter/material.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';

class ManageCropPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(gradient: BACKGROUND),
      child: Column(
        children: <Widget>[


        ],
      ),
    );
  }
}



Future<Map<String,dynamic>> getData() async {
    var snap = await Database.dataRef.once();
    return snap.value;
}

