import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asm_wt/app/app_service.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/core/firebase/auth_service.dart';
import 'package:asm_wt/core/firebase/implement/firebase_auth_service.dart';
import 'package:asm_wt/models/user_model.dart';
import 'package:asm_wt/router/router_name.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/service/user_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/loading_overlay_widget.dart';
import 'package:asm_wt/widget/network_error_widget.dart';
import 'package:asm_wt/widget/text_field_widget.dart';
import 'package:provider/provider.dart';

class MyAccountController extends ControllerMVC {
  late final AppStateMVC appState;

  factory MyAccountController([StateMVC? state]) =>
      _this ??= MyAccountController._(state);
  MyAccountController._(StateMVC? state) : super(state);
  static MyAccountController? _this;
  final AuthService _authService = FirebaseAuthService();
  UsersService usersService = UsersService();

  final ScrollController scrollController =
      ScrollController(initialScrollOffset: 0);
  final SharedPreferences prefs = GetIt.instance<SharedPreferences>();

  TextEditingController accountDelCon = TextEditingController();
  bool correctDelName = false;
  bool locatoinSwitchBtn = true;
  bool loading = false;
  late StreamSubscription subscription;
  List<ConnectivityResult>? connectivityResult;
  UserModel? userModel;
  String? userId;

  @override
  void dispose() {
    subscription.cancel();
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    getConnectivity();
    userId = prefs.getString('userId');

    getUserDataByUserId();
  }

  Future<void> getUserDataByUserId() async {
    await usersService.getUserByUserId(userId).then((res) => {
          if (res != null)
            {
              setState(() {
                userModel = res;
              }),
              notifyListeners()
            }
        });
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
          connectivityResult = result;
        },
      );

  Future<void> onStatusPressed(
      BuildContext context, String? userStatus, String? userId) async {
    Map<String, dynamic> status = <String, dynamic>{};
    var theme = Theme.of(context);
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) => NetworkErrorDialog(
          onPressed: Navigator.of(context).pop,
        ),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(
                      UserStatus.userStatusList.length, (int index) {
                    String translate = "";
                    switch (UserStatus.userStatusList[index]) {
                      case UserStatus.Available:
                        translate = "ว่าง";
                        break;
                      case UserStatus.Offline:
                        translate = "ออฟไลน์";
                        break;
                      case UserStatus.UnAvalibale:
                        translate = "ไม่ว่าง";
                        break;
                      default:
                        translate = "Unknow";
                        break;
                    }
                    return RadioListTile(
                        title: Text(
                          "${UserStatus.userStatusList[index]} ($translate)",
                          style: theme.textTheme.bodyMedium,
                        ),
                        value: UserStatus.userStatusList[index],
                        groupValue: userStatus,
                        onChanged: (val) {
                          setState(() {
                            userStatus = val;
                          });
                          status["user_status"] = val;
                        });
                  }),
                );
              },
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(translate('button.cancel')),
                  ),
                  TextButton(
                    onPressed: () async => {
                      LoadingOverlay.of(context).show(),
                      await usersService
                          .updateUserInfoByUserId(userId, status)
                          .then((res) async => {
                                await getUserDataByUserId(),
                                LoadingOverlay.of(context).hide(),
                                Navigator.pop(context)
                              })
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                            theme.colorScheme.primary)),
                    child: Text(translate('button.confirm'),
                        style: theme.textTheme.headlineSmall?.merge(
                            TextStyle(color: theme.colorScheme.onPrimary))),
                  ),
                ],
              )
            ],
          );
        },
      );
    }
  }

  Future<void> getFromGallery(
      BuildContext context, String userId, String? previousImageName) async {
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
      XFile? userProfileFile = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 15);
      if (userProfileFile != null) {
        // File imageFile = File(pickedFile.path);
        await usersService
            .updateUserProfilPhotoByUserID(
                userId, userProfileFile, previousImageName)
            .then((res) async => {
                  if (res.status == "S")
                    {
                      await getUserDataByUserId(),
                      showToastMessage(context, translate("message.updated"),
                          Theme.of(context).colorScheme.primary)
                    },
                  LoadingOverlay.of(context).hide()
                });
      } else {
        LoadingOverlay.of(context).hide();
      }
    }
  }

  void showActionConfirmDelAccFunc(context, String username) {
    var theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          resizeToAvoidBottomInset: false,
          body: StatefulBuilder(
              builder: (BuildContext context, setState) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            StaticDataConfig.border_radius)),
                    contentTextStyle: theme.textTheme.bodyMedium,
                    titlePadding: const EdgeInsets.all(0),
                    title: Container(
                      color: theme.colorScheme.primary,
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: StaticDataConfig.app_padding,
                            bottom: StaticDataConfig.app_padding),
                        child: Text(translate("text_header.confirm_delete"),
                            style: theme.textTheme.headlineLarge?.merge(
                                TextStyle(
                                    color: theme.colorScheme.onSecondary))),
                      ),
                    ),
                    content: SizedBox(
                      height: 120,
                      child: Column(
                        children: [
                          Text(translate("contents.confirm_delete_content"),
                              style: theme.textTheme.bodyMedium),
                          const SizedBox(
                            height: 5,
                          ),
                          TextFieldWidget(
                            controller: accountDelCon,
                            onChanged: (p0) {
                              if (p0 == username) {
                                setState(() => correctDelName = true);
                              } else {
                                setState(() => correctDelName = false);
                              }
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            title: translate('authentication.username'),
                            hint: username,
                            boolSuffixIcon: false,
                            keyboardType: TextInputType.name,
                            prefixIcon: const Icon(Icons.person),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(translate('button.cancel')),
                          ),
                          // ignore: unrelated_type_equality_checks
                          correctDelName
                              ? TextButton(
                                  onPressed: () => onConfirmDelSuccess(context),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              theme.colorScheme.primary)),
                                  child: Text(
                                    translate('button.confirm'),
                                    style: theme.textTheme.headlineSmall?.merge(
                                        TextStyle(
                                            color:
                                                theme.colorScheme.onPrimary)),
                                  ),
                                )
                              : TextButton(
                                  onPressed: () => {},
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              theme.colorScheme.onTertiary)),
                                  child: Text(
                                    translate('button.confirm'),
                                    style: theme.textTheme.headlineSmall
                                        ?.merge(TextStyle(color: Colors.white)),
                                  ),
                                ),
                        ],
                      )
                    ],
                  )),
        );
      },
    );
  }

  Future<void> onSignOutPressed(BuildContext context) async {
    LoadingOverlay.of(context).show();
    final prefs = await SharedPreferences.getInstance();
    await _authService.signOut().then((value) => {
          Future.delayed(
              const Duration(seconds: StaticDataConfig.static_loading), () {
            LoadingOverlay.of(context).hide();
            Provider.of<AppService>(context, listen: false).loginState = false;
            prefs.setString('userId', "");
            prefs.setBool('tracking', false);
            context.pushReplacementNamed(RouteNames.root);
          }),
        });
  }

  Future<void> onConfirmDelSuccess(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successful Delete Account')),
    );
    onSignOutPressed(context);
  }
}
