import 'package:flutter/material.dart';
import 'package:thuycanh/configure/Configure.dart';
import 'package:thuycanh/database/Database.dart';

class ManageCropPage extends StatefulWidget {
  @override
  _ManageCropPageState createState() => _ManageCropPageState();
}

class _ManageCropPageState extends State<ManageCropPage> {
  int cropSelected = 1;
  bool showData = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(gradient: BACKGROUND),
      child: Column(
        children: <Widget>[
          //Build Crop Total
          Flexible(
            flex: 1,
            child: FutureBuilder(
              future: Database.getCropTotal(),
              builder: (context, snap) {
                var total = snap.data ?? 1;
                return Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Tổng số vụ: $total',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),

          //Build crop selected
          Flexible(
            flex: 1,
            child: FutureBuilder(
              future: Database.getCropTotal(),
              builder: (context, snap) {
                var total = snap.data ?? 1;
                List<int> listSelect =
                    List.generate(total, (index) => index + 1);
                return Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.all(8),
                  child: DefaultTextStyle(
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    child: Row(
                      children: <Widget>[
                        Text("Hiển thị dữ liệu mùa: "),
                        DropdownButton<int>(
                            items: listSelect
                                .map((item) => DropdownMenuItem(
                                    child: Text(
                                      '$item',
                                      style: TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    value: item))
                                .toList(),
                            value: cropSelected,
                            onChanged: (value) {
                              setState(() {
                                cropSelected = value;
                                showData = true;
                              });
                            })
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          //Build Data
          Flexible(
            child: Container(
              child: FutureBuilder(
                future: Database.getDataCropSelected(cropSelected),
                builder: (context, snapshot) {
                  Map data = snapshot.data ?? {};
                  // print(data);
                  List<Widget> list = [];
                  list.add(DefaultTextStyle(
                    style: TEXT_STYLE,
                    child: Row(
                      children: <Widget>[
                        Expanded(child: Text('Day'), flex: 2),
                        Expanded(child: Text('pH'), flex: 1),
                        Expanded(child: Text('tds'), flex: 1),
                        Expanded(child: Text('temperature'), flex: 2),
                      ],
                    ),
                  ));
                  data.forEach((key, value) {
                    list.add(DefaultTextStyle(
                      style: TEXT_STYLE,
                      child: Row(
                        children: <Widget>[
                          Expanded(child: Text('$key'), flex: 2),
                          Expanded(child: Text('${value['ph']}'), flex: 1),
                          Expanded(child: Text('${value['tds']}'), flex: 1),
                          Expanded(
                            child: Text('${value['temperature']}'),
                            flex: 2,
                          ),
                        ],
                      ),
                    ));
                  });
                  return Container(
                    padding: EdgeInsets.all(8),
                    child: showData
                        ? Column(
                            children: list,
                          )
                        : Text('Vui lòng chọn vụ để xem lại dữ liệu'),
                  );
                },
              ),
            ),
            flex: 10,
          ),

          //Build button finish crop and create new crop
          Flexible(
            child: Container(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FlatButton(
                    child: Container(
                      margin: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text('Kết thúc vụ'),
                      width: 100,
                      height: 50,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      Database.saveDataAndFinishCrop(context);
                    },
                  ),
                  FlatButton(
                    child: Container(
                      margin: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: Text('Tạo vụ'),
                      height: 50,
                      width: 100,
                      color: Colors.blue,
                    ),
                    onPressed: () {
                      Database.createNewCrop(context);
                    },
                  ),
                ],
              ),
            ),
            flex: 2,
          )
        ],
      ),
    );
  }
}
