import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExitConfirmationHandler {
  static DateTime? lastPressed;

  static Future<bool> onWillPop(BuildContext context) async {
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
            title: const Text('Exit App'),
            content: const Text('Do you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ),
      );

      if (shouldExit ?? false) {
        // Add a small delay before exiting
        await Future.delayed(const Duration(milliseconds: 100));
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return true;
      }
    }
    return false;
  }
}
