import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/blocs.dart';
import '../models/user_repository.dart';
import '../shared/app_localizations.dart';
import 'login_button_apple.dart';
import 'login_button_social.dart';

class LoginButtonsForm extends StatefulWidget {
  final UserRepository _userRepository;

  LoginButtonsForm({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  State<LoginButtonsForm> createState() => _LoginButtonsFormState();
}

class _LoginButtonsFormState extends State<LoginButtonsForm> {
  @override
  Widget build(BuildContext buildContext) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          if (widget._userRepository.appleSignInAvailable != null &&
              widget._userRepository.appleSignInAvailable.isAvailable == true)
            LoginButtonApple(onPressed: () async {
              /*BlocProvider.of<AuthBloc>(context).add(WarnUserEvent(
                  List<String>()..add("progress_start"),
                  message: ""));*/

              BlocProvider.of<AuthBloc>(context).add(
                LoginWithApplePressed(),
              );
            }),
          SizedBox(
            width: 8,
            height: 8,
          ),
          LoginButtonSocial(
            key: const ValueKey('google_signin'),
            assetName: 'assets/images/social_icons/go-logo.png',
            text:
                AppLocalizations.of(context).translate('google_signin_button'),
            onPressed: () async {
              /*BlocProvider.of<AuthBloc>(context).add(WarnUserEvent(
                  List<String>()..add("progress_start"),
                  duration: Duration(seconds: 4))); */
              BlocProvider.of<AuthBloc>(context).add(
                LoginWithGooglePressed(),
              );
            },
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
