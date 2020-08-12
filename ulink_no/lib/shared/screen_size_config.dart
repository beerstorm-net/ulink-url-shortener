import 'package:flutter/widgets.dart';

class ScreenSizeConfig {
  MediaQueryData _mediaQueryData;
  double screenWidth;
  double screenHeight;
  double shortestSide;
  double blockSizeHorizontal;
  double blockSizeVertical;

  double _safeAreaHorizontal;
  double _safeAreaVertical;
  double safeBlockHorizontal;
  double safeBlockVertical;

  bool isInit() {
    return _mediaQueryData != null;
  }

  void init(BuildContext context) {
    if (_mediaQueryData != null) {
      // ensure init is done only once
      return;
    }

    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    shortestSide = _mediaQueryData.size.shortestSide;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    _safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    _safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;
    safeBlockHorizontal = (screenWidth - _safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - _safeAreaVertical) / 100;
  }

  bool isMobile() {
    return shortestSide != null && shortestSide < 600;
  }

  Map<String, dynamic> toMap() {
    return {
      '_mediaQueryData': this._mediaQueryData,
      'screenWidth': this.screenWidth,
      'screenHeight': this.screenHeight,
      'shortestSize': this.shortestSide,
      'blockSizeHorizontal': this.blockSizeHorizontal,
      'blockSizeVertical': this.blockSizeVertical,
      '_safeAreaHorizontal': this._safeAreaHorizontal,
      '_safeAreaVertical': this._safeAreaVertical,
      'safeBlockHorizontal': this.safeBlockHorizontal,
      'safeBlockVertical': this.safeBlockVertical,
    };
  }
}
