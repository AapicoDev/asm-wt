import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';

class ExitConfirmationHandler {
  static DateTime? lastPressed;

  static Future<void> onWillPop(BuildContext context) async {
    final now = DateTime.now();
    if (lastPressed == null ||
        now.difference(lastPressed!) > const Duration(seconds: 2)) {
      lastPressed = now;

      // Use rootNavigator to ensure dialog shows above all routes
      final shouldExit = await showDialog<bool>(
        context: context,
        useRootNavigator: true, // Important!
        barrierDismissible: false, // Prevent dismissing by tapping outside
        builder: (context) => WillPopScope(
          onWillPop: () async => false, // Prevent dismissing by back button
          child: AlertDialog(
            title: Text(translate("exit_app.exit_app")),
            content: Text(translate("exit_app.confirm_content")),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  translate("exit_app.cancel"),
                  style: TextStyle(fontFamily: 'kanit'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  translate("exit_app.confirm"),
                  style: TextStyle(fontFamily: 'kanit'),
                ),
              ),
            ],
          ),
        ),
      );

      if (shouldExit ?? false) {
        // Add a small delay before exiting
        await Future.delayed(const Duration(milliseconds: 100));
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    }
  }
}
