part of 'links_bloc.dart';

abstract class LinksState extends Equatable {
  const LinksState();

  @override
  List<Object> get props => [];
}

class InitialLinksState extends LinksState {}

class LinksLoaded extends LinksState {
  final List<AppLink> links;

  const LinksLoaded([this.links = const []]);

  @override
  List<Object> get props => [links];

  @override
  String toString() => 'LinksLoaded { links: $links }';
}

class LinkAdded extends LinksState {
  final AppLink link;

  LinkAdded(this.link);

  @override
  List<Object> get props => [link];

  @override
  String toString() => 'LinkAdded { link: $link }';
}
