import 'package:shared_preferences/shared_preferences.dart';

const String userid = "userId";
const String myMobileNumber = "mobileNumber";
// const String ADMINSTATUS = "adminStatus";

class CacheService {
  Future<void> setCache(String key, dynamic value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
  }

  Future<dynamic> getCache(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  Future<void> setUserId(String? userId) async {
    await setCache(userid, userId);
  }

  Future<void> setMyMobileNumber(String? mobileNumber) async {
    await setCache(myMobileNumber, mobileNumber);
  }

  Future<String?> getUserId() async {
    final userId = await getCache(userid);
    if (userId == null || userId == "") return null;
    return "$userId";
  }

  Future<String?> getMyMobileNumber() async {
    final mobileNumber = await getCache(myMobileNumber);
    if (mobileNumber == null || mobileNumber == "") return null;
    return "$mobileNumber";
  }
}
