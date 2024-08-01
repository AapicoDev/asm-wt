import 'package:asm_wt/test/sample_controller.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class SampleView extends StatefulWidget {
  final String id;

  const SampleView({Key? key, required this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SampleViewState();
}

class _SampleViewState extends StateMVC<SampleView> {
  late SampleController con;

  _SampleViewState() : super(SampleController()) {
    con = controller as SampleController;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBarWidget(
        isDiscard: false,
        type: StaticModelType.manu,

        title: translate('app_bar.vehicle_break_down'),
        leadingBack: true,
        backIcon: Icons.arrow_back,
        icon: Icons.help,
        // iconTitle: translate('button.help'),
        iconTitle: '',
        onRightPressed: () => showActionGenFunc(
            context, translate('text_header.help'), translate('contents.help')),
      ),
      body: Container(
        color: theme.colorScheme.tertiary,
        width: width,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction,
                size: 30,
              ),
              Text(translate('message.under_dev')),
            ]),
      ),
    );
  }
}
