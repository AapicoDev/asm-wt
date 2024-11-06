import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class FullscreenImageViewer extends StatelessWidget {
  final String imageUrlOrPath;
  final bool isLocalFile;

  const FullscreenImageViewer({
    required this.imageUrlOrPath,
    this.isLocalFile = false,
  });

  // Static method to show the dialog with the FullscreenImageViewer widget
  static void show(BuildContext context, String imageUrlOrPath,
      {bool isLocalFile = false}) {
    showDialog(
      context: context,
      builder: (context) => FullscreenImageViewer(
        imageUrlOrPath: imageUrlOrPath,
        isLocalFile: isLocalFile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: isLocalFile
                ? Image.file(
                    File(imageUrlOrPath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _errorPlaceholder();
                    },
                  )
                : Image.network(
                    imageUrlOrPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _errorPlaceholder();
                    },
                  ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: Icon(Ionicons.close_circle_outline,
                  color: Colors.white, size: 50),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      color: Colors.grey[300],
      width: 300,
      height: 300,
      child: const Center(child: Text('Image not available')),
    );
  }
}
