import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/common_utils.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object event) {
    CommonUtils.logger.d('onEvent: $event');
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    CommonUtils.logger.d('onTransition: $transition');
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Cubit cubit, Object error, StackTrace stacktrace) {
    CommonUtils.logger.d('onError: $error, $stacktrace');
    super.onError(cubit, error, stacktrace);
  }

  @override
  void onChange(Cubit cubit, Change change) {
    CommonUtils.logger.d('onChange: $cubit, $change');
    super.onChange(cubit, change);
  }
}
