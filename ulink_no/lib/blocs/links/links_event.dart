part of 'links_bloc.dart';

abstract class LinksEvent extends Equatable {
  const LinksEvent();

  @override
  List<Object> get props => [];
}

class LoadLinksEvent extends LinksEvent {}

class AddLinkEvent extends LinksEvent {
  final List<AppLink> links;

  AddLinkEvent(this.links);

  @override
  List<Object> get props => [links];

  @override
  String toString() => 'AddLinkEvent { links: $links }';
}
