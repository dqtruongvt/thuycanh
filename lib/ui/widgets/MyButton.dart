import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Function onPressed;
  final String text;
  final Color color;

  final double height;
  final double width;
  const MyButton({
    Key key,
    @required this.onPressed,
    @required this.text,
    this.height: 50,
    this.width: 200,
    this.color: Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: onPressed,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(8),
              height: height,
              width: width,
              color: color,
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 10),
              )),
        ));
  }
}
