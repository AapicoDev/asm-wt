import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

// ignore: must_be_immutable
class AlertDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  String? type;
  AlertDialogWidget(
      {super.key, required this.title, required this.content, this.type});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AlertDialog(
      title: Container(
        alignment: Alignment.center,
        child: Text(title),
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(theme.colorScheme.primary)),
          child: Text(
            translate('button.ok'),
            style: theme.textTheme.headlineSmall
                ?.merge(TextStyle(color: theme.colorScheme.onPrimary)),
          ),
        )
      ],
    );
  }
}
