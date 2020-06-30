import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const TEXT_SIZE = 15.0;
const TEXT_COLOR = Colors.black;
const TEXT_STYLE = TextStyle(
    fontSize: TEXT_SIZE, color: TEXT_COLOR, fontWeight: FontWeight.bold);
const BACKGROUND = LinearGradient(
    colors: [Colors.blue, Colors.white],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight);

fromDate(String date) {
  return date.replaceAll('/', '-');
}

toData(String str) {
  return str.replaceAll('-', '/');
}
