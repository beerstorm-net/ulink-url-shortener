part of 'app_navigator_bloc.dart';

abstract class AppNavigatorEvent extends Equatable {
  const AppNavigatorEvent();

  @override
  List<Object> get props => [];
}

class AppPageEvent extends AppNavigatorEvent {
  final APP_PAGE tab;

  const AppPageEvent({this.tab = APP_PAGE.LINK});

  @override
  List<Object> get props => [tab];

  @override
  String toString() => 'AppPageEvent {tab: $tab}';
}
