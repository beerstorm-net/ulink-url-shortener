import 'package:apple_sign_in/apple_sign_in.dart' as AppleSignin;
import 'package:flutter/material.dart';

import '../shared/app_localizations.dart';

class LoginButtonApple extends StatelessWidget {
  final Function onPressed;
  LoginButtonApple({this.onPressed}) : assert(onPressed != null);

  @override
  Widget build(BuildContext context) {
    return AppleSignin.AppleSignInButton(
      buttonKey: const ValueKey('apple_signin'),
      style: AppleSignin.ButtonStyle.whiteOutline,
      //cornerRadius: 28,
      type: AppleSignin.ButtonType.continueButton,
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
