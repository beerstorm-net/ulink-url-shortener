part of 'links_bloc.dart';

abstract class LinksEvent extends Equatable {
  const LinksEvent();

  @override
  List<Object> get props => [];
}

class LoadLinksEvent extends LinksEvent {}

class AddLinkEvent extends LinksEvent {
  final AppLink link;

  AddLinkEvent(this.link);

  @override
  List<Object> get props => [link];

  @override
  String toString() => 'AddLinkEvent { link: $link }';
}
