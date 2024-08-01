import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:asm_wt/app/app_key.dart';
import 'package:asm_wt/app/authentication/register_step1/register_step1_controller.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/widget/button_widget.dart';
import 'package:asm_wt/widget/text_field_widget.dart';

class RegisterStep1View extends StatefulWidget {
  const RegisterStep1View({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RegisterStep1ViewState();
}

class _RegisterStep1ViewState extends StateMVC<RegisterStep1View> {
  late RegisterStep1Controller con;

  _RegisterStep1ViewState() : super(RegisterStep1Controller()) {
    con = controller as RegisterStep1Controller;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double border_radius = StaticDataConfig.border_radius;

    return Scaffold(
      appBar: AppBarWidget(
        color: theme.colorScheme.primary,
        isDiscard: false,
        type: StaticModelType.manu,

        title: translate('app_bar.account_register'),
        leadingBack: true,
        backIcon: Icons.arrow_back,
        icon: null,
        // iconTitle: translate('button.help'),
        iconTitle: '',
        onRightPressed: () => showActionGenFunc(
            context, translate('text_header.help'), translate('contents.help')),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(
      //       left: StaticDataConfig.app_padding,
      //       right: StaticDataConfig.app_padding),
      //   child: ButtonWidget(
      //       enable: true,
      //       fullStyle: true,
      //       title: translate('button.next'),
      //       onPressed: () async => {con.onNextBtnPressed(context)}),
      // ),
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
                    'lib/assets/images/basic_info.jpg',
                    width: height * 0.30,
                    height: height * 0.30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(translate('authentication.account_info'),
                        style: theme.textTheme.titleLarge?.merge(TextStyle(
                            fontSize: 25, color: theme.colorScheme.secondary))),
                  ),
                  Form(
                    key: AppKeys.registerScreen,
                    child: Column(
                      children: [
                        TextFieldWidget(
                          onChanged: (v) async {
                            con.onStaffIdChanged(context);
                          },
                          controller: con.staffId,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          title: translate('authentication.staff_id'),
                          hint: '12345XXX',
                          boolSuffixIcon: false,
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(Icons.verified),
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(),
                            // FormBuilderValidators.email(),
                          ]),
                        ),
                        TextFieldWidget(
                          controller: con.username,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          title: translate('authentication.username'),
                          hint: 'SUN',
                          boolSuffixIcon: false,
                          keyboardType: TextInputType.text,
                          prefixIcon: const Icon(Icons.person),
                        ),
                        TextFieldWidget(
                          controller: con.email,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          title: translate('authentication.email'),
                          hint: 'sun@aapico.com',
                          boolSuffixIcon: false,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email),
                        ),
                        // TextFieldWidget(
                        //   controller: con.phone,
                        //   autovalidateMode: AutovalidateMode.onUserInteraction,
                        //   title: translate('authentication.phone_number'),
                        //   hint: '+66 64787878',
                        //   boolSuffixIcon: false,
                        //   keyboardType: TextInputType.phone,
                        //   prefixIcon: const Icon(Icons.phone),
                        //   validator: FormBuilderValidators.compose([
                        //     FormBuilderValidators.required(),
                        //     // FormBuilderValidators.email(),
                        //   ]),
                        // ),
                        const SizedBox(
                          height: 5,
                        ),
                        IntlPhoneField(
                          // controller: con.phone,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          onChanged: (phone) {
                            setState(() {
                              con.phone.text = phone.completeNumber;
                            });
                          },
                          validator: (p0) {
                            if (p0?.countryISOCode == "TH" &&
                                p0?.number.length == 9) {
                              con.isPhoneNumberValid = true;
                            } else {
                              AppKeys.registerScreen.currentState?.deactivate();
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
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height * 0.10,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: StaticDataConfig.app_padding,
                  right: StaticDataConfig.app_padding),
              child: ButtonWidget(
                  enable: true,
                  fullStyle: true,
                  title: translate('button.next'),
                  onPressed: () async => {con.onNextBtnPressed(context)}),
            )
          ],
        ),
        // )
      ),
    );
  }
}
