import 'package:flutter/material.dart';

class AppKeys {
  static final GlobalKey<FormState> loginScreen = GlobalKey<FormState>();
  static final GlobalKey<FormState> skipTaskReason = GlobalKey<FormState>();
  static final GlobalKey<FormState> registerScreen = GlobalKey<FormState>();
  static final GlobalKey<FormState> registerScreen2 = GlobalKey<FormState>();
  static final GlobalKey<FormState> requestNoted = GlobalKey<FormState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  // static final GlobalKey<FormState> checkInStep1 = GlobalKey<FormState>();

  static final List<GlobalKey<FormState>> checkInListKey =
      List<GlobalKey<FormState>>.generate(
          12, (index) => GlobalKey(debugLabel: 'key_$index'),
          growable: false);

  static final GlobalKey<FormFieldState> txtPasswordKey =
      GlobalKey<FormFieldState>();

  static final GlobalKey<FormFieldState> txtEmailKey =
      GlobalKey<FormFieldState>();
}
