import 'package:pinput/pinput.dart';
import 'package:asm_wt/app/authentication/register_step2/register_step2_controller.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/employee_model.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/widget/button_widget.dart';

// ignore: must_be_immutable
class RegisterStep2View extends StatefulWidget {
  String? type;
  String? verID;
  EmployeeModel? employeeModel;
  String? token;
  bool? isThaiBulkSms;
  RegisterStep2View(
      {Key? key,
      this.type,
      this.verID,
      this.token,
      this.isThaiBulkSms,
      this.employeeModel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterStep2ViewState();
}

class _RegisterStep2ViewState extends StateMVC<RegisterStep2View>
    with TickerProviderStateMixin {
  late RegisterStep2Controller con;

  _RegisterStep2ViewState() : super(RegisterStep2Controller()) {
    con = controller as RegisterStep2Controller;
  }

  @override
  void initState() {
    setState(() {
      con.type = widget.type;
      con.verID = widget.verID;
      con.employeeModel = widget.employeeModel;
      con.token = widget.token;
      con.isThaiBulkSms = widget.isThaiBulkSms ?? false;
    });

    // con.verifyOTP(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.secondary),
        borderRadius: BorderRadius.circular(5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: theme.colorScheme.secondary),
      borderRadius: BorderRadius.circular(5),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: theme.colorScheme.onPrimary,
      ),
    );

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBarWidget(
          color: theme.colorScheme.primary,
          isDiscard: false,
          type: StaticModelType.manu,
          title: translate('app_bar.account_register'),
          leadingBack: false,
          icon: Icons.help,
          // iconTitle: translate('button.help'),
          iconTitle: '',
          onRightPressed: () => showActionGenFunc(context,
              translate('text_header.help'), translate('contents.help')),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  padding: const EdgeInsets.only(
                      left: StaticDataConfig.app_padding,
                      right: StaticDataConfig.app_padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'lib/assets/images/phone_verify.jpg',
                        width: height * 0.30,
                        height: height * 0.30,
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                                translate('authentication.phone_verify'),
                                style: theme.textTheme.titleLarge?.merge(
                                    TextStyle(
                                        fontSize: 25,
                                        color: theme.colorScheme.secondary))),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      translate("text_header.sent_verified"),
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    SizedBox(height: height / 400),
                                    Text(
                                      "${translate("text_header.code_on")} ${widget.employeeModel?.phoneNumber ?? ""}",
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            height: height * 0.06,
                            width: width * 0.90,
                            child: Pinput(
                              length: 6,
                              controller: con.otpController,
                              isCursorAnimationEnabled: true,
                              defaultPinTheme: defaultPinTheme,
                              focusedPinTheme: focusedPinTheme,
                              submittedPinTheme: submittedPinTheme,
                              showCursor: true,
                              pinputAutovalidateMode:
                                  PinputAutovalidateMode.onSubmit,
                              onCompleted: (pin) => print(pin),
                              // androidSmsAutofillMethod:
                              //     AndroidSmsAutofillMethod.smsRetrieverApi,

                              onChanged: (val) {
                                // otpval = val;
                                // con.verifyOTP(context);
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text.rich(
                            TextSpan(
                                style: theme.textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                      text:
                                          translate("permission.code_timeout")),
                                  TextSpan(
                                      text: "${con.counter} s",
                                      style: theme.textTheme.headlineMedium),
                                ]),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          con.counter == 0
                              ? SizedBox(
                                  child: Center(
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.tertiary,
                                        textStyle:
                                            theme.textTheme.headlineSmall,
                                      ),
                                      onPressed: () =>
                                          {con.onResendPressed(context)},
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            translate("permission.otp_request"),
                                            style:
                                                theme.textTheme.headlineMedium,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Icon(Icons.recycling)
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink()
                        ],
                      ),
                    ],
                  )),
              SizedBox(
                height: height * 0.22,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: StaticDataConfig.app_padding,
                    right: StaticDataConfig.app_padding),
                child: ButtonWidget(
                    enable: true,
                    fullStyle: true,
                    title: translate('button.submit'),
                    onPressed: () async => {con.verifyOTPFunc(context)}),
              ),
            ],
          ),
          // )
        ),
      ),
    );
  }
}
