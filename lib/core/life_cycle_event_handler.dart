import 'package:flutter/material.dart';

class LifecycleEventHandler extends WidgetsBindingObserver {
  final VoidCallback? resumeCallBack;
  final VoidCallback? suspendingCallBack;

  LifecycleEventHandler({
    this.resumeCallBack,
    this.suspendingCallBack,
  });

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) {
          resumeCallBack!();
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (suspendingCallBack != null) {
          suspendingCallBack!();
        }
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }
}
