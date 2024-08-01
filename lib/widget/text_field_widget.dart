import 'package:asm_wt/assets/static_data.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class TextFieldWidget extends StatelessWidget {
  TextFieldWidget(
      {super.key,
      required this.title,
      this.controller,
      this.validator,
      this.keyboardType,
      this.prefixIcon,
      this.textInputAction,
      this.suffixIcon,
      this.isEnableEdit,
      required this.hint,
      this.onChanged,
      required this.boolSuffixIcon,
      required this.autovalidateMode});

  TextEditingController? controller;
  final String title;
  final String hint;
  String? Function(String?)? validator;
  Widget? prefixIcon, suffixIcon;
  bool boolSuffixIcon;
  bool? isEnableEdit = false;
  Function(String?)? onChanged;
  TextInputType? keyboardType;
  TextInputAction? textInputAction;
  AutovalidateMode autovalidateMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double border_radius = StaticDataConfig.border_radius;

    return Container(
      margin: const EdgeInsets.only(top: 5.0, bottom: 2.0),
      color: Colors.transparent,
      child: TextFormField(
        enableInteractiveSelection: true,
        readOnly: isEnableEdit ?? false,
        controller: controller,
        onChanged: onChanged,
        obscureText: boolSuffixIcon,
        validator: validator,
        textInputAction: textInputAction,
        autovalidateMode: autovalidateMode,
        keyboardType: keyboardType,
        style: TextStyle(color: theme.colorScheme.secondary),
        decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(border_radius)),
            labelText: title,
            labelStyle: theme.textTheme.bodyMedium,
            prefixIcon: prefixIcon,
            suffixIcon:
                Padding(padding: const EdgeInsets.all(10), child: suffixIcon),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(border_radius)),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(border_radius)),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: theme.colorScheme.primary, width: 1),
                borderRadius: BorderRadius.circular(border_radius)),
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium
                ?.merge(TextStyle(color: theme.colorScheme.onTertiary))),
      ),
    );
  }
}

// final username = TextEditingController();
// TextFieldWidget(
//               controller: username,
//               boolSuffixIcon: false, (optional)
//               title: translate('authenication.username'),
//               keyboardType: TextInputType.number,
//               prefixIcon: const Icon(Icons.person),
//             ),