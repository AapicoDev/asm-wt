import 'dart:async';

import 'package:asm_wt/app/app_controller.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asm_wt/core/firebase/auth_service.dart';
import 'package:asm_wt/core/firebase/implement/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class TasksRootController extends ControllerMVC {
  late AppStateMVC appState;
  User? user;
  final AuthService _authService = FirebaseAuthService();
  final SharedPreferences prefs = GetIt.instance<SharedPreferences>();
  AppController appController = AppController();
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;
  List<ConnectivityResult> connectivityResult = [];

  factory TasksRootController() => _this ??= TasksRootController._();
  TasksRootController._() : super();
  static TasksRootController? _this;

  String? userId;
  String? deviceToken;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();

    connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(updateConnectionStatus);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> results;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      results = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status : $e');
      return null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.

    return updateConnectionStatus(results);
  }

  Future<void> updateConnectionStatus(List<ConnectivityResult> result) async {
    connectivityResult = result;
  }

  Future<void> getDriverId() async {
    userId = prefs.getString("userId");
  }

  Future<void> getToken(String? userId) async {
    var deviceToken = await _authService.getUserToken(userId);

    if (deviceToken!.isNotEmpty) {
      deviceToken = deviceToken;
    }
  }
}
