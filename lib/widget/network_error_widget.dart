import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:asm_wt/widget/button_widget.dart';

// ignore: must_be_immutable
class NetworkErrorDialog extends StatelessWidget {
  final VoidCallback? onPressed;

  NetworkErrorDialog({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
              width: 170,
              child: Image.asset('lib/assets/images/connection_lost.png')),
          const SizedBox(height: 32),
          Text(
            translate('internet_connection.header'),
            style: theme.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            translate('internet_connection.sub_header'),
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            translate('internet_connection.content'),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ButtonWidget(
              // textColor: Colors.white,
              color: Theme.of(context).colorScheme.secondary,
              enable: true,
              fullStyle: true,
              title: translate('button.ok'),
              onPressed: onPressed)
        ],
      ),
    );
  }
}
