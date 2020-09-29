import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../shared/app_defaults.dart';
import '../shared/common_utils.dart';
import 'app_link.dart';
import 'app_user.dart';
import 'user_repository.dart';

class LinkRepository {
  UserRepository _userRepository;

  LinkRepository({UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  UserRepository get userRepository => _userRepository;

  Future<List<AppLink>> loadLinks({int page = 1}) async {
    final String API_BASE =
        _userRepository.remoteConfig.getString('ulink_api_url');
    String reqUrl = API_BASE + API_LINKS;
    // FIXME: validate paging works on API as well!!
    //reqUrl += reqUrl.contains('?') ? "&" : "?";
    //reqUrl += "page=" + page.toString();
    //AppUser appUser = _userRepository.sharedPrefUtils.prefsGetUser();
    AppUser appUser = _userRepository.hiveStore.readAppUser();
    //_userRepository.hiveStore.read(PREFKEYS[PREFKEY.APP_USER]);

    final response = await http
        .get(reqUrl, headers: {API_HEADER_TOKEN: 'Bearer ' + appUser.token});

    List<AppLink> links = List();
    List<dynamic> responseJson;
    if (response.statusCode <= 201) {
      Map<String, dynamic> responseBody = json.decode(response.body);
      responseJson = responseBody.containsKey('data')
          ? responseBody['data'] as List<dynamic>
          : List();
      links = responseJson.map((linkMap) => AppLink.fromJson(linkMap)).toList();
    } else {
      CommonUtils.logger
          .e('API call failed... $reqUrl | ${response.reasonPhrase}');
    }

    return links;
  }

  Future<AppLink> addLink({@required AppLink appLink}) async {
    final String API_BASE =
        _userRepository.remoteConfig.getString('ulink_api_url');
    String reqUrl = API_BASE + API_LINKS;
    //AppUser appUser = _userRepository.sharedPrefUtils.prefsGetUser();
    AppUser appUser = _userRepository.hiveStore.readAppUser();
    //_userRepository.hiveStore.read(PREFKEYS[PREFKEY.APP_USER]);

    var reqBody = jsonEncode(appLink.toRequestJson());
    final response = await http.post(reqUrl,
        headers: {
          API_HEADER_TOKEN: 'Bearer ' + appUser.token,
          'Content-Type': 'application/json'
        },
        body: reqBody);

    if (response.statusCode <= 201) {
      Map<String, dynamic> responseJson = json.decode(response.body);
      appLink = AppLink.fromJson(responseJson);
    } else {
      CommonUtils.logger
          .e('API call failed... $reqUrl | ${response.reasonPhrase}');
    }

    return appLink;
  }
}
