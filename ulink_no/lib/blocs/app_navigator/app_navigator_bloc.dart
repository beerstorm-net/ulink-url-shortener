import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../shared/app_defaults.dart';

part 'app_navigator_event.dart';
part 'app_navigator_state.dart';

class AppNavigatorBloc extends Bloc<AppNavigatorEvent, AppNavigatorState> {
  AppNavigatorBloc() : super(InitialAppNavigatorState());

  @override
  Stream<AppNavigatorState> mapEventToState(AppNavigatorEvent event) async* {
    if (event is AppPageEvent) {
      yield AppPageState(tab: event.tab);
    }
  }
}
