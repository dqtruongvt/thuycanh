class Helper {
  reverseDate(String day) {
    String dd = day.substring(8);
    String mm = day.substring(5, 7);
    String yyyy = day.substring(0, 4);
    return dd + '/' + mm + '/' + yyyy;
  }

  sortMapByDay(Map map) {
    List<dynamic> keys = map.keys.toList();
    keys.sort((a, b) => a.compareTo(b));
    var sortMap = {};
    keys.forEach((key) {
      sortMap[key] = map[key];
    });
    return sortMap;
  }
}
