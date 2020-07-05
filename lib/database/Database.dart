import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
final firestore = Firestore.instance;
final saveCaculateRef = firestore.document('caculate/save');
final saveRef = firestore.collection('save');
final cropRef = firestore.collection('crop');
final orderCropRef = firestore.collection('crop').orderBy('timestamp');
final dataTestRef = firestore.collection('test').document('data');
final pumpTestRef = firestore.collection('test').document('pump');
final orderDataRef = firestore.collection('data').orderBy('timestamp');



