import 'package:asm_wt/app/app_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class AppController extends ControllerMVC {
  factory AppController() => _this ??= AppController._();
  AppController._();
  static AppController? _this;
  late final AppService appService;

  /// Initialize any 'time-consuming' operations at the beginning.
  /// Initialize asynchronous items essential to the Mobile Applications.
  /// Typically called within a FutureBuilder() widget.
  @override
  Future<bool> initAsync() async {
    // Simply wait for 10 seconds at startup.
    /// In production, this is where databases are opened, logins attempted, etc.
    return Future.delayed(const Duration(seconds: 1), () {
      FlutterNativeSplash.remove();
      // FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
      //   if (user == null) {
      //     debugPrint('User is currently signed out!');
      //   } else {
      //     // debugPrint(user.toString());
      //     // var token = FirebaseMessaging.instance.getToken();
      //     String? token = await FirebaseMessaging.instance.getToken();
      //   }
      // });
      return true;
    });
  }

  /// Supply an 'error handler' routine if something goes wrong
  /// in the corresponding initAsync() routine.
  /// Returns true if the error was properly handled.
  @override
  bool onAsyncError(FlutterErrorDetails details) {
    return false;
  }
}
