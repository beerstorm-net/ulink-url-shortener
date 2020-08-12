import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:meta/meta.dart';

import './bloc.dart';
import '../../models/user_repository.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final UserRepository _userRepository;
  SettingsBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(InitialSettingsState());

  //@override
  SettingsState get initialState => InitialSettingsState();

  @override
  Stream<SettingsState> mapEventToState(
    SettingsEvent event,
  ) async* {
    if (event is AppLocaleEvent) {
      yield* _mapChangeLocaleToState(event);
    } else if (event is AppConnectivityEvent) {
      yield* _mapAppConnectivityToState(event);
    } else if (event is AppleSignInAvailableEvent) {
      yield* _mapAppleSignInAvailableEventToState(event);
    }
  }

  Stream<SettingsState> _mapChangeLocaleToState(AppLocaleEvent event) async* {
    if (event.appLocale != null) {
      _userRepository.sharedPrefUtils
          .prefsSaveLocale(event.appLocale.languageCode);
      //await Jiffy.locale(event.appLocale.languageCode.startsWith('nb')? 'nb' : event.appLocale.languageCode);
      await Jiffy.locale(event.appLocale.languageCode);

      yield AppLocaleState(event.appLocale);
    }
  }

  Stream<SettingsState> _mapAppConnectivityToState(
      AppConnectivityEvent event) async* {
    if (event.isConnected != null) {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      DateTime now = DateTime.now();
      String nowStr = dateFormat.format(now);
      if (event.isConnected == false) {
        _userRepository.sharedPrefUtils.prefsNoInternet(nowStr);
      } else {
        _userRepository.sharedPrefUtils.prefsClearNoInternet();
      }

      yield AppConnectivityState(event.isConnected);
    }
  }

  Stream<SettingsState> _mapAppleSignInAvailableEventToState(
      AppleSignInAvailableEvent event) async* {
    if (event.isAvailable != null) {
      // NB! process event if necessary

      yield AppleSignInAvailableState(event.isAvailable);
    }
  }
}
