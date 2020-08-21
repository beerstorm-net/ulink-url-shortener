import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/blocs.dart';
import '../models/user_repository.dart';
import '../shared/app_localizations.dart';
import '../widgets/login_buttons_form.dart';

class OnboardingCarousel extends StatefulWidget {
  static const String pageRoute = '/onboarding';

  final UserRepository _userRepository;

  OnboardingCarousel({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _OnboardingCarousel createState() =>
      _OnboardingCarousel(userRepository: _userRepository);
}

class _OnboardingCarousel extends State<OnboardingCarousel> {
  final GlobalKey<ScaffoldState> _onboardingScaffoldKey =
      GlobalKey<ScaffoldState>();
  final UserRepository _userRepository;
  _OnboardingCarousel({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository;

  List<Widget> _pageViews;
  int _dotsCount; // = _pageViews.length;
  double _currentDot = 0.0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      initialPage: 0,
      keepPage: true,
      //viewportFraction: 0.8,
    );
    _pageController.addListener(() {
      //print('page: ${_pageController.page}');
      setState(() {
        _currentDot = _pageController.page;
      });
    });

    if (_userRepository.appleSignInAvailable != null) {
      BlocProvider.of<SettingsBloc>(context).add(AppleSignInAvailableEvent(
          _userRepository.appleSignInAvailable.isAvailable));
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    _pageViews = _pageViews ?? _buildPageViews(buildContext);
    _dotsCount = _dotsCount ?? _pageViews.length;

    return Scaffold(
      key: _onboardingScaffoldKey,
      backgroundColor: Colors.white,
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is AppConnectivityState && state.isConnected == false) {
            //_showSnackBar(AppLocalizations.of(context).translate('warning_nointernet'));
            BlocProvider.of<AuthBloc>(context).add(WarnUserEvent(
                List<String>()..add("alert_message")..add("WARN"),
                message: AppLocalizations.of(buildContext)
                    .translate('warning_nointernet')));
          } else if (state is AppleSignInAvailableState &&
              state.isAvailable == false) {
            //if (_userRepository.sharedPrefUtils.isIOSPlatform()) {
            if (_userRepository.hiveStore.isIOSPlatform()) {
              BlocProvider.of<AuthBloc>(context).add(WarnUserEvent(
                  List<String>()..add("alert_message")..add("WARN"),
                  message: AppLocalizations.of(buildContext)
                      .translate('warning_apple_signin_notavailable')));
            }
          }
        },
        child: _buildOnboardingLayout(buildContext),
      ),
    );
  }

  AssetImage bgImage = new AssetImage(
      "assets/images/onboarding_carousel_bg/onboarding_carousel_bg.png");
  _buildOnboardingLayout(context) => Container(
        key: ValueKey('onboardingLayout'),
        alignment: Alignment.center,
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
          image: new DecorationImage(
              image: bgImage, fit: BoxFit.fill, alignment: Alignment.topCenter),
        ),
        padding: new EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: _buildOnboardingContent(context),
      );

  _buildOnboardingContent(context) => Container(
        key: ValueKey('onboardingContent'),
        color: Colors.transparent,
        padding: EdgeInsets.only(top: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              /*Visibility(
                visible: Provider.of<DataConnectionStatus>(context) ==
                    DataConnectionStatus.disconnected,
                child: InternetNotAvailable()), */
              Container(
                  width:
                      _userRepository.screenSizeConfig.safeBlockHorizontal * 88,
                  height:
                      _userRepository.screenSizeConfig.safeBlockVertical * 66,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  /*constraints: BoxConstraints.expand(
                    //width: 350.0,
                    height: 440.0),*/
                  margin:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                  child: new Stack(
                    children: <Widget>[
                      new PageView.builder(
                        //physics: new AlwaysScrollableScrollPhysics(),
                        itemCount: _pageViews.length,
                        controller: _pageController,
                        itemBuilder: (_, int index) {
                          //return _pageViews[index % _pageViews.length];
                          return Transform.scale(
                            scale: index == _currentDot ? 1 : 0.8,
                            child: _pageViews[index % _pageViews.length],
                          );
                        },
                      ),
                    ],
                  )),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                //alignment: Alignment.bottomCenter,
                child: DotsIndicator(
                  dotsCount: _dotsCount,
                  axis: Axis.horizontal,
                  position: _currentDot,
                  decorator: DotsDecorator(
                    size: const Size.square(12.0),
                    activeSize: const Size(20.0, 12.0),
                    activeColor: Colors.yellow,
                    color: Colors.white,
                    spacing: const EdgeInsets.symmetric(horizontal: 2.0),
                    activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                child: LoginButtonsForm(
                  userRepository: _userRepository,
                ),
              ),
            ],
          ),
        ),
      );

  String onboardingImage1 =
      'assets/images/onboarding_images/onboarding_carousel_img01.png';
  String onboardingImage2 =
      'assets/images/onboarding_images/onboarding_carousel_img02.png';
  String onboardingImage3 = 'assets/images/app/app_icon.jpg';
  _buildPageViews(context) {
    List pageItems = [
      {
        'image': onboardingImage1,
        'title': AppLocalizations.of(context).translate('onboarding_title1'),
        'body': AppLocalizations.of(context).translate('onboarding_body1'),
      },
      {
        'image': onboardingImage2,
        'title': AppLocalizations.of(context).translate('onboarding_title2'),
        'body': AppLocalizations.of(context).translate('onboarding_body2'),
      },
      {
        'image': onboardingImage3,
        'title': AppLocalizations.of(context).translate('onboarding_title3'),
        'body': AppLocalizations.of(context).translate('onboarding_body3'),
      },
    ];

    List<Widget> _pageViews = new List<Widget>();
    for (var i = 0; i < pageItems.length; i++) {
      Widget widget = ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Image(
                image: AssetImage(pageItems[i]['image']),
                height: _userRepository.screenSizeConfig.safeBlockVertical * 48,
              ),
            ),
            SizedBox(
              height: 4.0,
              width: 4.0,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  (pageItems[i]['title'].toString().contains('fabulam'))
                      ? Text(
                          pageItems[i]['title'],
                          style: TextStyle(
                              fontFamily: 'Sancreek',
                              fontSize: _userRepository
                                      .screenSizeConfig.safeBlockVertical *
                                  (_userRepository.screenSizeConfig.isMobile()
                                      ? 4.8
                                      : 3.3),
                              color: Colors.blueGrey),
                        )
                      : Text(
                          pageItems[i]['title'],
                          style: TextStyle(
                              fontSize: _userRepository
                                      .screenSizeConfig.safeBlockVertical *
                                  (_userRepository.screenSizeConfig.isMobile()
                                      ? 3.8
                                      : 3),
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey),
                        ),
                  Text(
                    "",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    pageItems[i]['body'],
                    style: TextStyle(
                        fontSize:
                            _userRepository.screenSizeConfig.safeBlockVertical *
                                (_userRepository.screenSizeConfig.isMobile()
                                    ? 2.8
                                    : 2),
                        color: Colors.blueGrey),
                  ),
                ],
              ),
            )
          ],
        ),
      );
      _pageViews.add(widget);
    }

    return _pageViews;
  }
}
