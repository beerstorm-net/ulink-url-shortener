part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class InitialAuthState extends AuthState {
  @override
  List<Object> get props => [];
}

class UninitializedAuthState extends AuthState {}

class LoginPageState extends AuthState {}

class Unauthenticated extends AuthState {
  final Map<String, String> detail;
  final ORIGIN origin;

  const Unauthenticated({this.detail, this.origin = ORIGIN.RELOAD});

  @override
  List<Object> get props => [detail, origin];

  @override
  String toString() => 'Unauthenticated { detail: $detail | origin: $origin }';
}

class Authenticated extends AuthState {
  final AppUser appUser;
  final ORIGIN origin;

  const Authenticated(this.appUser, {this.origin = ORIGIN.RELOAD});

  @override
  List<Object> get props => [appUser, origin];

  @override
  String toString() =>
      'Authenticated { appUser: ${appUser.toJson().toString()} | origin: $origin}';
}

class EnrichAppUserState extends AuthState {}

class WarnUserState extends AuthState {
  final List<String> actions;
  final String message;
  final Duration duration;

  const WarnUserState(this.actions,
      {this.message, this.duration = const Duration(seconds: 2)});

  @override
  List<Object> get props => [actions, message, duration];

  @override
  String toString() =>
      'WarnUserState { actions: $actions, message: $message, duration: $duration }';
}

class RefreshTokenState extends AuthState {
  final AppUser appUser;
  final bool isRefreshed;

  const RefreshTokenState({this.appUser, this.isRefreshed});
  @override
  List<Object> get props => [isRefreshed, appUser];

  @override
  String toString() =>
      'RefreshTokenState { isRefreshed: $isRefreshed | appUser: $appUser }';
}
