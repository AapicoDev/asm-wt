import 'dart:async';
import 'dart:io';

import 'package:asm_wt/service/RESTAPI/thaibulksms_otp_service.dart';
import 'package:get_it/get_it.dart';
import 'package:asm_wt/app/app_service.dart';
import 'package:asm_wt/core/firebase/auth_service.dart';
import 'package:asm_wt/core/firebase/implement/firebase_auth_service.dart';
import 'package:asm_wt/models/employee_model.dart';
import 'package:asm_wt/models/thaibulksms_model.dart';
import 'package:asm_wt/router/router_name.dart';
import 'package:asm_wt/service/device_model_service.dart';
import 'package:asm_wt/service/user_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/loading_overlay_widget.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterStep2Controller extends ControllerMVC {
  late final AppStateMVC appState;
  bool boolSuffixIcon = true;
  String? errorMessage = '';
  String? type;
  bool isThaiBulkSms = false;
  String? verID;
  String? token;
  EmployeeModel? employeeModel;
  int counter = 30;
  Timer? timer;
  final auth = FirebaseAuth.instance;
  UsersService usersService = UsersService();
  AllDevicesService allDevicesService = AllDevicesService();
  final AuthService _authService = FirebaseAuthService();
  SharedPreferences prefs = GetIt.instance<SharedPreferences>();
  ThaiBulkOTPService thaiBulkOTPService = ThaiBulkOTPService();

  TextEditingController otpController = TextEditingController();

  factory RegisterStep2Controller([StateMVC? state]) =>
      _this ??= RegisterStep2Controller._(state);
  RegisterStep2Controller._(StateMVC? state) : super(state);
  static RegisterStep2Controller? _this;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    otpController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    otpController = TextEditingController();
    counter = 30;
    startTimer();
  }

  void startTimer() {
    if (timer != null) {
      timer?.cancel();
    }
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (counter > 0) {
          counter--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> onResendPressed(BuildContext context) async {
    // await verifyPhone(context, employeeModel, type, true);
    await thaiBulkOTPService
        .requestThaiBulkSmsOTP(employeeModel?.phoneNumber ?? '')
        .then((res) => {
              if (res?.status == "success")
                {
                  setState(() {
                    counter = 30;
                  }),
                  startTimer(),
                  context.pushReplacementNamed(RouteNames.register2,
                      pathParameters: {
                        'verID': '12345',
                        'token': res?.token ?? '',
                        'type': type ?? '',
                        'isThaiBulkSms': 'true'
                      },
                      extra: employeeModel),
                },
            });
  }

  void toggle() {
    setState(() {
      boolSuffixIcon = !boolSuffixIcon;
    });
  }

  Future<void> verifyPhone(BuildContext context, EmployeeModel? employeeModel,
      String? type, bool isResentCode) async {
    // await auth.setSettings(
    //     forceRecaptchaFlow: true, appVerificationDisabledForTesting: true);

    //check if phone number is already register;
    LoadingOverlay.of(context).show();

    if (type == "login") {
      await auth
          .verifyPhoneNumber(
            phoneNumber: employeeModel?.phoneNumber,
            timeout: const Duration(seconds: 32),
            verificationCompleted: (PhoneAuthCredential credential) async {},
            verificationFailed: (FirebaseAuthException e) async {
              await thaiBulkOTPService
                  .requestThaiBulkSmsOTP(employeeModel?.phoneNumber ?? '')
                  .then((res) => {
                        if (res?.status == "success")
                          {
                            setState(() {
                              counter = 30;
                            }),
                            startTimer(),
                            context.pushReplacementNamed(RouteNames.register2,
                                pathParameters: {
                                  'verID': '123',
                                  'token': res?.token ?? '',
                                  'type': type ?? '',
                                  'isThaiBulkSms': 'true'
                                },
                                extra: employeeModel),
                          },
                      });
            },
            codeSent: (String verificationId, int? resendToken) {
              if (!isResentCode) {
                showToastMessage(context, translate("authentication.opt_sent"),
                    Theme.of(context).colorScheme.primary);

                context.pushReplacementNamed(RouteNames.register2,
                    pathParameters: {
                      'verID': verificationId,
                      'type': type ?? '',
                      'isThaiBulkSms': 'false',
                      'token': '12345'
                    },
                    extra: employeeModel);
              } else {
                setState(() {
                  counter = 30;
                });
                startTimer();

                showToastMessage(context, "Resent code success!",
                    Theme.of(context).colorScheme.primary);
              }
            },
            codeAutoRetrievalTimeout: (String verificationId) {
              print("-------------Code retrieve time out.");
            },
          )
          .whenComplete(() => LoadingOverlay.of(context).hide());
      ;
    } else {
      //if register;
      await usersService
          .checkPhoneNumberIsExist(employeeModel?.phoneNumber)
          .then(
            (res) async => {
              debugPrint('${res}'),
              if (res != null && res.isActivated == true)
                {
                  showToastMessage(context, translate("message.exist_phon_num"),
                      Theme.of(context).colorScheme.onBackground),
                }
              else
                {
                  await auth.verifyPhoneNumber(
                    phoneNumber: employeeModel?.phoneNumber,
                    timeout: const Duration(seconds: 32),
                    verificationCompleted: (PhoneAuthCredential credential) {},
                    verificationFailed: (FirebaseAuthException e) async {
                      await thaiBulkOTPService
                          .requestThaiBulkSmsOTP(
                              employeeModel?.phoneNumber ?? '')
                          .then((res) => {
                                if (res?.status == "success")
                                  {
                                    setState(() {
                                      counter = 30;
                                    }),
                                    startTimer(),
                                    context.pushReplacementNamed(
                                        RouteNames.register2,
                                        pathParameters: {
                                          'verID': '123',
                                          'token': res?.token ?? '',
                                          'type': type ?? '',
                                          'isThaiBulkSms': 'true'
                                        },
                                        extra: employeeModel),
                                  },
                              });
                    },
                    codeSent: (String verificationId, int? resendToken) {
                      if (!isResentCode) {
                        showToastMessage(
                            context,
                            translate("authentication.opt_sent"),
                            Theme.of(context).colorScheme.primary);
                        context.pushReplacementNamed(RouteNames.register2,
                            pathParameters: {
                              'verID': verificationId,
                              'type': type ?? '',
                              'isThaiBulkSms': 'false',
                              'token': '12345'
                            },
                            extra: employeeModel);
                      } else {
                        setState(() {
                          counter = 30;
                        });
                        startTimer();

                        showToastMessage(context, "Resent code success!",
                            Theme.of(context).colorScheme.primary);
                      }
                    },
                    codeAutoRetrievalTimeout: (String verificationId) {
                      print("-------------Code retrieve time out.");
                    },
                  ),
                }
            },
          )
          .whenComplete(() => LoadingOverlay.of(context).hide());
      ;
    }
  }

  Future<void> verifyOTP(BuildContext context, String? type, String? verID,
      String smsCode, EmployeeModel? employeeModel, int duration) async {
    FocusScope.of(context).requestFocus(FocusNode());
    PhoneAuthCredential phoneAuthCredential =
        PhoneAuthProvider.credential(verificationId: verID!, smsCode: smsCode);
    signInWithPhoneAuthCredential(
        context, phoneAuthCredential, type, employeeModel);
  }

  Future<void> processEmployeeSignUp(BuildContext context) async {
    String? identifier;
    AndroidDeviceInfo? androidInfo;

    if (Platform.isIOS) {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      var data = await deviceInfoPlugin.iosInfo;
      identifier = "${data.name}-v${data.systemName}";
    } else if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      androidInfo = await deviceInfo.androidInfo;
    }

    print("============ $identifier, ${androidInfo?.id}");
    employeeModel?.deviceID = Platform.isIOS ? identifier : androidInfo?.id;
    employeeModel?.phoneModel = Platform.isIOS ? "iOS" : "Android";

    employeeModel?.userUID = auth.currentUser?.uid;
    employeeModel?.isActivated = true;
    if (employeeModel?.profileURL == null) {
      employeeModel?.profileURL =
          "https://firebasestorage.googleapis.com/v0/b/wingspan-449f4.appspot.com/o/dafault_profile%2Fprofile.png?alt=media&token=d4cba450-fcff-467c-9ec7-9aca8e48a7bc";
    }

    //link account in auth firebase with collection user; because col user use different;
    await usersService
        .createUserAccount(
            employeeModel!.toJson(), employeeModel?.staffId ?? '')
        .then((res) async => {
              if (res.status == 'S')
                {
                  await allDevicesService.incrementDeviceValueByOrganizationID(
                      employeeModel!.organization_id!),
                  await prefs.setString('userId', employeeModel?.staffId ?? ''),
                  await prefs.setString(
                      'organizationId', employeeModel?.organization_id ?? ''),
                  await prefs.setString(
                      'username', employeeModel?.username ?? ''),
                  await prefs.setBool('tracking', true),
                  await prefs.setBool('bioScan', false),
                  Provider.of<AppService>(context, listen: false).bioAuth =
                      true,
                  Provider.of<AppService>(context, listen: false).loginState =
                      true,
                  context.pushReplacementNamed(RouteNames.todayTask),
                  LoadingOverlay.of(context).hide(),
                }
              else
                {
                  showToastMessage(context, translate("message.went_wrong"),
                      Theme.of(context).colorScheme.onBackground),
                  LoadingOverlay.of(context).hide()
                },
            });
  }

  Future<void> processEmployeeLogin(BuildContext context) async {
    await prefs.setString('userId', employeeModel?.staffId ?? '');
    await prefs.setString(
        'organizationId', employeeModel?.organization_id ?? '');
    await prefs.setString('username', employeeModel?.username ?? '');
    await prefs.setBool('tracking', true);
    await prefs.setBool('bioScan', false);
    Provider.of<AppService>(context, listen: false).bioAuth = true;
    Provider.of<AppService>(context, listen: false).loginState = true;

    context.pushReplacementNamed(RouteNames.todayTask);
    LoadingOverlay.of(context).hide();
  }

  void signInWithPhoneAuthCredential(
      BuildContext context,
      PhoneAuthCredential phoneAuthCredential,
      String? type,
      EmployeeModel? employeeModel) async {
    try {
      LoadingOverlay.of(context).show();

      print("----------${employeeModel?.organization_id}");

      final authCredential =
          await auth.signInWithCredential(phoneAuthCredential);

      if (authCredential.user != null) {
        if (type == "Reset") {
          //reset password;
        } else {
          //successfule create account;
          if (type == "login") {
            await processEmployeeLogin(context);
          } else {
            await processEmployeeSignUp(context);
          }

          await _authService.getUserToken(employeeModel?.staffId);
        }

        // ignore: use_build_context_synchronously
        showToastMessage(context, translate("message.successful"),
            Theme.of(context).colorScheme.primary);
      } else {}
    } on FirebaseAuthException catch (e) {
      // showToastMessage(context, translate("authentication.incorrect_otp"),
      //     ToastGravity.BOTTOM);

      showToastMessage(context, e.message?.split("/")[0] ?? '',
          Theme.of(context).colorScheme.onBackground);
      LoadingOverlay.of(context).hide();
    }
  }

  Future<void> verifyOTPFunc(BuildContext context) async {
    if (otpController.text != "" && !isThaiBulkSms) {
      await verifyOTP(
          context, type, verID, otpController.text, employeeModel, counter);
    } else if (otpController.text != "" && isThaiBulkSms) {
      print("-------atfer thaibulksms request");
      LoadingOverlay.of(context).show();
      ThaiBulkSMSModel thaiBulkSMSModel = ThaiBulkSMSModel();
      thaiBulkSMSModel.token = token;
      thaiBulkSMSModel.pin = otpController.text;
      await thaiBulkOTPService
          .verifyThaiBulkSmsOTP(thaiBulkSMSModel.toJson())
          .then((res) async => {
                print("--------${res.data}"),
                if (res.status == 'S')
                  {
                    await auth.signInAnonymously(),
                    if (type == "login")
                      {processEmployeeLogin(context)}
                    else
                      {processEmployeeSignUp(context)},
                    await _authService.getUserToken(employeeModel?.staffId),
                  }
                else
                  {
                    showToastMessage(context, res.data.toString(),
                        Theme.of(context).colorScheme.onBackground),
                  }
              })
          .whenComplete(() => LoadingOverlay.of(context).hide());
    } else {
      showToastMessage(context, translate("message.went_wrong"),
          Theme.of(context).colorScheme.onBackground);
    }
  }
}
