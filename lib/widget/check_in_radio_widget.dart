import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CheckInRadioType {
  static const String radioType = 'radio';
  static const String textType = 'text';
  static const String imgType = 'image';
}

// ignore: must_be_immutable
class CheckInRadioWidget extends StatelessWidget {
  String? title;
  int? selected;
  String? type;
  Object? groupValue;
  List<XFile>? image;
  String? text;
  VoidCallback? onImagePress;
  TextEditingController? distanceData;
  ValueChanged? onAbnormalPress;
  ValueChanged? onNormalPress;
  Function(String?)? onChanged;
  bool? changeField;

  CheckInRadioWidget(
      {super.key,
      this.type,
      this.title,
      this.selected,
      this.groupValue,
      this.image,
      this.text,
      this.onAbnormalPress,
      this.onNormalPress,
      this.onImagePress,
      this.changeField,
      this.onChanged,
      this.distanceData});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: 40,
      child: Container(
        color: theme.colorScheme.tertiary,
        padding: EdgeInsets.only(left: 10),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: groupValue != null || image != null || text != null
                      ? Text(
                          title!,
                          style: theme.textTheme.bodyMedium,
                        )
                      : Text.rich(TextSpan(
                          style: theme.textTheme.bodyMedium,
                          children: [
                              TextSpan(
                                text: title,
                              ),
                              TextSpan(
                                  text: '*',
                                  style: theme.textTheme.headlineMedium?.merge(
                                      TextStyle(
                                          color:
                                              theme.colorScheme.onBackground)))
                            ]))),
              Expanded(
                flex: 1,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (type == CheckInRadioType.radioType)
                        Row(
                          children: [
                            Radio(
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => theme.colorScheme.onBackground),
                              value: 1,
                              groupValue: groupValue,
                              onChanged: onAbnormalPress,
                            ),
                            Radio(
                              fillColor: MaterialStateColor.resolveWith(
                                  (states) => theme.colorScheme.secondary),
                              value: 0,
                              groupValue: groupValue,
                              onChanged: onNormalPress,
                            )
                          ],
                        )
                      else if (type == CheckInRadioType.textType)
                        SizedBox(
                            width: width / 3.6,
                            child: TextField(
                              controller: distanceData,
                              onChanged: onChanged,
                              keyboardType: TextInputType.number,
                              // inputFormatters: <TextInputFormatter>[
                              //   FilteringTextInputFormatter.digitsOnly
                              // ],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'km',
                              ),
                            ))
                      else
                        image != null
                            ? IconButton(
                                icon: Icon(
                                  Icons.photo_camera,
                                  color: theme.colorScheme.secondary,
                                ),
                                onPressed: onImagePress,
                              )
                            : IconButton(
                                icon: const Icon(Icons.add_a_photo),
                                onPressed: onImagePress,
                              )
                    ]),
              ),
            ]),
      ),
    );
  }
}
