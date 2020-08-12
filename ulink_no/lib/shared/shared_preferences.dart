import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPref {
  SharedPreferences _prefs;
  bool isReady = false;

  initSharedPreferences() async {
    this._prefs = await SharedPreferences.getInstance();
    this.isReady = true;
  }

  read(String key) {
    //return contains(key)? json.decode(_prefs.getString(key)) : null;
    if (!contains(key)) {
      return null;
    }
    String value = _prefs.getString(key);
    if (value.contains("{")) {
      return json.decode(value);
    } else {
      return value;
    }
  }

  save(String key, dynamic value) {
    if (value is String && !value.contains("{")) {
      _prefs.setString(key, value);
    } else {
      _prefs.setString(key, json.encode(value));
    }
  }

  contains(String key) {
    return _prefs.containsKey(key);
  }

  remove(String key) {
    _prefs.remove(key);
  }

  clear() {
    // clear all keys from prefs
    _prefs.clear();
  }
}
