import 'package:flutter/material.dart';

import '../widgets/common_dialogs.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AssetImage bgImage = new AssetImage("assets/images/app/app_splash.jpg");
    return Scaffold(
        body: Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: new DecorationImage(
          image: bgImage,
          fit: BoxFit.cover,
        ),
      ),
      alignment: Alignment.center,
      child: LoadingIndicator(),
    ));
  }
}
