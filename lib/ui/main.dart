import 'package:flutter/material.dart';
import 'package:thuycanh/ui/DataDayPage.dart';

import 'package:thuycanh/ui/DataCropPage.dart';
import 'package:thuycanh/ui/ManageCropPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.blue),
      home: Dashboard(),

    );
    
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _index = 0;
  final List<Widget> layouts = [DataDayPage(), DataCropPage(), ManageCropPage()];
  final List<Widget> titles = [Text('Dữ liệu ngày'), Text('Dữ liệu vụ'), Text('Quản lí vụ')];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: titles[_index],
          centerTitle: true,
        ),
        body: layouts[_index],
        bottomNavigationBar: BottomNavigationBar(
            fixedColor: Colors.blue,
            elevation: 0.0,
            type: BottomNavigationBarType.fixed,
            currentIndex: _index,
            onTap: (index) {
              setState(() {
                _index = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.date_range,
                    color: Colors.blue,
                  ),
                  title: titles[0]),
              BottomNavigationBarItem(
                  icon: Icon(Icons.view_comfy, color: Colors.blue),
                  title:titles[1]),
              BottomNavigationBarItem(
                  icon: Icon(Icons.library_books, color: Colors.blue),
                  title: titles[2])
            ]));
  }
}
