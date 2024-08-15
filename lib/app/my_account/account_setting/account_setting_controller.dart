import 'package:asm_wt/app/app_controller.dart';
import 'package:asm_wt/widget/alert_dialog_widget.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class AccountSettingController extends ControllerMVC {
  late final AppStateMVC appState;
  User? user;
  bool locatoinSwitchBtn = true;
  final SharedPreferences prefs = GetIt.instance<SharedPreferences>();
  AppController appController = AppController();
  final LocalAuthentication auth = LocalAuthentication();
  bool? isLocationTracking;
  bool? isBioScanEnable;
  bool canCheckBiometrics = false;

  factory AccountSettingController([StateMVC? state]) =>
      _this ??= AccountSettingController._(state);
  AccountSettingController._(StateMVC? state) : super(state);
  static AccountSettingController? _this;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isLocationTracking = prefs.getBool("tracking");
    isBioScanEnable = prefs.getBool("bioScan");
  }

  void showAction(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialogWidget(
          title: 'Help',
          content:
              "Once the purpose and focus of the evaluation are determined, you should identify specific evaluation questions. Ideally policy evaluation is built into the entire policy process; however, achieving this ideal is not always feasible.",
        );
      },
    );
  }

  Future<void> sampleFunc(BuildContext context) async {
    await null;
  }
}
