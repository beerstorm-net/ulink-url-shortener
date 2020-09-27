import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ulink/blocs/links/links_bloc.dart';
import 'package:ulink/models/app_link.dart';
import 'package:ulink/shared/common_utils.dart';

import '../models/user_repository.dart';

class LinksScreen extends StatefulWidget {
  LinksScreen({Key key}) : super(key: key);

  @override
  _LinksScreenState createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  UserRepository _userRepository;
  List<AppLink> links = List();

  @override
  Widget build(BuildContext buildContext) {
    _userRepository =
        _userRepository ?? RepositoryProvider.of<UserRepository>(buildContext);

    return BlocListener<LinksBloc, LinksState>(
      listener: (context, state) {
        if (state is LinksLoaded) {
          CommonUtils.logger.d('links: ${state.links}');
          if (state.links.isNotEmpty) {
            setState(() {
              links = state.links;
            });
          }
        }
      },
      child: Container(
        child: Text('LINKS... show!... \n $links'),
      ),
    );
  }
}
