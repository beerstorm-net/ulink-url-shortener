import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jiffy/jiffy.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:share/share.dart';
import 'package:ulink/blocs/links/links_bloc.dart';
import 'package:ulink/models/app_link.dart';
import 'package:ulink/shared/common_utils.dart';
import 'package:ulink/widgets/common_dialogs.dart';

import '../models/user_repository.dart';

class LinksScreen extends StatefulWidget {
  LinksScreen({Key key}) : super(key: key);

  @override
  _LinksScreenState createState() => _LinksScreenState();
}

class _LinksScreenState extends State<LinksScreen> {
  UserRepository _userRepository;
  List<AppLink> links = List();
  RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  final SlidableController _slidableController = SlidableController();

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
              _refreshController.refreshCompleted();
            });
          }
        }
      },
      child: Container(
        //child: Text('LINKS... show!... \n $links'),
        child: SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            header: WaterDropMaterialHeader(), //WaterDropHeader(),
            onRefresh: () {
              BlocProvider.of<LinksBloc>(context).add(LoadLinksEvent());
            },
            onLoading: () {
              BlocProvider.of<LinksBloc>(context).add(LoadLinksEvent());
            },
            child: ListView.builder(
                itemCount: links.length,
                itemBuilder: (context, index) {
                  AppLink link = links[index];
                  String shortLinkRef =
                      _userRepository.remoteConfig.getString('ulink_base_url');
                  shortLinkRef += "/" + link.short_link;
                  //return _buildListItem(link);
                  return Slidable(
                    child: _buildListItem(link, shortLinkRef),
                    actionPane: SlidableDrawerActionPane(),
                    actionExtentRatio: 0.25,
                    controller: _slidableController,
                    actions: <Widget>[
                      IconSlideAction(
                        caption: 'Copy',
                        color: Colors.blue,
                        icon: Icons.content_copy,
                        closeOnTap: false,
                        onTap: () async {
                          await FlutterClipboard.copy(shortLinkRef);
                          //print('copied to clipboard!!! $shortLinkRef');
                          showAlertDialog(context,
                              "Link copied to clipboard! \n$shortLinkRef",
                              type: "SUCCESS", autoHide: Duration(seconds: 3));
                        },
                      ),
                      IconSlideAction(
                        caption: 'Share',
                        color: Colors.blueGrey,
                        icon: Icons.share,
                        closeOnTap: false,
                        onTap: () {
                          String shareText =
                              'Shorten & Simplify via uLINK.no -> $shortLinkRef';
                          print('shareText: $shareText');
                          Share.share(shareText);
                        },
                      ),
                    ],
                  );
                })),
      ),
    );
  }

  _buildListItem(AppLink link, String shortLinkRef) {
    //return Text('link: $link');

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            //leading: Icon(Icons.link, size: 28, color: Colors.black12),
            /*leading: Image.asset(
              'assets/images/app/app_icon.png',
              scale: 2,
            ),*/
            title: Text(
              shortLinkRef,
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(' '),
                Text(
                  link.long_link,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.blueAccent,
                      fontStyle: FontStyle.italic),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
                Text(
                  Jiffy(link.createdAt).fromNow(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueAccent,
                    fontStyle: FontStyle.italic,
                  ),
                )
              ],
            ),
            //onTap: () {},
            //onLongPress: () {},
          ),
        ],
      ),
    );
  }
}
