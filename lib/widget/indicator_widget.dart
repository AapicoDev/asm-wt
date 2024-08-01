import 'package:flutter/material.dart';

class IndicatorWidget extends StatelessWidget {
  const IndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        height: 70, child: Center(child: CircularProgressIndicator()));
  }
}
