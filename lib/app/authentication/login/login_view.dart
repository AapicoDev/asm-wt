import 'package:asm_wt/router/router_name.dart';
import 'package:asm_wt/util/get_unique_id.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:asm_wt/app/app_key.dart';
import 'package:asm_wt/app/authentication/login/login_controller.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/app_bar_widget.dart';
import 'package:asm_wt/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends StateMVC<LoginView> {
  late LoginController con;
  String? deviceId;

  _LoginViewState() : super(LoginController()) {
    con = controller as LoginController;
  }

  bool? isCheckbox = true;
  late LocalizationDelegate localizationDelegate;
  int? groupValue = 0;

  Widget buildSegment(String text) {
    return Container(
      child: Text(
        text,
        style: const TextStyle(fontSize: 22, color: Colors.black),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchDeviceId();
  }

  // This function calls the getDeviceId function and updates the state
  Future<void> fetchDeviceId() async {
    String? id = await getDeviceId(); // Get the device ID
    setState(() {
      deviceId = id; // Store the result and refresh the UI
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    localizationDelegate = LocalizedApp.of(context).delegate;
    double border_radius = StaticDataConfig.border_radius;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBarWidget(
          color: theme.colorScheme.primary,
          isDiscard: false,
          type: StaticModelType.translate,
          title: translate('app_bar.demo_title'),
          leadingBack: false,
          iconTitle: localizationDelegate.currentLocale.languageCode == 'en'
              ? 'Eng'
              : 'ไทย',
          icon: Icons.language,
          onRightPressed: () => modelBottomSheetFunc(
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
              null),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // Dismiss the keyboard
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'lib/assets/images/asm-logo.png',
                  height: height * 0.30,
                ),
                const Divider(),

                // Container(
                //   alignment: Alignment.center,
                //   padding: EdgeInsets.all(10),
                //   child: CupertinoSlidingSegmentedControl<int>(
                //     backgroundColor: CupertinoColors.white,
                //     thumbColor: CupertinoColors.activeGreen,
                //     padding: EdgeInsets.all(8),
                //     groupValue: groupValue,
                //     children: {
                //       0: buildSegment("Flutter"),
                //       1: buildSegment("React"),
                //       2: buildSegment("Native"),
                //     },
                //     onValueChanged: (value) {
                //       setState(() {
                //         groupValue = value;
                //       });
                //     },
                //   ),
                // ),
                Container(
                  padding: const EdgeInsets.all(StaticDataConfig.app_padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          textAlign: TextAlign.center,
                          translate('authentication.login_title') +
                              "\n[POS Version]\n",
                          style: theme.textTheme.titleLarge?.merge(TextStyle(
                              fontSize: 25,
                              color: theme.colorScheme.secondary))),
                      const SizedBox(
                        height: 5,
                      ),
                      Form(
                          key: AppKeys.loginScreen,
                          child: IntlPhoneField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            invalidNumberMessage:
                                translate("message.invalid_phone_number"),
                            onChanged: (phone) {
                              setState(() {
                                con.phoneNumber.text = phone.completeNumber;
                              });
                            },
                            validator: (p0) {
                              if (p0?.countryISOCode == "TH" &&
                                  p0?.number.length == 9) {
                                con.isPhoneNumberValid = true;
                              }
                              return translate("authentication.required");
                            },
                            dropdownTextStyle: theme.textTheme.bodyMedium,
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 0),
                                disabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(border_radius)),
                                labelText:
                                    translate('authentication.phone_number'),
                                labelStyle: theme.textTheme.bodyMedium,
                                // prefixIcon: prefixIcon,
                                // suffixIcon: Padding(
                                //     padding: const EdgeInsets.all(10),
                                //     child: suffixIcon),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(border_radius)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300, width: 1),
                                    borderRadius:
                                        BorderRadius.circular(border_radius)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: theme.colorScheme.primary,
                                        width: 1),
                                    borderRadius:
                                        BorderRadius.circular(border_radius)),
                                hintText: "65 789 8908",
                                hintStyle: theme.textTheme.bodyMedium?.merge(
                                    TextStyle(
                                        color: theme.colorScheme.onTertiary))),
                            initialCountryCode: 'TH',
                          )),
                      Row(
                        children: <Widget>[
                          SizedBox(width: width / 2),
                          Checkbox(
                              activeColor: theme.colorScheme.secondary,
                              value: isCheckbox,
                              onChanged: (bool? newBool) {
                                setState(() {
                                  isCheckbox = newBool;
                                });
                              }),
                          Text(
                            translate('authentication.remember_me'),
                            style: theme.textTheme.bodySmall,
                          )
                        ],
                      ),
                      SizedBox(
                        height: height * 0.15,
                      ),
                      Column(
                        children: [
                          ButtonWidget(
                              enable: true,
                              fullStyle: true,
                              title: translate('button.sign_in'),
                              onPressed: () => con.onSignInPressed(context)
                              // onPressed: () => context.pushNamed(RouteNames.myTasks)
                              ),
                          Text("${deviceId}"),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  translate("authentication.dont_have_account"),
                                  style: theme.textTheme.bodyMedium),
                              GestureDetector(
                                onTap: () {
                                  context.pushNamed(RouteNames.register);
                                },
                                child: Text(
                                  translate("authentication.register"),
                                  style: theme.textTheme.headlineSmall?.merge(
                                      TextStyle(
                                          color: theme.colorScheme.onSurface)),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            // )
          ),
        ),
      ),
    );
  }
}
