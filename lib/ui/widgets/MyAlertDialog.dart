import 'package:flutter/material.dart';
import 'package:thuycanh/ui/widgets/MyButton.dart';

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
      content: Text(message),
      actions: <Widget>[
        MyButton(
            text: 'Có',
            onPressed: onYes,
            height: 40,
            width: 75,
            color: Colors.blue),
        MyButton(
            text: 'Không',
            onPressed: onNo,
            height: 40,
            width: 75,
            color: Colors.blue),
      ],
    );
  }
}