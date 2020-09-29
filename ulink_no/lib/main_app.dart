import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'blocs/data_connectivity_service.dart';
import 'blocs/settings/settings_bloc.dart';
import 'blocs/settings/settings_event.dart';
import 'blocs/settings/settings_state.dart';
import 'models/user_repository.dart';
import 'pages/main_page.dart';
import 'shared/app_localizations.dart';

/// Navigator key to navigate without a BuildContext
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatefulWidget {
  final UserRepository _userRepository;
  MainApp(
      {Key key,
      @required UserRepository userRepository,
      DataConnectivityService dataConnectivityService})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  Locale appLocale;
  bool isAppStarted;
  DataConnectivityService _dataConnectivityService;

  @override
  void initState() {
    super.initState();

    //appLocale = widget._userRepository.sharedPrefUtils.prefsGetLocale();
    appLocale = widget._userRepository.hiveStore.readAppLocale();
    //widget._userRepository.hiveStore.read(PREFKEYS[PREFKEY.APP_LANGCODE]);

    // listen to AppLifecycleState
    WidgetsBinding.instance.addObserver(this);
    isAppStarted = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        isAppStarted = true;
      });
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_dataConnectivityService != null &&
        _dataConnectivityService.listener != null) {
      _dataConnectivityService.listener.cancel();
      _dataConnectivityService.listener = null;
    }
    super.dispose();
  }

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    if (_dataConnectivityService == null ||
        _dataConnectivityService.listener == null) {
      _dataConnectivityService = DataConnectivityService(
          context: context, userRepository: widget._userRepository);
    }

    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (BuildContext context, SettingsState state) {
        return (state is AppLocaleState);
      },
      builder: (context, state) {
        if (state is AppLocaleState && state.appLocale != null) {
          appLocale = state.appLocale;
        }

        return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: _navigatorKey,
            //locale: appLocale != null ? appLocale : defaultAppLocale,
            locale: appLocale,
            supportedLocales: appSupportedLocales,
            // Returns a locale which will be used by the app
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              // If the locale of the device is not supported, use the first one
              // from the list (English, in this case).
              Locale locale;

              if (appLocale != null) {
                locale = appLocale;
              } else {
                // Check if the current device locale is supported
                for (var supportedLocale in supportedLocales) {
                  if (supportedLocale.languageCode ==
                      deviceLocale.languageCode) {
                    locale = supportedLocale;
                    break;
                  }
                }
              }

              // If the locale of the device is not supported or not found,
              // use the first one from the list (English, in this case).
              locale = locale ?? supportedLocales.first;

              if (appLocale == null) {
                BlocProvider.of<SettingsBloc>(context)
                    .add(AppLocaleEvent(locale));
              }

              return locale;
            },
            localizationsDelegates: [
              // A class which loads the translations from JSON files
              AppLocalizations.delegate,
              RefreshLocalizations.delegate,
              // Built-in localization of basic text for Material widgets
              GlobalMaterialLocalizations.delegate,
              // Built-in localization for text direction LTR/RTL
              GlobalWidgetsLocalizations.delegate,
              // Built-in localization of basic text for Cupertino widgets
              GlobalCupertinoLocalizations.delegate,
            ],
            title: 'uLINK',
            theme: ThemeData(
              primarySwatch: Colors.deepOrange,
              primaryColor: Colors.deepOrange,
              accentColor: Colors.orange,

              // This makes the visual density adapt to the platform that you run
              // the app on. For desktop platforms, the controls will be smaller and
              // closer together (more dense) than on mobile platforms.
              visualDensity:
                  VisualDensity.adaptivePlatformDensity, // from beta channel
            ),
            home: MainPage(userRepository: widget._userRepository));
      },
    );
  }
}
