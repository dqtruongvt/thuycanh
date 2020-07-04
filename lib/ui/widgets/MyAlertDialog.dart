import 'package:flutter/material.dart';
import 'package:thuycanh/configure/Configure.dart';

class MyAlertDialog extends StatelessWidget {
  final String message;
  final Function onYes;
  final Function onNo;

  const MyAlertDialog({
    Key key,
    @required this.message,
    @required this.onYes,
    @required this.onNo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text(
        message,
        style: TITLE_STYLE,
      ),
      actions: <Widget>[
        FloatingActionButton.extended(onPressed: onYes, label: Text('Có')),
        FloatingActionButton.extended(onPressed: onNo, label: Text('Không')),
      ],
    );
  }
}
