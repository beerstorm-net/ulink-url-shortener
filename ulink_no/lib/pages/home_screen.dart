import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ulink/models/app_user.dart';
import 'package:ulink/shared/app_defaults.dart';
import 'package:ulink/shared/common_utils.dart';

import '../blocs/settings/settings_bloc.dart';
import '../models/user_repository.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final String title;
  final UserRepository _userRepository;
  HomeScreen({Key key, @required UserRepository userRepository, String title})
      : assert(userRepository != null),
        _userRepository = userRepository,
        title = title ?? "uLINK",
        super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _globalKeyHome =
      GlobalKey<ScaffoldState>(debugLabel: '_keyHomeScreen');

  @override
  void initState() {
    // if necessary, also listen to when first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //TODO _checkRefreshToken();
    });

    // listen to app states
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // TODO:
    } else {
      // TODO:
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _refreshTokenTimer?.cancel();
    _refreshTokenTimer = null;

    super.dispose();
  }

  /*
  _forceReload() {
    BlocProvider.of<AuthBloc>(context)
        .add(WarnUserEvent(List<String>()..add("progress_start"), message: ""));

    // force load on init
    _checkRefreshToken();
    BlocProvider.of<IdeaBloc>(context).add(LoadIdeasEvent());
  }
   */
  _checkRefreshToken() {
    AppUser appUser = widget._userRepository.sharedPrefUtils.prefsGetUser();
    CommonUtils.checkRefreshToken(context, appUser);
  }

  Timer _refreshTokenTimer;
  _initRefreshTokenTimer(context) {
    _refreshTokenTimer = Timer.periodic(REFRESH_TOKEN_TIMER, (timer) {
      // check if token requires refresh, trigger event if time came
      AppUser appUser = widget._userRepository.sharedPrefUtils.prefsGetUser();
      CommonUtils.checkRefreshToken(context, appUser);
    });
  }

  @override
  Widget build(BuildContext buildContext) {
    /*//TODO
    if (_refreshTokenTimer == null) {
      _refreshTokenTimer = _initRefreshTokenTimer(buildContext);
    }*/

    return Scaffold(
      key: _globalKeyHome,
      primary: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        //title: Text(widget.title),
        title: Text(
          widget.title,
          style: TextStyle(
              fontSize:
                  widget._userRepository.screenSizeConfig.safeBlockVertical *
                      (widget._userRepository.screenSizeConfig.isMobile()
                          ? 4.4
                          : 3.3),
              fontFamily: 'Sancreek',
              color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              key: const ValueKey('button_settings'),
              alignment: Alignment.center,
              //visualDensity: VisualDensity.adaptivePlatformDensity,
              icon: Icon(Icons.more_horiz), // .settings
              iconSize:
                  widget._userRepository.screenSizeConfig.safeBlockVertical *
                      3.8,
              tooltip: 'Settings',
              color: Colors.white,
              focusColor: Colors.grey,
              onPressed: () {
                Navigator.push(
                  buildContext,
                  MaterialPageRoute<SettingsScreen>(
                    builder: (_) => BlocProvider.value(
                      value: BlocProvider.of<SettingsBloc>(buildContext),
                      child: RepositoryProvider(
                        lazy: false,
                        create: (context) => widget._userRepository,
                        child: SettingsScreen(),
                      ),
                    ),
                  ),
                );
              })
        ],
      ),
      body: Container(
        width: widget._userRepository.screenSizeConfig.safeBlockHorizontal * 98,
        height: widget._userRepository.screenSizeConfig.safeBlockVertical * 100,
        //margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
        child: Center(
          child: RepositoryProvider(
            lazy: false,
            create: (buildContext) => widget._userRepository,
            child: Text('TODO: Main Screen'), // FIXME: build main screen
          ),
          //child: isGoogleMap ? Loc8GoogleMap() : Loc8OpenMap(),
        ),
      ),
    );
  }
}
