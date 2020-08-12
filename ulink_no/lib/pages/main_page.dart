import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../blocs/blocs.dart';
import '../models/user_repository.dart';
import '../shared/app_defaults.dart';
import '../shared/common_utils.dart';
import '../widgets/common_dialogs.dart';
import 'home_screen.dart';
import 'onboarding_carousel.dart';
import 'splash_screen.dart';

class MainPage extends StatefulWidget {
  UserRepository _userRepository;
  MainPage({Key key, UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ProgressDialog _progressDialog;

  @override
  Widget build(BuildContext buildContext) {
    if (_progressDialog == null) {
      _progressDialog = buildProgressDialog(buildContext, '...in progress...',
          isDismissible: true, autoHide: Duration(seconds: 3));
    }

    return BlocConsumer<AuthBloc, AuthState>(listenWhen: (prev, current) {
      return current is WarnUserState;
    }, listener: (prev, current) {
      // progress dialog actions
      if (current is WarnUserState) {
        // progress dialog
        if (current.actions.contains("progress_start")) {
          _progressDialog.show();
        } else if (current.actions.contains("progress_stop")) {
          _progressDialog.hide();
        } else if (current.actions.contains("alert_message")) {
          String _alertType = "WARNING"; // default
          if (current.actions.contains("SUCCESS")) {
            _alertType = "SUCCESS";
          } else if (current.actions.contains("INFO")) {
            _alertType = "INFO";
          } else if (current.actions.contains("ERROR")) {
            _alertType = "ERROR";
          }
          showAlertDialog(buildContext, current.message,
              type: _alertType, autoHide: current.duration);
        }
      }
    }, buildWhen: (prev, current) {
      return (current is AuthState &&
          (current is Authenticated || current is Unauthenticated));
    }, builder: (context, state) {
      CommonUtils.logger.d("main.builder state: $state");

      if (widget._userRepository.screenSizeConfig.isInit() == false) {
        widget._userRepository.screenSizeConfig.init(buildContext);
      }

      BlocProvider.of<AuthBloc>(context).add(
          WarnUserEvent(List<String>()..add("progress_stop"), message: ""));

      if (state is Unauthenticated) {
        if (state.detail != null && state.origin == ORIGIN.LOGIN) {
          BlocProvider.of<AuthBloc>(context).add(WarnUserEvent(
              List<String>()..add("alert_message")..add("WARN"),
              message: state.detail['message']));
        }
        return OnboardingCarousel(userRepository: widget._userRepository);
      }

      if (state is Authenticated) {
        if (state.origin == ORIGIN.LOGIN) {
          BlocProvider.of<AuthBloc>(context).add(
              EnrichAppUserEvent(List()..add('DEVICEINFO')..add('LOCATION')));

          BlocProvider.of<AuthBloc>(context).add(WarnUserEvent(
              List<String>()..add("progress_start"),
              message: ""));

          // NB! to avoid multiple reloads!!!
          BlocProvider.of<AuthBloc>(context).add(AppStartedEvent());
        }

        return HomeScreen(userRepository: widget._userRepository);
        /*return BlocProvider(
          create: (context) => MemoriesBloc(
              memoriesRepository:
                  MemoriesRepository(userRepository: widget._userRepository))
            ..add(LoadMemories()),
          child: HomeScreen(userRepository: widget._userRepository),
        ); */
      }

      return SplashScreen();
    });
  }

  @override
  void dispose() {
    _progressDialog?.hide();
    _progressDialog = null;

    super.dispose();
  }
}
