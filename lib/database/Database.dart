import 'package:firebase_database/firebase_database.dart';

class Database {
  static DatabaseReference ref = FirebaseDatabase.instance.reference();
  static DatabaseReference dataRef = ref.child("data");
  static DatabaseReference testRef = ref.child("test");
}