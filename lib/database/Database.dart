import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

class Database {
  static DatabaseReference ref = FirebaseDatabase.instance.reference();
  static DatabaseReference dataRef = ref.child("data");
  static DatabaseReference testRef = ref.child("test");
  static DatabaseReference saveRef = ref.child("save_data");
  static DatabaseReference cropRef = ref.child("crop");

  static Future<DataSnapshot> getDataRef() async {
    return dataRef.once();
  }

  static Future<DataSnapshot> getDataCropRef() async {
    return cropRef.child('data').once();
  }

  static Future<DataSnapshot> getSaveRef() async {
    return saveRef.once();
  }

  static Future<Map> getSaveDataRef() async {
    var saveData = await getSaveRef();
    return saveData.value['data'];
  }

  static Future<int> getCropTotal() async {
    var saveData = await getSaveRef();
    return saveData.value['crop_total'];
  }

  static Future<int> getStartID() async {
    var saveData = await getSaveRef();
    return saveData.value['startID'];
  }

  static Future<int> getEndID() async {
    var cropData = await getDataCropRef();
    Map map = cropData.value;
    int index = -1;
    map.forEach((key, value) {
      index++;
    });
    return index;
  }

  static Future<bool> checkAllowGetDataFromDevice() async {
    var saveData = await getSaveRef();
    return saveData.value['allow_get_data_from_device'];

    //Return false when user don't click create new crop
  }

  static Future<Map> getDataCropSelected(int cropSelected) async {
    String crop = "crop_" + cropSelected.toString();
    var data = await getSaveDataRef();
    Map map = data[crop];
    var startID = map['startID'];
    print(startID);
    var endID = map['endID'];
    var cropRef = await getDataCropRef();
    Map cropData = cropRef.value;
    var days = cropData.keys.toList();
    var sortDays = days.sublist(startID, endID - startID + 1);
    var sortMap = Map();
    sortDays.forEach((day) {
      sortMap[day] = cropData[day];
    });
    return sortMap;
  }

  //When user click finish crop
  static Future<void> saveDataAndFinishCrop(BuildContext context) async {
    var cropTotal = await getCropTotal();
    var allow = await checkAllowGetDataFromDevice();
    int startID = await getStartID();
    int endID = await getEndID();
    if (allow && endID >= startID) {
      saveRef
          .child('data')
          .child('crop_$cropTotal')
          .set({'startID': startID, 'endID': endID});
      startID = endID + 1;
      saveRef.child('startID').set(startID);
      allow = false;
      saveRef.child('allow_get_data_from_device').set(allow);
      Toast.show("Dữ liệu của bạn đã được lưu lại", context);
    } else {
      Toast.show(
          "Vụ mùa này đã kết thúc. Ấn tạo vụ để tạo vụ mùa mới", context);
    }
  }

  static Future<void> createNewCrop(BuildContext context) async {
    var cropTotal = await getCropTotal();
    var allow = await checkAllowGetDataFromDevice();
    if (!allow) {
      cropTotal++;
      allow = true;
      saveRef.child('crop_total').set(cropTotal);
      saveRef.child('allow_get_data_from_device').set(allow);
      Toast.show("Bạn đã tạo vụ mùa mới", context);
    } else {
      Toast.show(
          "Mùa vụ hiện tại chưa kết thúc. Kết thúc mùa vụ hiện tại bạn có thể tạo một vụ mùa mới",
          context);
    }
  }
}
