import 'dart:ui';

import '../models/app_user.dart';
import 'app_defaults.dart';
import 'shared_preferences.dart';

class SharedPrefUtils {
  final SharedPref _sharedPref;

  SharedPrefUtils(this._sharedPref);

  // all common read/write goes here

  final String keyUserId = PREFKEYS[PREFKEY.APP_USERID]; //"APP_USERID";
  void prefsSaveUserId(String userId) {
    String key = keyUserId;
    if (_sharedPref.contains(key)) {
      _sharedPref.remove(key);
    }
    _sharedPref.save(key, userId);
  }

  String prefsGetUserId() {
    String key = keyUserId;
    String userId =
        (_sharedPref.contains(key)) ? _sharedPref.read(key) as String : '';
    return userId;
  }

  void prefsSaveUser(AppUser appUser) {
    String key = PREFKEYS[PREFKEY.APP_USER];
    if (appUser == null) {
      _sharedPref.remove(key);
      return;
    }
    //if (_sharedPref.contains(key)) {
    //  _sharedPref.remove(key);
    //}
    _sharedPref.save(key, appUser.toJson());
  }

  AppUser prefsGetUser() {
    String key = PREFKEYS[PREFKEY.APP_USER];
    Map<String, dynamic> data =
        (_sharedPref.contains(key)) ? _sharedPref.read(key) as Map : null;
    return data != null ? AppUser.fromJson(data) : null;
  }

  final String keyLangCode = PREFKEYS[PREFKEY.APP_LANGCODE]; //"APP_LANGCODE";
  void prefsSaveLocale(String langCode) {
    String key = keyLangCode;
    if (_sharedPref.contains(key)) {
      _sharedPref.remove(key);
    }
    _sharedPref.save(key, langCode);
  }

  Locale prefsGetLocale() {
    String key = keyLangCode;
    String langCode =
        (_sharedPref.contains(key)) ? _sharedPref.read(key) as String : null;
    return langCode != null ? Locale(langCode) : null;
  }

/*AppUser storeGetAppUser() {
    String key = "APP_USER";
    AppUser appUser;
    if (_sharedPref.contains(key)) {
      appUser = AppUser.fromJson(_sharedPref.read(key));
    }
    return appUser;
  }*/

  final String keyWelcomeUser = PREFKEYS[PREFKEY.WELCOME_USER];
  void prefsWelcomeUser(bool isWelcomeUser) {
    String key = keyWelcomeUser;
    (isWelcomeUser == false)
        ? _sharedPref.remove(key)
        : _sharedPref.save(key, isWelcomeUser.toString());
  }

  bool prefsIsWelcomeUser() {
    String key = keyWelcomeUser;
    String isWelcomeUser = (_sharedPref.contains(key))
        ? (_sharedPref.read(key) as String)
        : 'false';
    return (isWelcomeUser == 'true');
  }

  final String keyBiometrics =
      PREFKEYS[PREFKEY.APP_BIOMETRICS]; //"APP_BIOMETRICS";
  void prefsAuthBiometrics(bool isAuthenticated) {
    String key = keyBiometrics;
    if (_sharedPref.contains(key)) {
      _sharedPref.remove(key);
    }
    _sharedPref.save(key, isAuthenticated.toString());
  }

  bool prefsIsAuthBiometrics() {
    String key = keyBiometrics;
    String isAuthenticated = (_sharedPref.contains(key))
        ? (_sharedPref.read(key) as String)
        : 'false';
    return (isAuthenticated == 'true');
  }

  final String keySettingsBiometrics =
      PREFKEYS[PREFKEY.SETTINGS_BIOMETRICS]; //"APP_SETTINGS_BIOMETRICS";
  void prefsSettingsBiometrics(bool enableBiometrics) {
    String key = keySettingsBiometrics;
    if (_sharedPref.contains(key)) {
      _sharedPref.remove(key);
    }
    _sharedPref.save(key, enableBiometrics.toString());
  }

  bool prefsIsEnabledBiometrics() {
    String key = keySettingsBiometrics;
    String enableBiometrics = (_sharedPref.contains(key))
        ? (_sharedPref.read(key) as String)
        : 'false';
    return (enableBiometrics == 'true');
  }

  final String keyNoInternet = PREFKEYS[PREFKEY.NOINTERNET]; //"NO_INTERNET";
  void prefsNoInternet(String time) {
    String key = keyNoInternet;
    if (_sharedPref.contains(key)) {
      _sharedPref.remove(key);
    }
    _sharedPref.save(key, time);
  }

  String prefsLastNoInternet() {
    String key = keyNoInternet;
    return (_sharedPref.contains(key)) ? (_sharedPref.read(key) as String) : '';
  }

  void prefsClearNoInternet() {
    return _sharedPref.remove(keyNoInternet);
  }

  bool prefsIsNoInternet() {
    return _sharedPref.contains(keyNoInternet);
  }

  void prefsDebug(bool enableDebug) {
    String key = PREFKEYS[PREFKEY.SETTINGS_DEBUG];
    if (_sharedPref.contains(key)) {
      _sharedPref.remove(key);
    }
    _sharedPref.save(key, enableDebug.toString());
  }

  bool prefsIsDebug() {
    String key = PREFKEYS[PREFKEY.SETTINGS_DEBUG];
    String enableDebug = (_sharedPref.contains(key))
        ? (_sharedPref.read(key) as String)
        : 'false';
    return (enableDebug == 'true');
  }

  final String keyDevicePlatform = PREFKEYS[PREFKEY.DEVICEPLATFORM];
  void prefsDevicePlatform(String devicePlatform) {
    String key = keyDevicePlatform;
    if (_sharedPref.contains(key)) {
      _sharedPref.remove(key);
    }
    _sharedPref.save(key, devicePlatform);
  }

  String prefsGetDevicePlatform() {
    String key = keyDevicePlatform;
    String devicePlatform = _sharedPref.contains(key)
        ? _sharedPref.read(key) as String
        : 'ios'; // ios default
    return devicePlatform;
  }

  bool isIOSPlatform() {
    return prefsGetDevicePlatform() == "ios";
  }

  bool isAndroidPlatform() {
    return prefsGetDevicePlatform() == "android";
  }
}
