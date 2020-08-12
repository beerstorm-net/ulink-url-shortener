part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AppStartedEvent extends AuthEvent {}

class LoginWithApplePressed extends AuthEvent {}

class LoginWithGooglePressed extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class EnrichAppUserEvent extends AuthEvent {
  final List<String> actions; // DEVICEINFO, LOCATION, ...

  const EnrichAppUserEvent(this.actions);

  @override
  List<Object> get props => [actions];

  @override
  String toString() => 'EnrichAppUserEvent { actions: $actions }';
}

class RefreshTokenEvent extends AuthEvent {
  final AppUser appUser;

  const RefreshTokenEvent({this.appUser});
  @override
  List<Object> get props => [appUser];

  @override
  String toString() => 'RefreshTokenEvent { appUser: $appUser }';
}

class WarnUserEvent extends AuthEvent {
  final List<String> actions;
  final String message;
  final Duration duration;

  const WarnUserEvent(this.actions,
      {this.message, this.duration = const Duration(seconds: 2)});

  @override
  List<Object> get props => [actions, message, duration];

  @override
  String toString() =>
      'WarnUserEvent { actions: $actions, message: $message, duration: $duration }';
}
