import 'package:shared_preferences/shared_preferences.dart';

class Keystore {
  get(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final value = (prefs.getString(key) ?? '');
    return value;
  }

  set(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
}
