import 'package:asm_wt/app/authentication/register_step2/register_step2_controller.dart';
import 'package:asm_wt/widget/loading_overlay_widget.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:asm_wt/app/app_key.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/models/employee_model.dart';
import 'package:asm_wt/service/base_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/alert_dialog_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class RegisterStep1Controller extends ControllerMVC {
  late final AppStateMVC appState;
  User? user;
  TextEditingController username;
  TextEditingController email;
  TextEditingController phone;
  TextEditingController staffId;
  bool boolSuffixIcon = true;
  String? errorMessage = '';
  final FirestoreService _firestoreService = FirestoreServiceImpl();
  RegisterStep2Controller _registerStep2Controller = RegisterStep2Controller();
  EmployeeModel? employeeModel;
  bool isStaffDataChecked = false;
  bool isPhoneNumberValid = false;
  String? employeeUID;
  String? organizationID;

  factory RegisterStep1Controller([StateMVC? state]) =>
      _this ??= RegisterStep1Controller._(state);
  RegisterStep1Controller._(StateMVC? state)
      : username = TextEditingController(),
        email = TextEditingController(),
        staffId = TextEditingController(),
        phone = TextEditingController(),
        super(state);
  static RegisterStep1Controller? _this;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    username.dispose();
    email.dispose();
    staffId.dispose();
    phone.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    username = TextEditingController();
    email = TextEditingController();
    staffId = TextEditingController();
    phone = TextEditingController();
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

  Future<void> onStaffIdChanged(BuildContext context) async {
    phone.text = "";
    email.text = "";
    username.text = "";
    isStaffDataChecked = false;

    await _firestoreService
        .getDocumentByOneIdInside(
            TableName.dbEmployeeTable, "employee_id", staffId.text)
        .then((snapshot) => {
              if (snapshot != null)
                {
                  employeeModel = EmployeeModel.fromDocumentSnapshot(snapshot),
                  if (employeeModel?.isActivated ?? false)
                    {
                      showToastMessage(
                          context,
                          translate("message.is_already_activated"),
                          Theme.of(context).colorScheme.onBackground)
                    }
                  else
                    {
                      email.text = employeeModel!.email == null
                          ? ''
                          : employeeModel!.email.toString(),
                      username.text = employeeModel?.username ?? '',
                      isStaffDataChecked = true,
                    }
                }
              else
                {
                  print('Document does not exist'),
                }
            });
  }

  Future<void> onNextBtnPressed(BuildContext context) async {
    if (AppKeys.registerScreen.currentState!.validate()) {
      if (isStaffDataChecked) {
        RegExp ifStartWithZero = RegExp(r'^(\+66$)|(^\+66([^0]\d*))');
        RegExpMatch? phonenumber = ifStartWithZero.firstMatch(phone.text);
        if (phonenumber?[0] != null) {
          if (isPhoneNumberValid && phone.text.isNotEmpty) {
            LoadingOverlay.of(context).show();

            setState(() {
              employeeModel?.email = email.text;
              employeeModel?.username = username.text;
              employeeModel?.phoneNumber = phone.text;
            });

            // ignore: use_build_context_synchronously
            await _registerStep2Controller.verifyPhone(
                context, employeeModel, 'register', false);
          } else {
            showToastMessage(
                context,
                translate('permission.enter_phone_number'),
                Theme.of(context).colorScheme.onBackground);
          }
        } else {
          showToastMessage(
              context,
              translate('permission.phone_start_with_zero'),
              Theme.of(context).colorScheme.onBackground);
        }
      } else {
        showActionGenFunc(
            context,
            translate("authentication.staff_id_not_found"),
            translate("authentication.staff_id_message"));
      }
    }
  }
}
