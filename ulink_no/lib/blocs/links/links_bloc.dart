import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:ulink/models/app_link.dart';
import 'package:ulink/models/link_repository.dart';

part 'links_event.dart';
part 'links_state.dart';

class LinksBloc extends Bloc<LinksEvent, LinksState> {
  @override
  LinksState get initialState => InitialLinksState();

  final LinkRepository _linkRepository;
  LinksBloc({@required LinkRepository linkRepository})
      : assert(linkRepository != null),
        _linkRepository = linkRepository,
        super(InitialLinksState());

  @override
  Stream<LinksState> mapEventToState(LinksEvent event) async* {
    if (event is LoadLinksEvent) {
      yield* _loadLinksToState(event);
    }
  }

  Stream<LinksState> _loadLinksToState(LinksEvent event) async* {
    List<AppLink> links = await _linkRepository.loadLinks();
    yield LinksLoaded(links);
  }
}
