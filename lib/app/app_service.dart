// ignore: non_constant_identifier_names
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String loginKey = "5FD6G46SDF4GD64F1VG9SD68-99999";
String bioAuthKey = "bioAuthKey-123456789";
// ignore: non_constant_identifier_names
String ONBOARD_KEY = "b2e5f876d46bdf6d2e61205ec94c57b2-999999";

class AppService with ChangeNotifier {
  late final SharedPreferences sharedPreferences;
  final StreamController<bool> _loginStateChange =
      StreamController<bool>.broadcast();
  final StreamController<bool> _bioAuthStateChange =
      StreamController<bool>.broadcast();
  bool _loginState = false;
  bool _bioAuthState = false;
  bool _initialized = false;
  bool _onboarding = false;
  int _navNum = 0;

  User? user;

  AppService(this.sharedPreferences);

  bool get loginState => _loginState;
  bool get bioAuth => _bioAuthState;
  int get navNum => _navNum;

  bool get initialized => _initialized;
  bool get onboarding => _onboarding;
  Stream<bool> get loginStateChange => _loginStateChange.stream;
  Stream<bool> get bioAuthStateChange => _bioAuthStateChange.stream;

  set loginState(bool state) {
    sharedPreferences.setBool(loginKey, state);
    _loginState = state;
    _loginStateChange.add(state);
    notifyListeners();
  }

  set navNum(int value) {
    if (_navNum != value) {
      _navNum = value;
      notifyListeners();
    }
  }

  set bioAuth(bool state) {
    sharedPreferences.setBool(bioAuthKey, state);
    _bioAuthState = state;
    _bioAuthStateChange.add(state);
    notifyListeners();
  }

  set initialized(bool value) {
    _initialized = value;
    notifyListeners();
  }

  set onboarding(bool value) {
    sharedPreferences.setBool(ONBOARD_KEY, value);
    _onboarding = value;
    notifyListeners();
  }

  Future<void> onAppStart() async {
    _onboarding = sharedPreferences.getBool(ONBOARD_KEY) ?? false;
    _loginState = sharedPreferences.getBool(loginKey) ?? false;

    // This is just to demonstrate the splash screen is working.
    // In real-life applications, it is not recommended to interrupt the user experience by doing such things.
    await Future.delayed(const Duration(seconds: 2));

    _initialized = true;
    notifyListeners();
  }
}
