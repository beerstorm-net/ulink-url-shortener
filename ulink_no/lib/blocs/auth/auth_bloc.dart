import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../models/models.dart';
import '../../shared/app_defaults.dart';
import '../../shared/common_utils.dart';
import 'auth_error.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserRepository _userRepository;

  AuthBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(UninitializedAuthState());

  AuthState get initialState => UninitializedAuthState();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is AppStartedEvent) {
      yield* _mapAppStartedToState();
    } else if (event is LogoutEvent) {
      yield* _mapLogoutEventToState();
    } else if (event is LoginWithApplePressed) {
      yield* _mapLoginWithApplePressedToState();
    } else if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState();
    } else if (event is EnrichAppUserEvent) {
      yield* _mapEnrichAppUserToState(event);
    } else if (event is WarnUserEvent) {
      yield* _mapWarnUserEventToState(event);
    } else if (event is RefreshTokenEvent) {
      yield* _mapRefreshTokenEventToState(event);
    }
  }

  Stream<AuthState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _userRepository.isSignedIn();
      if (isSignedIn) {
        final AppUser appUser = await _userRepository.getAppUser();

        _userRepository.hiveStore.save(PREFKEYS[PREFKEY.APP_USER], appUser);
        //_userRepository.sharedPrefUtils.prefsSaveUser(appUser);

        //add(RefreshTokenEvent(appUser: appUser));
        yield Authenticated(appUser, origin: ORIGIN.RELOAD);
      } else {
        yield Unauthenticated(origin: ORIGIN.RELOAD);
      }
    } catch (_) {
      yield Unauthenticated(origin: ORIGIN.RELOAD);
    }
  }

  Stream<AuthState> _mapLogoutEventToState() async* {
    // NB! wait a bit so that SettingsScreen is closed!!!
    await Future.delayed(const Duration(milliseconds: 200));

    await _userRepository.signOut();
    yield Unauthenticated(origin: ORIGIN.LOGOUT);
  }

  Stream<AuthState> _mapLoginWithApplePressedToState() async* {
    try {
      add(WarnUserEvent(List<String>()..add("progress_start"),
          duration: Duration(seconds: 3)));

      AppUser appUser = await _userRepository.signInWithApple();
      CommonUtils.logger.d('login_bloc.loginSuccess');

      _userRepository.hiveStore.save(PREFKEYS[PREFKEY.APP_USER], appUser);
      //_userRepository.sharedPrefUtils.prefsSaveUser(appUser);
      //add(RefreshTokenEvent(appUser: appUser));

      add(WarnUserEvent(List<String>()..add("progress_stop")));
      yield Authenticated(appUser, origin: ORIGIN.LOGIN);
    } on LoginError catch (loginError) {
      CommonUtils.logger.w("login_bloc.loginError: ${loginError.toJson()}");
      //yield LoginState.failure(detail: loginError.toJson());
      yield Unauthenticated(detail: loginError.toJson(), origin: ORIGIN.LOGIN);
    } catch (ex, stx) {
      CommonUtils.logger.e("Exception: $ex");
      CommonUtils.logger.e("Stacktrace: $stx");

      //yield LoginState.failure();
      yield Unauthenticated(
          detail: Map()..putIfAbsent('message', () => 'General error'),
          origin: ORIGIN.LOGIN);
    }
  }

  Stream<AuthState> _mapLoginWithGooglePressedToState() async* {
    try {
      add(WarnUserEvent(List<String>()..add("progress_start"),
          duration: Duration(seconds: 3)));

      AppUser appUser = await _userRepository.signInWithGoogle();
      CommonUtils.logger.d('login_bloc.loginSuccess');
      //yield LoginState.success();

      _userRepository.hiveStore.save(PREFKEYS[PREFKEY.APP_USER], appUser);
      //_userRepository.sharedPrefUtils.prefsSaveUser(appUser);
      //add(RefreshTokenEvent(appUser: appUser));

      add(WarnUserEvent(List<String>()..add("progress_stop")));
      yield Authenticated(appUser, origin: ORIGIN.LOGIN);
    } on LoginError catch (loginError) {
      CommonUtils.logger.w("login_bloc.loginError: ${loginError.toJson()}");
      //yield LoginState.failure(detail: loginError.toJson());
      yield Unauthenticated(detail: loginError.toJson(), origin: ORIGIN.LOGIN);
    } catch (ex, stx) {
      CommonUtils.logger.e("Exception: $ex");
      CommonUtils.logger.e("Stacktrace: $stx");

      //yield LoginState.failure();
      yield Unauthenticated(
          detail: Map()..putIfAbsent('message', () => 'General error'),
          origin: ORIGIN.LOGIN);
    }
  }

  Stream<AuthState> _mapEnrichAppUserToState(EnrichAppUserEvent event) async* {
    //String userId = _userRepository.sharedPrefUtils.prefsGetUserId();
    String userId =
        _userRepository.hiveStore.read(PREFKEYS[PREFKEY.APP_USERID]);
    if (userId == null || event.actions == null) {
      return;
    }
    Map<String, dynamic> deviceInfo = Map();
    Map<String, dynamic> locationInfo = Map();
    if (event.actions.contains('DEVICEINFO')) {
      deviceInfo = await CommonUtils.getBasicDeviceInfo(
          //devicePlatform: _userRepository.sharedPrefUtils.prefsGetDevicePlatform());
          devicePlatform:
              _userRepository.hiveStore.read(PREFKEYS[PREFKEY.DEVICEPLATFORM]));
    }

    if (event.actions.contains('LOCATION')) {
      locationInfo = await _userRepository.ipInfoDb();
    }

    Map<String, dynamic> dataToUpdate = Map();
    if (deviceInfo.isNotEmpty) {
      deviceInfo.putIfAbsent('updatedAt', () => CommonUtils.getFormattedDate());
      dataToUpdate.putIfAbsent('deviceInfo', () => deviceInfo);
    }

    if (locationInfo.isNotEmpty) {
      locationInfo.putIfAbsent(
          'updatedAt', () => CommonUtils.getFormattedDate());
      dataToUpdate.putIfAbsent('locationInfo', () => locationInfo);
    }
    if (dataToUpdate.isNotEmpty) {
      _userRepository.storeUpdateAppUser(userId, dataToUpdate);
    }
    /*
    var usersCollection = Firestore.instance.collection("users");
    var userDoc =
        await usersCollection.where('uid', isEqualTo: "$userId").getDocuments();
    if (userDoc.documents.isNotEmpty) {
      String userDocId = userDoc.documents[0].documentID;
      if (deviceInfo.isNotEmpty) {
        deviceInfo.putIfAbsent(
            'updatedAt', () => CommonUtils.getFormattedDate());
        await usersCollection.document(userDocId).setData({
          'extData': {'deviceInfo': deviceInfo}
        }, merge: true);
      }

      if (locationInfo.isNotEmpty) {
        locationInfo.putIfAbsent(
            'updatedAt', () => CommonUtils.getFormattedDate());
        await usersCollection.document(userDocId).setData({
          'extData': {'locationInfo': locationInfo}
        }, merge: true);
      }
    }
    */

    //yield EnrichAppUserState();
  }

  Stream<AuthState> _mapWarnUserEventToState(WarnUserEvent event) async* {
    // NB! implement this further if necessary
    yield WarnUserState(event.actions,
        message: event.message, duration: event.duration);
  }

  Stream<AuthState> _mapRefreshTokenEventToState(
      RefreshTokenEvent event) async* {
    //AppUser appUser = event.appUser ?? _userRepository.sharedPrefUtils.prefsGetUser();
    AppUser appUser = event.appUser ?? _userRepository.hiveStore.readAppUser();
    //_userRepository.hiveStore.read(PREFKEYS[PREFKEY.APP_USER]);
    if (appUser != null) {
      appUser = await _userRepository.apiRefreshToken(appUser: appUser);
      if (CommonUtils.nullSafe(appUser.token).isNotEmpty) {
        _userRepository.hiveStore.save(PREFKEYS[PREFKEY.APP_USER], appUser);
        //_userRepository.sharedPrefUtils.prefsSaveUser(appUser);

        Map<String, dynamic> dataToUpdate = Map()
          ..putIfAbsent('token', () => appUser.token)
          ..putIfAbsent('token_created_at', () => appUser.token_created_at);
        _userRepository.storeUpdateAppUser(appUser.uid, dataToUpdate);

        yield RefreshTokenState(appUser: appUser, isRefreshed: true);
        //yield Authenticated(appUser, origin: ORIGIN.REFRESH_TOKEN);
      } else {
        yield RefreshTokenState(appUser: appUser, isRefreshed: false);
        /*yield Unauthenticated(
            detail: Map()
              ..putIfAbsent('message', () => 'Error while refreshToken'),
            origin: ORIGIN.REFRESH_TOKEN);
        */
      }
    }
  }
}
