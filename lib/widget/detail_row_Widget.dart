import 'package:flutter/material.dart';
import 'package:asm_wt/assets/static_data.dart';

// ignore: must_be_immutable
class DetailRowWidget extends StatelessWidget {
  String? title;
  String? subTitle;
  String? sub2Title;
  IconData? icon;
  bool underline = false;
  double? height;
  int flex = 3;
  bool? isBladge = false;
  bool? isHasProblem;

  DetailRowWidget(
      {super.key,
      this.title,
      this.subTitle,
      this.isBladge,
      this.sub2Title,
      this.isHasProblem,
      required this.flex,
      this.height,
      this.icon,
      required this.underline});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: height,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: const Text('.'),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                title ?? "",
                style: theme.textTheme.headlineSmall,
              ),
            ),
            Expanded(
              flex: flex,
              child: Row(children: [
                Icon(
                  icon,
                  color: theme.colorScheme.onBackground,
                ),
                Expanded(
                  flex: 1,
                  child: isBladge ?? false
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: width / 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    StaticDataConfig.border_radius),
                                color: theme.colorScheme.onTertiary,
                              ),
                              child: Center(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  child: Text(
                                    subTitle ?? '',
                                    style: theme.textTheme.headlineSmall
                                        ?.merge(TextStyle(color: Colors.white)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          child: RichText(
                            softWrap: true,
                            text: TextSpan(
                                style: theme.textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                      text: subTitle,
                                      style: underline
                                          ? theme.textTheme.bodyMedium?.merge(
                                              const TextStyle(
                                                  decorationStyle:
                                                      TextDecorationStyle.wavy,
                                                  decoration:
                                                      TextDecoration.underline))
                                          : theme.textTheme.bodyMedium),
                                  TextSpan(
                                      text: sub2Title,
                                      style: theme.textTheme.headlineSmall
                                          ?.merge(TextStyle(
                                              color: isHasProblem ?? false
                                                  ? theme
                                                      .colorScheme.onBackground
                                                  : theme
                                                      .colorScheme.background)))
                                ]),
                          ),
                        ),
                )
              ]),
            ),
          ]),
    );
  }
}
