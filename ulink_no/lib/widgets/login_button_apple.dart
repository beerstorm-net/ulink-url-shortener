import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:flutter/material.dart';

import '../shared/app_localizations.dart';

class LoginButtonApple extends StatelessWidget {
  final Function onPressed;
  LoginButtonApple({this.onPressed}) : assert(onPressed != null);

  @override
  Widget build(BuildContext context) {
    return AppleSignInButton(
      buttonKey: const ValueKey('apple_signin'),
      style: ButtonStyle.whiteOutline,
      //cornerRadius: 28,
      type: ButtonType.continueButton,
      buttonText: AppLocalizations.of(context).translate('apple_signin_button'),
      onPressed: () {
        this.onPressed();
        /*BlocProvider.of<AuthBloc>(context).add(
          LoginWithApplePressed(),
        );*/
      },
    );
  }
}
