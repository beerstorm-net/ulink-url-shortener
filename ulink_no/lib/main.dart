import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sentry/sentry.dart';

import 'blocs/app_navigator/app_navigator_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/links/links_bloc.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/settings/settings_event.dart';
import 'blocs/simple_bloc_observer.dart';
import 'main_app.dart';
import 'models/link_repository.dart';
import 'models/user_repository.dart';
import 'shared/common_utils.dart';
import 'shared/shared_preferences.dart';
import 'widgets/apple_sign_in_available.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = SimpleBlocObserver();

  await Firebase.initializeApp();

  final String devicePlatform = await CommonUtils.getDevicePlatform();
  final bool isPhysicalDevice =
      await CommonUtils.isPhysicalDevice(devicePlatform: devicePlatform);
  final appleSignInAvailable = await AppleSignInAvailable.check();

  final SharedPref _sharedPref = SharedPref();
  await _sharedPref.initSharedPreferences();

  await Hive.initFlutter();
  Box _hiveBox = await Hive.openBox("appBox");

  final RemoteConfig _remoteConfig = await RemoteConfig.instance;
  await _remoteConfig.fetch(expiration: const Duration(hours: 24));
  await _remoteConfig.activateFetched();
  // Enable developer mode to relax fetch throttling
  //_remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: !isPhysicalDevice));
  // optional: set defaults as backup
  Map<String, dynamic> remoteConfigDefaults =
      await CommonUtils.parseJsonFromAssets(
          'assets/config/remoteconfig_defaults.json');
  _remoteConfig.setDefaults(remoteConfigDefaults);

  //_sharedPref.clear();

  SentryClient _sentry;
  if (_remoteConfig.getString('sentry_dsn') != null) {
    _sentry = SentryClient(dsn: _remoteConfig.getString('sentry_dsn'));
  }

  _pushErrorToSentry({Object error, StackTrace stackTrace}) {
    if (_sentry != null) {
      try {
        _sentry.captureException(
          exception: error,
          stackTrace: stackTrace,
        );
        CommonUtils.logger.e('Successfully sent to sentry.io: $error');
      } catch (e) {
        CommonUtils.logger.e('Sending report to sentry.io failed: $e');
        CommonUtils.logger.e('Original error: $error');
      }
    }
  }

  final UserRepository _userRepository = UserRepository(
      appleSignInAvailable: appleSignInAvailable,
      sharedPref: _sharedPref,
      remoteConfig: _remoteConfig,
      hiveBox: _hiveBox);

  final LinkRepository _linkRepository =
      LinkRepository(userRepository: _userRepository);

  //_userRepository.sharedPref().clear();
  //Locale appLocale = _userRepository.sharedPrefUtils.prefsGetLocale();
  Locale appLocale = _userRepository.hiveStore.readAppLocale();
  //_userRepository.hiveStore.read(PREFKEYS[PREFKEY.APP_LANGCODE]);

  //_userRepository.sharedPrefUtils.prefsDebug(isPhysicalDevice);
  //_userRepository.sharedPrefUtils.prefsDevicePlatform(devicePlatform);
  _userRepository.saveDeviceBasics(
      devicePlatform: devicePlatform, isPhysicalDevice: isPhysicalDevice);

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = !isPhysicalDevice;
  // Pass all uncaught errors to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;
  FlutterError.onError = (FlutterErrorDetails errorDetails) {
    // dumps errors to console
    FlutterError.dumpErrorToConsole(errorDetails);

    if (!CommonUtils.isDebug) {
      _pushErrorToSentry(
          error: errorDetails.exception, stackTrace: errorDetails.stack);
    }

    // re-throws error so that `runZoned` handles it
    throw errorDetails;
  };

  final GlobalKey<ScaffoldState> _globalKeyMain =
      GlobalKey<ScaffoldState>(debugLabel: '_keyAppMain');
  runZonedGuarded<Future<void>>(() async {
    runApp(MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          lazy: false,
          create: (context) => AuthBloc(
            userRepository: _userRepository,
          )..add(AppStartedEvent()),
        ),
        BlocProvider<AppNavigatorBloc>(
            lazy: false, create: (context) => AppNavigatorBloc()),
        BlocProvider<SettingsBloc>(
          lazy: false,
          create: (context) => SettingsBloc(
            userRepository: _userRepository,
          )..add(AppLocaleEvent(appLocale)),
        ),
        BlocProvider<LinksBloc>(
            lazy: false,
            create: (context) => LinksBloc(
                  linkRepository: _linkRepository,
                )),

        // NB! add more BlocProviders when necessary
      ],
      child: MainApp(
        key: _globalKeyMain, //GlobalKey(),
        userRepository: _userRepository,
        //dataConnectivityService: _dataConnectivityService,
      ),
    ));
  }, (Object _error, StackTrace _stackTrace) async {
    CommonUtils.logger.e(_error);
    // using Crashlytics
    Crashlytics.instance.log(_error.toString());
    Crashlytics.instance.recordError(_error, _stackTrace);

    if (!CommonUtils.isDebug) {
      // using Sentry
      _pushErrorToSentry(error: _error, stackTrace: _stackTrace);
    }

    /* // TODO: enable this if we want to ask user to explicitly send error
    // Since the state can be null, we use `?.` to verify if it is null. If it is null, we don't do anything, if it is NOT null, we call the `push` function on it
    _navigatorKey.currentState?.push(MaterialPageRoute(
      builder: (_) => AppErrorWidget(
        navigatorKey: _navigatorKey,
        error: _error,
        stackTrace: _stackTrace,
      ),
    ));
    */
  });
}
