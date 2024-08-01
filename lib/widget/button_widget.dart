import 'package:asm_wt/assets/static_data.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ButtonWidget extends StatelessWidget {
  final bool enable;
  final String title;
  final Color? color;
  final VoidCallback? onPressed;
  bool fullStyle = true;

  ButtonWidget(
      {super.key,
      required this.enable,
      required this.title,
      this.onPressed,
      this.color,
      required this.fullStyle});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double customeWidth = width / 2.3;

    final theme = Theme.of(context);
    return ElevatedButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(EdgeInsets.zero),
        fixedSize: MaterialStateProperty.all(
            Size(fullStyle ? width : customeWidth, 40)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StaticDataConfig.border_radius),
        )),
        backgroundColor: MaterialStateProperty.all(enable
            ? color ?? theme.colorScheme.primary
            : color ?? theme.colorScheme.tertiary),
      ),
      onPressed: onPressed,
      child: Text(title,
          style: theme.textTheme.headlineMedium?.merge(TextStyle(
              color: enable
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onTertiary,
              fontWeight: FontWeight.w700))),
    );
  }
}

// ButtonWidget(
//         enable: true,
//         title: 'Sign In',
//         onPressed: () => {},
//       ),
