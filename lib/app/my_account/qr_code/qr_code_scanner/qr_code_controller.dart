import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:asm_wt/core/firebase/auth_service.dart';
import 'package:asm_wt/core/firebase/implement/firebase_auth_service.dart';
import 'package:asm_wt/service/task_service.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class StaticQrCodeType {
  static const String vehicle = 'vehicle';
  static const String task = 'task';
}

class QrCodeController extends ControllerMVC {
  late AppStateMVC appState;
  final AuthService _authService = FirebaseAuthService();
  User? user;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String? qrCodeId;
  bool isQrCodeCorrect = false;
  int currentview = 0;
  QRViewController? controller;
  TasksService tasksService;
  String? driverId;

  factory QrCodeController([StateMVC? state]) =>
      _this ??= QrCodeController._(state);
  QrCodeController._(StateMVC? state)
      : tasksService = TasksService(),
        super(state);
  static QrCodeController? _this;

  @override
  void initState() {
    currentview = 0;
    isQrCodeCorrect = false;
    getDriverId();
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      if (await Permission.camera.isDenied) {
        print("----------Camera permission is denny");
      }
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  Future<void> getDriverId() async {
    var userId = await _authService.getCurrentUserId();
    setState(() {
      driverId = userId;
    });
  }

  void setDefaultIsQrCodeCorrect() {
    setState(() {
      isQrCodeCorrect = false;
      currentview = 0;
    });
  }

  Future<void> isExistTaskByVehicleId(BuildContext context) async {}

  Future<void> onCheckInPressed(
      BuildContext context, Function setState) async {}

  void onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('no Permission')),
      // );
    }
  }
}
