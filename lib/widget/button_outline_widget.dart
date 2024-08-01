import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ButtonOutlineWidget extends StatelessWidget {
  String title;
  String? imagePath;
  IconData? icon;
  final VoidCallback? onPressed;
  ButtonOutlineWidget(
      {super.key,
      required this.title,
      this.imagePath,
      this.icon,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    final theme = Theme.of(context);

    return Container(
      width: width,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(icon, color: theme.colorScheme.secondary)
            : Image.asset(
                imagePath!,
                height: 25,
              ),
        label: Text(title, style: theme.textTheme.headlineSmall),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          foregroundColor: theme.colorScheme.secondary,
          // backgroundColor: theme.colorScheme.tertiary,
          side: BorderSide(
            color: theme.colorScheme.secondary,
            width: 1,
          ),
        ),
      ),
    );
  }
}
