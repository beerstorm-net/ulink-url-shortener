import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:progress_dialog/progress_dialog.dart';

import '../blocs/settings/bloc.dart';
import '../shared/app_localizations.dart';
import '../shared/common_utils.dart';

// language selection for changing locale
changeLocaleDialog(context) {
  return SimpleDialog(
    title: Text(
      AppLocalizations.of(context).translate("locale"),
      style: TextStyle(fontSize: 16),
    ),
    children: List<Widget>.generate(appSupportedLocales.length, (int index) {
      Locale appLocale = appSupportedLocales[index];
      String flag;
      if ('en' == appLocale.languageCode) {
        flag = 'gb' + '.png';
      } else if (appLocale.languageCode.startsWith('nb')) {
        flag = 'no' + '.png';
      } else {
        flag = appLocale.languageCode + '.png';
      }

      return SimpleDialogOption(
        child: Image.asset(
          'icons/flags/png/' + flag,
          package: 'country_icons',
          width: 28,
          height: 28,
        ),
        //child: Text(appLocale.languageCode),
        onPressed: () {
          CommonUtils.logger.d(appLocale);
          BlocProvider.of<SettingsBloc>(context).add(AppLocaleEvent(appLocale));
          Navigator.of(context).pop();
        },
      );
    }),
  );
}

// confirm before proceeding
Future<bool> confirmationDialog(BuildContext context, {String action}) async {
  action = action ?? 'logout'; // default action: logout

  // NB! action values: memory_delete, logout

  String keyTitle = action + '_title';
  String keyText = action + '_text';

  return showDialog<bool>(
    context: context,
    barrierDismissible:
        false, // dialog is dismissible with a tap on the barrier
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context).translate(keyTitle)),
        content: Row(
          children: <Widget>[
            Expanded(
              child: Text(AppLocalizations.of(context).translate(keyText)),
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
            color: Colors.lightGreen,
            shape: StadiumBorder(),
            child: Text(AppLocalizations.of(context).translate('no'),
                style: TextStyle(color: Colors.white, fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          FlatButton(
            color: Colors.redAccent,
            shape: StadiumBorder(),
            child: Text(AppLocalizations.of(context).translate('yes'),
                style: TextStyle(color: Colors.white, fontSize: 18)),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}

theSnackBar(context, String message) {
  return SnackBar(
    duration: Duration(seconds: 2),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: 260.0,
          child: Text(
            //AppLocalizations.of(context).translate('soon') + ' ' + message,
            message,
            overflow: TextOverflow.fade,
            softWrap: false,
          ),
        ),
        Icon(Icons.error),
      ],
    ),
    backgroundColor: Colors.orangeAccent,
  );
}

// show alert as a dialog
AwesomeDialog _awesomeDialog;
showAlertDialog(context, String message,
    {String type = "INFO", Duration autoHide = const Duration(seconds: 2)}) {
  DialogType dialogType = DialogType.INFO;
  Color textColor = Colors.blueGrey;
  if (type.toUpperCase() == "SUCCESS") {
    dialogType = DialogType.SUCCES;
    textColor = Colors.green;
  } else if (type.toUpperCase() == "WARNING") {
    dialogType = DialogType.WARNING;
    textColor = Colors.deepOrange;
  } else if (type.toUpperCase() == "ERROR") {
    dialogType = DialogType.ERROR;
    textColor = Colors.red;
  }
  _awesomeDialog = AwesomeDialog(
    context: context,
    animType: AnimType.LEFTSLIDE,
    dismissOnTouchOutside: true,
    dismissOnBackKeyPress: true,
    headerAnimationLoop: true,
    dialogType: dialogType,
    body: Container(
      padding: EdgeInsets.all(4.0),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
        overflow: TextOverflow.fade,
        maxLines: 6,
        softWrap: true,
      ),
    ),
    btnOk: null,
    btnCancel: null,
    autoHide: autoHide,
  );
  _awesomeDialog.show();
}

buildProgressDialog(context, String message,
    {bool isDismissible = false, bool showLogs, Duration autoHide}) {
  ProgressDialog _progressDialog = ProgressDialog(
    context,
    type: ProgressDialogType.Normal,
    isDismissible: isDismissible,
    autoHide: autoHide ?? Duration(seconds: 2),
    showLogs: showLogs ?? CommonUtils.isDebug,
  );
  _progressDialog.style(
    message: message.isNotEmpty ? message : '...',
    messageTextStyle: TextStyle(
        color: Colors.blueGrey, fontSize: 20.0, fontWeight: FontWeight.w600),
    progressWidget: SpinKitPouringHourglass(
      color: Colors.blueGrey,
      //size: 44,
    ),
    progressWidgetAlignment: Alignment.topLeft,
    dialogAlignment: Alignment.topCenter,
    //padding: EdgeInsets.only(top: 8.0),
  );

  return _progressDialog;
}

class LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
