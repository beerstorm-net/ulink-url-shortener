part of 'app_navigator_bloc.dart';

abstract class AppNavigatorState extends Equatable {
  const AppNavigatorState();

  @override
  List<Object> get props => [];
}

class InitialAppNavigatorState extends AppNavigatorState {}

class AppPageState extends AppNavigatorState {
  final APP_PAGE tab;

  const AppPageState({this.tab = APP_PAGE.LINK});

  @override
  List<Object> get props => [tab];

  @override
  String toString() => 'AppPageState {tab: $tab}';
}
