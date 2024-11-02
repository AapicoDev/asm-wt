import 'package:flutter/material.dart';

class FullscreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullscreenImageViewer({required this.imageUrl});

  // Static method to show the dialog with the FullscreenImageViewer widget
  static void show(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => FullscreenImageViewer(imageUrl: imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  width: 300,
                  height: 300,
                  child: const Center(child: Text('Image not available')),
                );
              },
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
