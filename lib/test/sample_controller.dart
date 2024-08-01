import 'package:asm_wt/widget/alert_dialog_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class SampleController extends ControllerMVC {
  late final AppStateMVC appState;
  User? user;

  factory SampleController([StateMVC? state]) =>
      _this ??= SampleController._(state);
  SampleController._(StateMVC? state) : super(state);
  static SampleController? _this;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
