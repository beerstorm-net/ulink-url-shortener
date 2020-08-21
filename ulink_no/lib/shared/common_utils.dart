import 'dart:convert';

import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:logger/logger.dart';
import 'package:package_info/package_info.dart';
import 'package:ulink/blocs/auth/auth_bloc.dart';
import 'package:ulink/models/app_user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class CommonUtils {
  // TODO: isDebug is a manual switch, but it must come from isPhysicalDevice
  static final isDebug = true;
  static final Logger logger = Logger(
    level: isDebug ? Level.debug : Level.warning,
    printer: PrettyPrinter(
        methodCount: 2, // number of method calls to be displayed
        errorMethodCount: 8, // number of method calls if stacktrace is provided
        lineLength: 120, // width of the output
        colors: true, // Colorful log messages
        printEmojis: false, // Print an emoji for each log message
        printTime: true // Should each log print contain a timestamp
        ),
  );

  static String nullSafe(String source) {
    return (source == null || source.isEmpty || source == "null") ? "" : source;
  }

  static String nullSafeSnap(dynamic source) {
    return source != null ? nullSafe(source as String) : "";
  }

  static String generateUuid() {
    var uuid = Uuid();
    return uuid.v5(Uuid.NAMESPACE_URL, 'beerstorm.net');
  }

  static Pattern passwordPattern() {
    final Pattern pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])'; //(?=.*?[!@#\$&*~]).{8,}$
    return pattern;
  }

  static String getFormattedDate({DateTime date}) {
    return DateFormat("yyyy-MM-dd HH:mm:ss").format(date ?? DateTime.now());
  }

  static Future<Map<String, dynamic>> parseJsonFromAssets(
      String filePath) async {
    return rootBundle
        .loadString(filePath)
        .then((jsonStr) => jsonDecode(jsonStr));
  }

  /*static bool shouldRefreshToken(String dateAt) {
    // API token expires in X, refresh earlier to avoid expiration!
    if (dateAt != null && dateAt.isNotEmpty) {
      Jiffy jiffy = Jiffy(dateAt);
      return (jiffy.diff(DateTime.now(), Units.DAY) >= 5);
    }
    return true;
  }*/
  static bool shouldRefreshToken(String token) {
    // API token expires in X, refresh earlier to avoid expiration!

    if (CommonUtils.nullSafe(token).isNotEmpty) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      int expiresAt = payload.containsKey('exp') ? payload['exp'] as int : null;

      if (expiresAt == null) {
        return true;
      }

      String dateAt = CommonUtils.getFormattedDate(
          date: DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000));
      Jiffy jiffy = Jiffy(dateAt);
      return (jiffy.diff(DateTime.now(), Units.DAY) <= 7) ||
          (jiffy.diff(DateTime.now(), Units.MINUTE) <= 30);
    }
    return true;
  }

  static String tokenCreatedAt(String token) {
    String createdAt;
    if (CommonUtils.nullSafe(token).isNotEmpty) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      int iat = payload.containsKey('iat') ? payload['iat'] as int : null;
      if (iat != null) {
        createdAt = CommonUtils.getFormattedDate(
            date: DateTime.fromMillisecondsSinceEpoch(iat * 1000));
      }
    }

    return createdAt ?? CommonUtils.getFormattedDate();
  }

  static void checkRefreshToken(context, AppUser appUser) {
    if (CommonUtils.shouldRefreshToken(appUser?.token)) {
      BlocProvider.of<AuthBloc>(context)
          .add(RefreshTokenEvent(appUser: appUser));
    }
    Future.delayed(Duration(seconds: 1));
  }

  static launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url,
          forceSafariVC: true,
          forceWebView: true,
          enableJavaScript: true,
          enableDomStorage: true,
          headers: <String, String>{'source': 'fabulam_app'});
    } else {
      throw 'Could not launch $url';
    }
  }

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static Future<bool> isPhysicalDevice({String devicePlatform}) async {
    if (devicePlatform.toLowerCase() == "ios") {
      IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      return iosDeviceInfo.isPhysicalDevice;
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      return androidDeviceInfo.isPhysicalDevice;
    }
  }

  static Future<String> getDevicePlatform() async {
    try {
      IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      if (iosDeviceInfo != null) {
        CommonUtils.logger.d('iOS device!');
        return "ios";
      }
    } catch (_) {
      CommonUtils.logger.d('ANDROID device!');
      return "android";
    }
    return "android"; // default
  }

  static Future<String> getDeviceId({String devicePlatform}) async {
    if (devicePlatform.toLowerCase() == "ios") {
      IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }

  static Future<Map<String, dynamic>> getBasicDeviceInfo(
      {String devicePlatform = "ios"}) async {
    Map<String, dynamic> deviceInfo =
        await getDeviceInfo(devicePlatform: devicePlatform);
    List<String> keys = List()
      ..add('name')
      ..add('systemName')
      ..add('systemVersion')
      ..add('model')
      //..add('localizedModel')
      //..add('identifierForVendor')
      ..add('isPhysicalDevice')
      // android specific
      ..add("version.release")
      ..add("device")
      ..add("manufacturer");
    Map<String, dynamic> basicDeviceInfo = Map();
    deviceInfo.forEach((key, value) {
      if (keys.contains(key)) {
        basicDeviceInfo.putIfAbsent(key, () => value);
      }
    });
    return basicDeviceInfo;
  }

  static Future<Map<String, dynamic>> getDeviceInfo(
      {String devicePlatform}) async {
    Map<String, dynamic> infoMap = new Map();
    if (devicePlatform.toLowerCase() == "ios") {
      IosDeviceInfo iosDeviceInfo = await deviceInfoPlugin.iosInfo;
      infoMap = _readIosDeviceInfo(iosDeviceInfo);
      infoMap['deviceId'] =
          iosDeviceInfo.identifierForVendor; // unique ID on iOS
      /*
      infoMap['deviceId'] = iosDeviceInfo.identifierForVendor; // unique ID on iOS
      infoMap['isPhysicalDevice'] = iosDeviceInfo.isPhysicalDevice;
      infoMap['systemName'] = iosDeviceInfo.systemName;
      infoMap['systemVersion'] = iosDeviceInfo.systemVersion;
      infoMap['model'] = iosDeviceInfo.model;
      infoMap['name'] = iosDeviceInfo.name;
      */
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
      infoMap = _readAndroidBuildData(androidDeviceInfo);
      infoMap['deviceId'] = androidDeviceInfo.androidId; // unique ID on Android
      /*
      infoMap['deviceId'] = androidDeviceInfo.androidId; // unique ID on Android
      infoMap['isPhysicalDevice'] = androidDeviceInfo.isPhysicalDevice;
      infoMap['systemName'] = androidDeviceInfo.device;
      infoMap['systemVersion'] = androidDeviceInfo.version;
      infoMap['model'] = androidDeviceInfo.model;
      infoMap['brand'] = androidDeviceInfo.brand;
      */
    }

    return infoMap;
  }

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      //'systemFeatures': build.systemFeatures,
    };
  }

  static Future<Map<String, String>> getPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    Map<String, String> infoMap = new Map();
    infoMap['appName'] = packageInfo.appName;
    infoMap['version'] = packageInfo.version;
    infoMap['packageName'] = packageInfo.packageName;
    infoMap['buildNumber'] = packageInfo.buildNumber;

    return infoMap;
  }
}
