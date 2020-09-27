import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ulink/blocs/app_navigator/app_navigator_bloc.dart';
import 'package:ulink/blocs/auth/auth_bloc.dart';
import 'package:ulink/blocs/links/links_bloc.dart';
import 'package:ulink/models/app_user.dart';
import 'package:ulink/pages/link_screen.dart';
import 'package:ulink/shared/app_defaults.dart';
import 'package:ulink/shared/app_localizations.dart';
import 'package:ulink/shared/common_utils.dart';

import '../models/user_repository.dart';
import 'links_screen.dart';
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

  Map<APP_PAGE, Widget> _allScreens = Map()
    ..putIfAbsent(APP_PAGE.LINK, () => LinkScreen())
    ..putIfAbsent(APP_PAGE.LINKS, () => LinksScreen())
    ..putIfAbsent(APP_PAGE.SETTINGS, () => SettingsScreen());
  Widget _currentScreen;

  @override
  void initState() {
    // if necessary, also listen to when first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRefreshToken();
    });

    // listen to app states
    WidgetsBinding.instance.addObserver(this);

    BlocProvider.of<AppNavigatorBloc>(context)
        .add(AppPageEvent(tab: APP_PAGE.LINK));

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // TODO: use when necessary
    } else {
      // TODO: use when necessary
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    //_refreshTokenTimer?.cancel();
    //_refreshTokenTimer = null;

    super.dispose();
  }

  _checkRefreshToken() {
    //AppUser appUser = widget._userRepository.sharedPrefUtils.prefsGetUser();
    AppUser appUser = widget._userRepository.hiveStore.readAppUser();
    CommonUtils.checkRefreshToken(context, appUser);
  }

  @override
  Widget build(BuildContext buildContext) {
    if (_currentScreen == null) {
      _currentScreen = _allScreens[APP_PAGE.LINK];
    }
    return BlocListener<AppNavigatorBloc, AppNavigatorState>(
        listener: (context, state) {
          print("State: $state");

          if (state is AppPageState) {
            if (_allScreens.containsKey(state.tab)) {
              setState(() {
                _currentScreen = _allScreens[state.tab];
              });
            }
          }
        },
        child: Scaffold(
          key: _globalKeyHome,
          primary: true,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              //icon: Icon(Icons.menu_rounded),
              icon: Image.asset(
                "assets/images/app/app_icon.png",
              ),
              onPressed: () {
                _globalKeyHome.currentState.openDrawer();
              },
            ),
            title: Text(
              widget.title,
              style: TextStyle(
                  fontSize: widget
                          ._userRepository.screenSizeConfig.safeBlockVertical *
                      (widget._userRepository.screenSizeConfig.isMobile()
                          ? 4.4
                          : 3.3),
                  fontFamily: 'Sancreek',
                  color: Colors.deepOrange),
            ),
            centerTitle: true,
          ),
          //drawer: Drawer(
          drawer: Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.all(8.0),
            width: widget._userRepository.screenSizeConfig.safeBlockHorizontal *
                80,
            height:
                widget._userRepository.screenSizeConfig.safeBlockVertical * 55,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: Colors.deepOrangeAccent.withAlpha(66),
                  width: 2.0,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  child: Text(''),
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("assets/images/app/app_splash.jpg"),
                    fit: BoxFit.scaleDown,
                  )),
                ),
                Divider(
                  thickness: 0.2,
                ),
                ListTile(
                  leading: Icon(
                    Icons.transform_rounded,
                    size: 48,
                    color: Colors.deepOrange,
                  ),
                  title: Text(
                    AppLocalizations.of(context).translate('app_page_link'),
                    style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: widget._userRepository.screenSizeConfig
                                .safeBlockVertical *
                            3.6),
                  ),
                  onTap: () {
                    BlocProvider.of<AppNavigatorBloc>(context)
                        .add(AppPageEvent(tab: APP_PAGE.LINK));
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.link,
                    size: 48,
                    color: Colors.deepOrange,
                  ),
                  title: Text(
                    AppLocalizations.of(context).translate('app_page_links'),
                    style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: widget._userRepository.screenSizeConfig
                                .safeBlockVertical *
                            3.6),
                  ),
                  onTap: () {
                    BlocProvider.of<AppNavigatorBloc>(context)
                        .add(AppPageEvent(tab: APP_PAGE.LINKS));
                    BlocProvider.of<LinksBloc>(context).add(LoadLinksEvent());

                    Navigator.pop(context);
                  },
                ),
                Divider(
                  thickness: 0.1,
                ),
                ListTile(
                  leading: Icon(
                    Icons.settings,
                    size: 44,
                    color: Colors.deepOrange,
                  ),
                  title: Text(
                    AppLocalizations.of(context).translate('app_page_settings'),
                    style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: widget._userRepository.screenSizeConfig
                                .safeBlockVertical *
                            3.3),
                  ),
                  onTap: () {
                    BlocProvider.of<AppNavigatorBloc>(context)
                        .add(AppPageEvent(tab: APP_PAGE.SETTINGS));
                    Navigator.pop(context);
                    /*
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
                */
                  },
                ),
              ],
            ),
          ),
          body: Container(
            width: widget._userRepository.screenSizeConfig.safeBlockHorizontal *
                98,
            height:
                widget._userRepository.screenSizeConfig.safeBlockVertical * 100,
            //margin: EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 4.0),
            child: Center(
              child: RepositoryProvider(
                  lazy: false,
                  create: (buildContext) => widget._userRepository,
                  child: BlocListener<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is RefreshTokenState) {
                        CommonUtils.logger.d('RefreshTokenState: $state');
                      }
                    },
                    listenWhen: (prev, current) {
                      return current is RefreshTokenState;
                    },
                    child: _currentScreen,
                  )),
              //child: isGoogleMap ? Loc8GoogleMap() : Loc8OpenMap(),
            ),
          ),
        ));
  }
}
