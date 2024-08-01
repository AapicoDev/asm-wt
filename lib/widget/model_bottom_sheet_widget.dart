import 'package:flutter/material.dart';

class ModelBottomSheetWidget extends StatefulWidget {
  final bool toggleIcon;
  final ValueChanged<bool> valueChanged;
  ModelBottomSheetWidget(
      {Key? key, required this.toggleIcon, required this.valueChanged});

  @override
  _ModelBottomSheetWidgetState createState() => _ModelBottomSheetWidgetState();
}

class _ModelBottomSheetWidgetState extends State<ModelBottomSheetWidget> {
  late bool _toggleIcon;
  @override
  void initState() {
    _toggleIcon = widget.toggleIcon;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // DataProvider dataProvider = Provider.of<DataProvider>(context);
    return Container(
      color: Colors.blue,
      child: Column(
        children: [
          IconButton(
              onPressed: () {
                setState(() {
                  _toggleIcon = !_toggleIcon;
                });
                widget.valueChanged(_toggleIcon);
              },
              icon: Icon(_toggleIcon
                  ? Icons.check_box
                  : Icons.check_box_outline_blank))
        ],
      ),
    );
  }
}

class DataProvider extends ChangeNotifier {
  bool toggleIcon = true;

  toggleIconState() {
    toggleIcon = !toggleIcon;
    notifyListeners();
  }
}
