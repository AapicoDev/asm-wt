import 'package:flutter/material.dart';

class CirclePainter extends CustomPainter {
  late final bool view;
  CirclePainter({required this.view});

  @override
  void paint(Canvas canvas, Size size) {
    final _paint = Paint()
      ..color = view ? Colors.grey : Colors.red
      ..strokeWidth = 2
      // Use [PaintingStyle.fill] if y
      //ou want the circle to be filled.
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width, size.height),
      _paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
