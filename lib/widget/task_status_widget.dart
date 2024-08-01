import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

class DrawDottedhorizontalline extends CustomPainter {
  Paint _paint = Paint();

  DrawDottedhorizontalline() {
    _paint = Paint();
    _paint.color = Colors.black; //dots color
    _paint.strokeWidth = 1; //dots thickness
    _paint.strokeCap = StrokeCap.round; //dots corner edges
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (double i = -45; i < 45; i = i + 5) {
      // 5 is space between dots
      if (i % 3 == 0)
        canvas.drawLine(Offset(i, 0.0), Offset(i + 10, 0.0), _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// ignore: must_be_immutable
class TaskStatusWidget extends StatelessWidget {
  final bool enable;
  final String title;
  final VoidCallback? onStartPressed;
  final VoidCallback? onFinishPressed;
  final bool isStarted = true;

  TaskStatusWidget({
    super.key,
    required this.enable,
    required this.title,
    this.onStartPressed,
    this.onFinishPressed,
  });

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    // double customeWidth = width / 3;

    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            IconButton(
              color: isStarted
                  ? theme.colorScheme.background
                  : theme.colorScheme.secondary,
              iconSize: 45,
              isSelected: true,
              icon: const Icon(
                Icons.play_circle,
              ),
              tooltip: 'To start delivery product to customer.',
              onPressed: () {},
            ),
            Text(
              translate("text_header.start_process"),
              style: theme.textTheme.headlineSmall?.merge(TextStyle(
                  color: isStarted
                      ? theme.colorScheme.background
                      : theme.colorScheme.onTertiary)),
            ),
          ],
        ),
        CustomPaint(painter: DrawDottedhorizontalline()),
        Column(
          children: [
            IconButton(
              color: isStarted
                  ? theme.colorScheme.background
                  : theme.colorScheme.secondary,
              iconSize: 45,
              isSelected: true,
              icon: const Icon(
                Icons.autorenew,
              ),
              tooltip: 'Task is on delivering',
              onPressed: () {},
            ),
            Text(
              translate("text_header.progressing_process"),
              style: theme.textTheme.headlineSmall?.merge(TextStyle(
                  color: isStarted
                      ? theme.colorScheme.background
                      : theme.colorScheme.onTertiary)),
            ),
          ],
        ),
        CustomPaint(painter: DrawDottedhorizontalline()),
        Column(
          children: [
            IconButton(
              color: theme.colorScheme.onTertiary,
              iconSize: 45,
              isSelected: true,
              icon: const Icon(
                Icons.check_circle,
              ),
              tooltip: 'To complete a task.',
              onPressed: onFinishPressed,
            ),
            Text(
              translate("text_header.finish_process"),
              style: theme.textTheme.headlineSmall
                  ?.merge(TextStyle(color: theme.colorScheme.onTertiary)),
            ),
          ],
        ),
      ],
    );
  }
}
