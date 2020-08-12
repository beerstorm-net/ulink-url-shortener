import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_event.dart';
import '../models/models.dart';

class DataConnectivityService {
  /*StreamController<DataConnectionStatus> connectivityStreamController =
      StreamController<DataConnectionStatus>(); */
  var listener;
  UserRepository userRepository;
  DataConnectionChecker dataConnectionChecker;
  BuildContext context;
  DataConnectivityService({this.userRepository, this.context}) {
    dataConnectionChecker = DataConnectionChecker();
    dataConnectionChecker.checkInterval = Duration(seconds: 12);

    listener =
        dataConnectionChecker.onStatusChange.listen((dataConnectionStatus) {
      //connectivityStreamController.add(dataConnectionStatus);
      BlocProvider.of<SettingsBloc>(context).add(AppConnectivityEvent(
          dataConnectionStatus == DataConnectionStatus.connected));

      // NB! experimental-failed: disconnect is handled only after specific period of time
      /*if (dataConnectionStatus == DataConnectionStatus.disconnected) {
        String lastNoInternet = userRepository.prefsLastNoInternet();
        DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
        DateTime now = DateTime.now();
        String nowNoInternet = dateFormat.format(now);
        if (lastNoInternet.isNotEmpty) {
          if (now.difference(dateFormat.parse(lastNoInternet)).inSeconds >=
              20) {
            connectivityStreamController.add(dataConnectionStatus);
          }
        } else {
          userRepository.prefsNoInternet(nowNoInternet);
        }
      } else {
        userRepository.prefsClearNoInternet();
        connectivityStreamController.add(dataConnectionStatus);
      }
      */
    });
  }
}
