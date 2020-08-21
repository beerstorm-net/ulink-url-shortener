import 'dart:convert';
import 'dart:ui';

import 'package:hive/hive.dart';
import 'package:ulink/models/app_user.dart';
import 'package:ulink/shared/common_utils.dart';

import 'app_defaults.dart';

class HiveStore {
  String _boxName;
  Box _hiveBox;
  //static initHiveBox(boxName) => await Hive.openBox(boxName);
  HiveStore({boxName = "appBox", Box hiveBox})
      : _boxName = boxName,
        _hiveBox = hiveBox; //initHiveBox(boxName);

  String get boxName => _boxName;
  Box get hiveBox => _hiveBox;

  read(String key) {
    if (!contains(key)) {
      return null;
    }
    String value = _hiveBox.get(key) as String;
    if (value.contains("{")) {
      return json.decode(value);
    } else {
      return value;
    }
  }

  save(String key, dynamic value) {
    if (value is String && !value.contains("{")) {
      _hiveBox.put(key, value);
    } else {
      _hiveBox.put(key, json.encode(value));
    }
  }

  contains(String key) {
    return _hiveBox.containsKey(key);
  }

  remove(String key) {
    _hiveBox.delete(key);
  }

  clear() {
    _hiveBox.clear();
  }

  // --- reusable methods for ease of access ---
  AppUser readAppUser() {
    String dataStr = _hiveBox.get(PREFKEYS[PREFKEY.APP_USER]);
    return CommonUtils.nullSafe(dataStr).isNotEmpty
        ? AppUser.fromJson(json.decode(dataStr))
        : null;
  }

  Locale readAppLocale() {
    String localeStr = _hiveBox.get(PREFKEYS[PREFKEY.APP_LANGCODE]);

    return CommonUtils.nullSafe(localeStr).isNotEmpty
        ? Locale(localeStr)
        : null;
  }

  bool isIOSPlatform() {
    return _hiveBox.get(PREFKEYS[PREFKEY.DEVICEPLATFORM]) == "ios";
  }

  bool isAndroidPlatform() {
    return _hiveBox.get(PREFKEYS[PREFKEY.DEVICEPLATFORM]) == "android";
  }
}
