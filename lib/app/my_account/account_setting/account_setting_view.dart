import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:asm_wt/app/app_service.dart';
import 'package:asm_wt/app/my_account/account_setting/account_setting_controller.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/account_list_weidget.dart';
import 'package:asm_wt/widget/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class AccountSettingView extends StatefulWidget {
  final AppService? appService;
  const AccountSettingView({Key? key, this.appService}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AccountSettingViewState();
}

class _AccountSettingViewState extends StateMVC<AccountSettingView> {
  late AccountSettingController con;
  _SupportState supportState = _SupportState.unknown;

  _AccountSettingViewState() : super(AccountSettingController()) {
    con = controller as AccountSettingController;
  }
  @override
  void initState() {
    super.initState();
    con.auth.isDeviceSupported().then((bool isSupported) => {
          print("=========$isSupported"),
          supportState =
              isSupported ? _SupportState.supported : _SupportState.unsupported,
        });
    checkBiometrics();
  }

  Future<void> checkBiometrics() async {
    late bool canCheckBiometrics;
    late bool canAuthenticate;
    try {
      canCheckBiometrics = await con.auth.canCheckBiometrics;
      canAuthenticate =
          canCheckBiometrics || await con.auth.isDeviceSupported();
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      con.canCheckBiometrics = canAuthenticate;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // double width = MediaQuery.of(context).size.width;
    // double height = MediaQuery.of(context).size.height;

    late LocalizationDelegate localizationDelegate =
        LocalizedApp.of(context).delegate;

    return Scaffold(
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        Text(
          '${translate('my_account.app_version')}${con.appVersion}',
          style: theme.textTheme.bodyMedium,
        )
      ],
      appBar: AppBarWidget(
        isDiscard: false,
        type: StaticModelType.manu,
        color: theme.colorScheme.primary,

        title: translate('my_account.settings'),
        leadingBack: true,
        backIcon: Icons.arrow_back,
        icon: Icons.help,
        // iconTitle: translate('button.help'),
        iconTitle: '',
        onRightPressed: () => showActionGenFunc(
            context, translate('text_header.help'), translate('contents.help')),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(StaticDataConfig.app_padding - 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(translate("my_account.app_setting"),
                style: theme.textTheme.headlineSmall
                    ?.merge(TextStyle(color: theme.colorScheme.onTertiary))),
            accountListWidget(
              context,
              tital: translate("my_account.location"),
              icon: Icons.location_on,
              hasArrow: false,
              widget: Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  activeColor: theme.colorScheme.secondary,
                  value: con.isLocationTracking ?? false,
                  onChanged: (val) {
                    setState(() {
                      con.isLocationTracking = val;
                    });
                    con.prefs.setBool("tracking", val);

                    print("-------_${con.prefs.getBool("tracking")}");
                  },
                ),
              ),
            ),
            accountListWidget(
              context,
              tital: translate("text_header.bio_scan"),
              icon: Icons.fingerprint,
              hasArrow: false,
              widget: Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                    activeColor: theme.colorScheme.secondary,
                    value: con.isBioScanEnable ?? false,
                    onChanged: con.canCheckBiometrics &&
                            supportState == _SupportState.supported
                        ? (val) {
                            setState(() {
                              con.isBioScanEnable = val;
                            });
                            con.prefs.setBool("bioScan", val);
                          }
                        : (val) {
                            showToastMessage(
                                context,
                                translate("bio_scan.message"),
                                theme.colorScheme.primary);
                          }),
              ),
            ),
            accountListWidget(context,
                tital: translate("button.change_language"),
                icon: Icons.language,
                hasArrow: false, onTap: () {
              modelBottomSheetFunc(
                  context,
                  StaticModelType.translate, //model type;
                  null, //navigation list;
                  null, // nav param list;
                  translate('text_header.change_lang'), //header title;
                  'English Language', //top title;
                  'Thai Language', //bottom title;
                  'lib/assets/images/en-flag.png', // top image path;
                  'lib/assets/images/th-flag.png', // bottom image path;
                  null,
                  null);
            },
                widget: localizationDelegate.currentLocale.languageCode == 'en'
                    ? Image.asset(
                        'lib/assets/images/en-flag.png',
                        height: 25,
                      )
                    : Image.asset(
                        'lib/assets/images/th-flag.png',
                        height: 25,
                      )),
          ],
        ),
      )),
    );
  }
}
