import 'dart:ui';

import 'package:equatable/equatable.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class InitialSettingsState extends SettingsState {
  @override
  List<Object> get props => [];
}

class AppBiometricsState extends SettingsState {
  final bool enableBiometrics;

  const AppBiometricsState(this.enableBiometrics);

  @override
  List<Object> get props => [enableBiometrics];

  @override
  String toString() =>
      'AppBiometricsState{ enableBiometrics: ${enableBiometrics.toString()} }';
}

class AppLocaleState extends SettingsState {
  final Locale appLocale;

  const AppLocaleState(this.appLocale);

  @override
  List<Object> get props => [appLocale];

  @override
  String toString() => 'AppLocaleState{ appLocale: ${appLocale.toString()} }';
}

class AppConnectivityState extends SettingsState {
  final bool isConnected;

  const AppConnectivityState(this.isConnected);

  @override
  List<Object> get props => [isConnected];

  @override
  String toString() => 'AppConnectivityState{ isConnected: $isConnected} }';
}

class AppleSignInAvailableState extends SettingsState {
  final bool isAvailable;

  const AppleSignInAvailableState(this.isAvailable);

  @override
  List<Object> get props => [isAvailable];

  @override
  String toString() =>
      'AppleSignInAvailableState { isAvailable: $isAvailable }';
}
