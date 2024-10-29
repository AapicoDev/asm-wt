import 'package:flutter/material.dart';

void showTopSnackBar(BuildContext context, String message) {
  // Create the overlay entry
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: MediaQuery.of(context).viewInsets.bottom + 80,
      left: 10,
      right: 10,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    ),
  );

  // Insert the overlay entry into the overlay
  overlay.insert(overlayEntry);

  // Remove the overlay after some delay
  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}
