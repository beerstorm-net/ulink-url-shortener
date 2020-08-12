import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class AppBiometricsEvent extends SettingsEvent {
  final bool enableBiometrics;

  const AppBiometricsEvent(this.enableBiometrics);

  @override
  List<Object> get props => [enableBiometrics];

  @override
  String toString() =>
      'AppBiometricsEvent { enableBiometrics: ${enableBiometrics.toString()} }';
}

class AppLocaleEvent extends SettingsEvent {
  //final String langCode;
  final Locale appLocale;

  const AppLocaleEvent(this.appLocale);

  @override
  List<Object> get props => [appLocale];

  @override
  String toString() => 'AppLocaleEvent { appLocale: ${appLocale.toString()} }';
}

class AppConnectivityEvent extends SettingsEvent {
  final bool isConnected;

  const AppConnectivityEvent(this.isConnected);

  @override
  List<Object> get props => [isConnected];

  @override
  String toString() => 'AppConnectivityEvent { isConnected: $isConnected }';
}

class AppleSignInAvailableEvent extends SettingsEvent {
  final bool isAvailable;

  const AppleSignInAvailableEvent(this.isAvailable);

  @override
  List<Object> get props => [isAvailable];

  @override
  String toString() =>
      'AppleSignInAvailableEvent { isAvailable: $isAvailable }';
}
