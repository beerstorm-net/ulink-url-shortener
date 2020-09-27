import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings_ui/settings_ui.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/settings/settings_state.dart';
import '../models/app_user.dart';
import '../models/user_repository.dart';
import '../shared/app_localizations.dart';
import '../shared/common_utils.dart';
import '../widgets/common_dialogs.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Locale appLocale;
  UserRepository _userRepository;
  AppUser appUser;
  Map<String, String> packageInfo;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext buildContext) {
    _userRepository =
        _userRepository ?? RepositoryProvider.of<UserRepository>(buildContext);

    if (appLocale == null) {
      if (this.mounted == true) {
        setState(() {
          //appLocale = _userRepository.sharedPrefUtils.prefsGetLocale();
          appLocale = _userRepository.hiveStore.readAppLocale();
          //_userRepository.hiveStore.read(PREFKEYS[PREFKEY.APP_LANGCODE]);
        });
      }
    }

    if (appUser == null) {
      _userRepository.getAppUser().then((_appUser) => this.mounted == true
          ? setState(() {
              appUser = _appUser;
            })
          : CommonUtils.logger
              .d("SettingsUi is unmounted...skip setState for $_appUser"));
    }

    if (packageInfo == null) {
      CommonUtils.getPackageInfo().then((_packageInfo) => this.mounted == true
          ? setState(() {
              packageInfo = _packageInfo;
            })
          : CommonUtils.logger
              .d("SettingsUi is unmounted...skip setState for $_packageInfo"));
    }

    return BlocConsumer<SettingsBloc, SettingsState>(
        listener: (BuildContext context, SettingsState state) {
      return (state is AppLocaleState);
    }, builder: (context, state) {
      if (state is AppLocaleState && state.appLocale != null) {
        appLocale = state.appLocale;
      }

      return Container(
        child: SettingsList(
          //backgroundColor: Colors.blueGrey.withAlpha(122),
          /*TODO: colors: SettingsColors(
            backgroundColor: Colors.white, //.blueGrey.withAlpha(122),
            fontColor: Colors.blueGrey,
            titleColor: Colors.blueGrey,
            subtitleColor: Colors.blueGrey,
          ),*/
          sections: [
            SettingsSection(
              title: AppLocalizations.of(context).translate("settings_common"),
              tiles: [
                SettingsTile(
                  title: AppLocalizations.of(context).translate("locale"),
                  subtitle: appLocale != null
                      ? AppLocalizations.of(context)
                          .translate("settings_lang_" + appLocale.languageCode)
                      : "...",
                  leading: Icon(Icons.language),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return changeLocaleDialog(context);
                      },
                    );
                  },
                ),
              ],
            ),
            SettingsSection(
              title: AppLocalizations.of(context).translate("settings_account"),
              tiles: [
                SettingsTile(
                  title:
                      AppLocalizations.of(context).translate("settings_email"),
                  subtitle: appUser != null ? appUser.email : '...',
                  leading: Icon(Icons.email),
                  onTap: () {
                    // TODO: display user email etc
                  },
                ),
                SettingsTile(
                  title:
                      AppLocalizations.of(context).translate("settings_logout"),
                  leading: Icon(Icons.exit_to_app),
                  onTap: () {
                    _logoutDialog(buildContext);
                  },
                ),
              ],
            ),
            SettingsSection(
              title: AppLocalizations.of(context).translate("settings_misc"),
              tiles: [
                /*if (_userRepository.rateMyApp != null)
                  SettingsTile(
                    title: AppLocalizations.of(context)
                        .translate("settings_ratemyapp"),
                    leading: Icon(Icons.star),
                    onTap: () async {
                      //BlocProvider.of<SettingsBloc>(context).add(AppRatingEvent("REQUEST"));
                      _userRepository.showRateDialog(context);
                    },
                  ),
                */
                SettingsTile(
                  title: AppLocalizations.of(context)
                      .translate("settings_privacy"),
                  leading: Icon(Icons.description),
                  onTap: () async {
                    String theUrl = _userRepository.remoteConfig
                        .getString('fabulam_privacy');
                    if (appLocale != null &&
                        !appLocale.languageCode.startsWith("en")) {
                      theUrl += theUrl.contains("?") ? "&" : "?";
                      theUrl += "lang=" + appLocale.languageCode;
                    }
                    await CommonUtils.launchURL(theUrl);
                  },
                ),
                SettingsTile(
                  title:
                      AppLocalizations.of(context).translate("settings_about"),
                  leading: Icon(Icons.info),
                  onTap: () async {
                    String theUrl =
                        _userRepository.remoteConfig.getString('fabulam_web');
                    if (appLocale != null &&
                        !appLocale.languageCode.startsWith("en")) {
                      theUrl += theUrl.contains("?") ? "&" : "?";
                      theUrl += "lang=" + appLocale.languageCode;
                    }
                    await CommonUtils.launchURL(theUrl);
                  },
                ),
              ],
            ),
            SettingsSection(
              title: AppLocalizations.of(context).translate("settings_version"),
              tiles: [
                SettingsTile(
                    //title: AppLocalizations.of(context).translate("settings_version"),
                    title: packageInfo != null
                        ? '${packageInfo['version'] + "+" + packageInfo['buildNumber']}'
                        : '...',
                    leading: Icon(Icons.info_outline)),
              ],
            )
          ],
        ),
      );
    });
  }

  void _logoutDialog(BuildContext context) async {
    bool confirmed = await confirmationDialog(context, action: 'logout');
    if (confirmed) {
      BlocProvider.of<AuthBloc>(context).add(
        LogoutEvent(),
      );

      try {
        Navigator.pop(context);
      } catch (_) {
        CommonUtils.logger.w('IgnorableError: while pop SettingsScreen...');
      }
    }
  }
}
