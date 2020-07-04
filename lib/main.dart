import 'package:flutter/material.dart';
import 'ui/pages/DataDayPage.dart';
import 'ui/pages/ManageCropPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
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
  final List<Widget> layouts = [DataDayPage(), ManageCropPage()];
  final List<Widget> titles = [Text('Dữ liệu ngày'), Text('Quản lí vụ')];

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
                  icon: Icon(Icons.library_books, color: Colors.blue),
                  title: titles[1])
            ]));
  }
}
