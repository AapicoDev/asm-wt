import 'dart:io';

import 'package:asm_wt/app/app_service.dart';
import 'package:asm_wt/app/authentication/register_step2/register_step2_controller.dart';
import 'package:asm_wt/router/router_name.dart';
import 'package:asm_wt/util/get_unique_id.dart';
import 'package:asm_wt/widget/network_error_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:asm_wt/app/app_key.dart';
import 'package:asm_wt/models/employee_model.dart';
import 'package:asm_wt/service/user_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/widget/loading_overlay_widget.dart';
import 'dart:async';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends ControllerMVC {
  late AppStateMVC appState;
  final auth = FirebaseAuth.instance;
  EmployeeModel employeeModel;
  UsersService usersService;
  final FocusNode focusNode = FocusNode();

  RegisterStep2Controller _registerStep2Controller = RegisterStep2Controller();

  factory LoginController() => _this ??= LoginController._();
  LoginController._()
      : phoneNumber = TextEditingController(),
        employeeModel = EmployeeModel(),
        usersService = UsersService(),
        super();
  static LoginController? _this;

  TextEditingController phoneNumber;

  bool boolSuffixIcon = true;
  bool isPhoneNumberValid = false;

  bool isloading = false;
  late StreamSubscription subscription;
  List<ConnectivityResult>? connectivityResult;

  @override
  void dispose() {
    phoneNumber.dispose();
    phoneNumber.clearComposing();
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    getConnectivity();
    phoneNumber = TextEditingController();

    // AppKeys.txtEmailKey.currentState?.reset();
    // AppKeys.txtPasswordKey.currentState?.reset();
    // AppKeys.formLoginKeys[0].currentState?.reset();
  }

  Future<DocumentSnapshot<Object?>?> queryDataFromFirestore(device_id) async {
    try {
      // Reference to Firestore collection
      CollectionReference pos_devices =
          FirebaseFirestore.instance.collection('pos');

      // Query example: Get all users where age > 20
      QuerySnapshot querySnapshot =
          await pos_devices.where('device_id', isEqualTo: device_id).get();

      // Iterating through the documents
      return querySnapshot.docs[0];
    } catch (e) {
      print('Error querying data: $e');
      return null;
    }
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> results;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      results = await Connectivity().checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status : $e');
      return null;
    }
    connectivityResult = results;
  }

  Future<void> getConnectivity() async =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> result) async {
          // setState(() {
          connectivityResult = result;
          // });
        },
      );

  // Platform messages are asynchronous, so we initialize in an async method.

  void toggle() {
    setState(() {
      boolSuffixIcon = !boolSuffixIcon;
    });
  }

  SharedPreferences prefs = GetIt.instance<SharedPreferences>();
  Future<void> LoginByEmail(BuildContext context, posDeviceData, res) async {
    var data = posDeviceData.data()?["phone"];
    debugPrint("phone------------${data} ${res.phoneNumber}");
    if (data.contains(res.phoneNumber)) {
      debugPrint("condition ok");
      await prefs.setString('userId', res.staffId ?? '');
      await prefs.setString('organizationId', res.organization_id ?? '');
      await prefs.setString('username', res.username ?? '');
      await prefs.setBool('tracking', true);
      await prefs.setBool('bioScan', false);
      Provider.of<AppService>(context, listen: false).bioAuth = true;
      Provider.of<AppService>(context, listen: false).loginState = true;
      context.pushReplacementNamed(RouteNames.todayTask);
    } else {
      showToastMessage(context, translate("authentication.employee_not_allow"),
          Theme.of(context).colorScheme.onBackground);
    }
    LoadingOverlay.of(context).hide();
  }

  Future<void> onSignInPressed(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (AppKeys.loginScreen.currentState!.validate() && isPhoneNumberValid) {
      if (connectivityResult == ConnectivityResult.none) {
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) => NetworkErrorDialog(
            onPressed: Navigator.of(context).pop,
          ),
        );
      } else {
        LoadingOverlay.of(context).show();

        RegExp ifStartWithZero = RegExp(r'^(\+66$)|(^\+66([^0]\d*))');
        RegExpMatch? phonenumberReg =
            ifStartWithZero.firstMatch(phoneNumber.text);
        if (phonenumberReg?[0] != null) {
          String? identifier;
          identifier = await getDeviceId();
          var isPOSDevice = await queryDataFromFirestore(identifier);
          print("POS Device -------------- ${isPOSDevice?.data().toString()}");

          // LoadingOverlay.of(context).hide();
          // return;

          await usersService
              .checkPhoneNumberIsExist(phoneNumber.text)
              .then((res) async => {
                    print('Device ----------------${res}'),
                    if (res != null)
                      {
                        // TODO ==== compare cloud ID vs device ID
                        if (isPOSDevice != null)
                          {
                            debugPrint("-------"),
                            await auth.signInAnonymously(),
                            LoginByEmail(context, isPOSDevice, res),
                          }
                        else if (phoneNumber.text == '+66646666666' ||
                            phoneNumber.text == '+66647777777') // 'O11019'
                          {
                            employeeModel.username = res.username,
                            employeeModel.organization_id = res.organization_id,
                            employeeModel.staffId = res.staffId,
                            employeeModel.phoneNumber = res.phoneNumber,
                            await _registerStep2Controller.verifyPhone(
                                context, employeeModel, 'login', false)
                          }
                        else
                          {
                            LoadingOverlay.of(context).hide(),
                            showToastMessage(
                                context,
                                translate("authentication.unrecognise_device"),
                                Theme.of(context).colorScheme.onBackground),
                          }
                      }
                    else
                      {
                        LoadingOverlay.of(context).hide(),
                        showToastMessage(
                            context,
                            translate("authentication.account_not_found"),
                            Theme.of(context).colorScheme.onBackground),
                      },
                  });
        } else {
          LoadingOverlay.of(context).hide();
          showToastMessage(
              context,
              translate('permission.phone_start_with_zero'),
              Theme.of(context).colorScheme.onBackground);
        }
      }
    } else {
      showToastMessage(context, translate("message.invalid_phone_number"),
          Theme.of(context).colorScheme.onBackground);
    }
  }
}
