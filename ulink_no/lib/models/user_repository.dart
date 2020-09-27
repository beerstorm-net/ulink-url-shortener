import 'dart:async';
import 'dart:convert';

import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../blocs/auth/auth_error.dart';
import '../models/app_user.dart';
import '../shared/app_defaults.dart';
import '../shared/common_utils.dart';
import '../shared/hive_store.dart';
import '../shared/screen_size_config.dart';
import '../shared/shared_preferences.dart';
import '../widgets/apple_sign_in_available.dart';
import 'app_user.dart';

class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final AppleSignInAvailable _appleSignInAvailable;
  final SharedPref _sharedPref;
  final RemoteConfig _remoteConfig;
  //final SharedPrefUtils _sharedPrefUtils;

  final HiveStore _hiveStore;

  ScreenSizeConfig screenSizeConfig = ScreenSizeConfig();
  // NB! screenSizeConfig.init(context) MUST be called from inside MaterialApp build

  var usersCollection = FirebaseFirestore.instance.collection("users");
  void setCollectionName(String collectionName) {
    usersCollection = FirebaseFirestore.instance.collection(collectionName);
  }

  //static initSharedPrefUtils(sharedPref) => SharedPrefUtils(sharedPref);
  static initHiveStore(hiveBox) => HiveStore(hiveBox: hiveBox);
  UserRepository(
      {FirebaseAuth firebaseAuth,
      @required AppleSignInAvailable appleSignInAvailable,
      @required SharedPref sharedPref,
      @required RemoteConfig remoteConfig,
      @required Box hiveBox})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _appleSignInAvailable = appleSignInAvailable,
        _remoteConfig = remoteConfig,
        _sharedPref = sharedPref ?? new SharedPref(),
        //_sharedPrefUtils = initSharedPrefUtils(sharedPref),
        _hiveStore = initHiveStore(hiveBox);

  // (optional) this can be used when _sharedPref is not init already, aka not passed as ready
  initSharedPref() async {
    if (!_sharedPref.isReady) {
      await _sharedPref.initSharedPreferences();
    }
  }

  SharedPref get sharedPref => _sharedPref;
  //SharedPrefUtils get sharedPrefUtils => _sharedPrefUtils;
  HiveStore get hiveStore => _hiveStore;

  AppleSignInAvailable get appleSignInAvailable => _appleSignInAvailable;

  RemoteConfig get remoteConfig => _remoteConfig;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      //'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  Future<AppUser> signInWithGoogle() async {
    GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.signIn();
    } on Exception catch (e) {
      CommonUtils.logger.w("signInWithGoogle exception: ${e.toString()}");
      googleUser = null;
    }

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        final UserCredential authResult = await _firebaseAuth
            .signInWithCredential(GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        ));
        final firebaseUser = authResult.user;

        AppUser appUser = _firebaseUserToAppUser(firebaseUser, Map());
        CommonUtils.logger.d('appUser: ' + appUser.toJson().toString());
        await storeSaveAppUser(appUser);

// flutter: appUser: {uid: ..., email: ...@icloud.com, photoUrl: null, displayName: Zeus Baba}
        return appUser; //firebaseUser;
      } else {
        /*throw PlatformException(
            code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
            message: 'Missing Google Auth Token'); */
        throw LoginError(
          code: 'ERROR_MISSING_GOOGLE_AUTH_TOKEN',
          message: 'Missing Google Auth Token',
        );
      }
    } else {
      throw LoginError(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign in aborted by user',
      );
    }
  }

  Future<AppUser> signInWithApple() async {
    _appleSignInAvailable ?? await AppleSignInAvailable.check();
    if (!_appleSignInAvailable.isAvailable) {
      throw LoginError(
        // PlatformException(
        code: 'APPLE_SIGNIN_NOT_AVAILABLE',
        message: 'Apple SignIn is not available',
      );
    }

    List<Scope> scopes = const [Scope.email, Scope.fullName];
    final AuthorizationResult result = await AppleSignIn.performRequests(
        [AppleIdRequest(requestedScopes: scopes)]);
    switch (result.status) {
      case AuthorizationStatus.authorized:
        final appleIdCredential = result.credential;
        final oAuthProvider = OAuthProvider('apple.com');
        final credential = oAuthProvider.credential(
          //.getCredential(
          idToken: String.fromCharCodes(appleIdCredential.identityToken),
          accessToken:
              String.fromCharCodes(appleIdCredential.authorizationCode),
        );

        //await _firebaseAuth.signInWithCredential(credential);
        //return _firebaseAuth.currentUser();
        final authResult = await _firebaseAuth.signInWithCredential(credential);
        final firebaseUser = authResult.user;
        //CommonUtils.logger.d(firebaseUser);
        //CommonUtils.logger.d('appleIdCredential response: ${appleIdCredential.toMap().toString()}');
        if (appleIdCredential.fullName != null) {
          String displayName =
              '${CommonUtils.nullSafe(appleIdCredential.fullName.givenName)}';
          displayName +=
              '${CommonUtils.nullSafe(appleIdCredential.fullName.familyName)}';
          firebaseUser.updateProfile(displayName: displayName);
        }
        AppUser appUser = _firebaseUserToAppUser(
            firebaseUser,
            appleIdCredential.fullName != null
                ? appleIdCredential.fullName.toMap()
                : Map());
        CommonUtils.logger.d('appUser: ' + appUser.toJson().toString());
        await storeSaveAppUser(appUser);

// flutter: appUser: {uid: ..., email: ...@icloud.com, photoUrl: null, displayName: Zeus Baba}
        return appUser; //firebaseUser;
      //return _userFromFirebase(firebaseUser);
      case AuthorizationStatus.error:
        throw LoginError(
          // throw PlatformException(
          code: 'ERROR_AUTHORIZATION_DENIED',
          message: result.error.toString(),
        );
      case AuthorizationStatus.cancelled:
        throw LoginError(
          // throw PlatformException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign in aborted by user',
        );
    }
    return null;
  }

  Future<AppUser> apiCreateUser({@required AppUser appUser}) async {
    final String API_BASE = remoteConfig.getString('ulink_api_url');
    String reqUrl = API_BASE + API_USERS;

    if (CommonUtils.nullSafe(appUser.uid).isEmpty ||
        CommonUtils.nullSafe(appUser.email).isEmpty) {
      CommonUtils.logger
          .w('empty appUser!!! ${appUser.uid} - ${appUser.email}');
      return appUser;
    }

    Map<String, dynamic> data = Map()
      ..putIfAbsent("userid", () => appUser.email.toLowerCase())
      ..putIfAbsent("password", () => appUser.uid.toLowerCase())
      ..putIfAbsent(
          "extra", () => Map()..putIfAbsent("appName", () => "uLINK-iOS"));
    var body = jsonEncode(data);
    final response = await http.post(reqUrl,
        headers: {"Content-Type": "application/json"}, body: body
        /*body: {
          "userid": appUser.email.toLowerCase(),
          "password": appUser.uid.toLowerCase(),
          "extra": {"appName": "uLINK-iOS"}
        }*/
        );
    if (response.statusCode <= 201) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      if (responseJson.containsKey('_id')) {
        appUser.createdAt = responseJson['createdAt'];
        appUser.updatedAt = responseJson['updatedAt'];
      }
    } else {
      // user might already exists!
      CommonUtils.logger
          .e('API call failed... $reqUrl | ${response.reasonPhrase}');
      appUser.createdAt = null;
    }
    return appUser;
  }

  Future<AppUser> apiGetUser({@required String token}) async {
    final String API_BASE = remoteConfig.getString('ulink_api_url');
    String reqUrl = API_BASE + API_USERS;

    final response =
        await http.get(reqUrl, headers: {API_HEADER_TOKEN: 'Bearer ' + token});

    AppUser appUser;
    if (response.statusCode <= 201) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      List<dynamic> responseJson = responseBody.containsKey('data')
          ? responseBody['data'] as List<dynamic>
          : List();
      if (responseJson.isNotEmpty) {
        appUser = AppUser.fromJson(responseJson.first);
      }
    } //else {}

    return appUser;
  }

  ensureApiUser({@required AppUser appUser}) async {
    //if (appUser.token == null || appUser.token.isEmpty) {
    //  return;
    //}
    if (CommonUtils.nullSafe(appUser.token).isNotEmpty) {
      AppUser existing = await apiGetUser(token: appUser.token);
      if (existing == null) {
        await apiCreateUser(appUser: appUser);
      }
    } else {
      await apiCreateUser(appUser: appUser);
    }
  }

  Future<AppUser> apiRefreshToken({@required AppUser appUser}) async {
    final String API_BASE = remoteConfig.getString('ulink_api_url');
    String reqUrl = API_BASE + API_REFRESH_TOKEN;

    await ensureApiUser(appUser: appUser);

    Map<String, dynamic> data = Map()
      ..putIfAbsent("strategy", () => "local")
      ..putIfAbsent("userid", () => appUser.email.toLowerCase())
      ..putIfAbsent("password", () => appUser.uid.toLowerCase());
    var body = jsonEncode(data);
    final response = await http.post(reqUrl,
        headers: {"Content-Type": "application/json"}, body: body
        /*body: {
          "strategy": "local",
          "userid": appUser.email.toLowerCase(),
          "password": appUser.uid.toLowerCase(),
        }*/
        );
    if (response.statusCode <= 201) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      appUser.token = responseJson.containsKey('accessToken')
          ? responseJson['accessToken'] as String
          : null;

      if (appUser.token != null) {
        appUser.token_created_at = CommonUtils.tokenCreatedAt(appUser.token);
        //appUser.token_updated_at = CommonUtils.getFormattedDate();
      }
    } else {
      CommonUtils.logger
          .e('API call failed... $reqUrl | ${response.reasonPhrase}');
      appUser.token = null;
    }
    return appUser;
  }

  saveDeviceBasics({String devicePlatform, bool isPhysicalDevice}) async {
    try {
      // re-save devicePlatform info!!!
      if (CommonUtils.nullSafe(devicePlatform).isEmpty) {
        devicePlatform = await CommonUtils.getDevicePlatform();
      }
      if (isPhysicalDevice == null) {
        isPhysicalDevice =
            await CommonUtils.isPhysicalDevice(devicePlatform: devicePlatform);
      }
      //sharedPrefUtils.prefsDebug(isPhysicalDevice);
      //sharedPrefUtils.prefsDevicePlatform(devicePlatform);
      hiveStore.save(PREFKEYS[PREFKEY.SETTINGS_DEBUG], isPhysicalDevice);
      hiveStore.save(PREFKEYS[PREFKEY.DEVICEPLATFORM], devicePlatform);
    } on Exception catch (_) {}
  }

  Future<void> signOut() async {
    try {
      _sharedPref.clear();
      await saveDeviceBasics();

      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      // NB! do Apple signout, not sure if supported!!!
    } on Exception catch (e) {
      CommonUtils.logger.w("Exception while signOut... ${e.toString()}");
    }
  }

  Future<bool> isSignedIn() async {
    final currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  Future<String> getUser() async {
    User currentUser = _firebaseAuth.currentUser;
    return (currentUser.displayName.isNotEmpty)
        ? currentUser.displayName
        : currentUser.email;
  }

  Future<AppUser> getAppUser() async {
    User currentUser = _firebaseAuth.currentUser;
    if (currentUser == null || currentUser.uid.isEmpty) {
      return null;
    }

    AppUser appUser;
    var userDoc = await usersCollection
        .where("uid", isEqualTo: "${currentUser?.uid}")
        .get();
    if (userDoc.docs.isNotEmpty) {
      appUser = AppUser.fromSnapshot(userDoc.docs[0]);
    } else {
      appUser = _firebaseUserToAppUser(currentUser, Map());
      appUser = await storeSaveAppUser(appUser);
    }
    return appUser;
  }

  AppUser _firebaseUserToAppUser(
      User user, Map<String, dynamic> appleFullName) {
    if (user == null) {
      return null;
    }
    AppUser appUser = AppUser(
      uid: user.uid,
      email: user.email,
      /* displayName: user.displayName.nullSafeString,
      photoUrl: user.photoUrl.nullSafeString, */
      displayName: CommonUtils.nullSafe(user.displayName),
      photoUrl: CommonUtils.nullSafe(user.photoURL),
    );

    CommonUtils.logger.d('appleFullName: ${appleFullName.toString()}');
    if (appUser.displayName.isEmpty && appleFullName.isNotEmpty) {
      appUser.displayName = '';
      appUser.displayName += appleFullName.containsKey('givenName')
          ? CommonUtils.nullSafe(appleFullName['givenName']) + ' '
          : '';
      appUser.displayName += appleFullName.containsKey('familyName')
          ? CommonUtils.nullSafe(appleFullName['familyName'])
          : '';
    }

    return appUser;
  }

  Future<AppUser> storeSaveAppUser(AppUser appUser, {String reason}) async {
    var userDoc =
        await usersCollection.where("uid", isEqualTo: "${appUser.uid}").get();
    CommonUtils.logger
        .d('checked in FireStore... userExists?: ${userDoc.docs.isNotEmpty}');
    if (userDoc.docs.isEmpty) {
      CommonUtils.logger.d('new user will be added...');
      appUser.createdAt = CommonUtils.getFormattedDate();
      //await usersCollection.add(appUser.toJson());
      await usersCollection.doc(appUser.uid).set(appUser.toJson());
    }

    _hiveStore.save(PREFKEYS[PREFKEY.APP_USERID], appUser.uid);
    _hiveStore.save(PREFKEYS[PREFKEY.APP_USER], appUser);
    //_sharedPrefUtils.prefsSaveUserId(appUser.uid);
    CommonUtils.logger.d('userId added to local prefs...');

    return appUser;
  }

  storeUpdateAppUser(String userId, Map<String, dynamic> dataToUpdate,
      {String userDocId}) async {
    if (userDocId == null) {
      var userDoc =
          await usersCollection.where('uid', isEqualTo: "$userId").get();
      if (userDoc.docs.isNotEmpty) {
        userDocId = userDoc.docs[0].id;
      }
    }

    if (userDocId != null) {
      await usersCollection
          .doc(userDocId)
          .set(dataToUpdate, SetOptions(merge: true));
      //.setData(dataToUpdate, merge: true);
    }
  }

  Future<Map> ipInfoDb() async {
    Map<String, dynamic> infoMap = Map();

    String ipinfodbToken =
        CommonUtils.nullSafe(remoteConfig.getString('ipinfodb_token'));
    String ipinfodbUrl =
        CommonUtils.nullSafe(remoteConfig.getString('ipinfodb_url'));
    if (ipinfodbToken.isNotEmpty && ipinfodbUrl.isNotEmpty) {
      String reqUrl = ipinfodbUrl;
      reqUrl += reqUrl.contains('?') ? "&" : "?";
      reqUrl += "key=" + ipinfodbToken;
      reqUrl += "&format=json";

      try {
        final response = await http.get(reqUrl);
        if (response.statusCode <= 201) {
          Map<String, dynamic> responseMap = json.decode(response.body);
          responseMap.remove('statusCode');
          responseMap.remove('statusMessage');

          infoMap.addAll(responseMap);
        }
      } catch (ex) {
        CommonUtils.logger.w('error while ipinfodb... $ex');
      }
    }

    return infoMap;
  }
}
