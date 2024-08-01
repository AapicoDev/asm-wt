import 'package:flutter_translate/flutter_translate.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:flutter/material.dart';
import 'package:asm_wt/widget/detail_row_Widget.dart';

class OnBoardTaskCardWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final int? docLength;
  final VoidCallback? onPressed;
  final String startDate;
  final String countDown;
  final int? destinationNum;
  final int? successNum;

  const OnBoardTaskCardWidget(
      {super.key,
      required this.title,
      required this.startDate,
      required this.countDown,
      this.docLength,
      this.destinationNum,
      this.successNum,
      required this.subTitle,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onPressed,
      child: Card(
          elevation: 10.0,
          color: theme.colorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StaticDataConfig.border_radius),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
          child: SizedBox(
            height: height - 20,
            width: docLength == 1 ? width / 1.1 : width / 1.3,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            color: theme.colorScheme.background,
                            iconSize: 35,
                            isSelected: true,
                            icon: const Icon(
                              Icons.autorenew,
                            ),
                            tooltip: 'Task is on delivering',
                            onPressed: () {},
                          ),
                          Text(
                            'Progress',
                            style: theme.textTheme.bodySmall?.merge(TextStyle(
                                color: theme.colorScheme.background,
                                fontWeight: FontWeight.bold)),
                          ),
                        ],
                      )),
                  Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(.0),
                        child: Center(
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onPrimary,
                                      border: Border.all(
                                          color: theme.colorScheme.onTertiary,
                                          width: 1.0),
                                    ),
                                    child: Column(
                                      children: [
                                        Text("${destinationNum ?? 0}",
                                            style: theme.textTheme.titleLarge),
                                        Text(
                                          "Destination",
                                          style: theme.textTheme.bodySmall,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.background,
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          "$successNum",
                                          style: theme.textTheme.titleLarge
                                              ?.merge(TextStyle(
                                                  color: theme
                                                      .colorScheme.onPrimary)),
                                        ),
                                        Text(
                                          "Success",
                                          style: theme.textTheme.bodySmall
                                              ?.merge(TextStyle(
                                                  color: theme
                                                      .colorScheme.onPrimary,
                                                  fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            DetailRowWidget(
                              flex: 4,
                              underline: false,
                              title: translate('text_header.task_title'),
                              subTitle: title,
                              height: 20,
                            ),
                            DetailRowWidget(
                              flex: 4,
                              underline: false,
                              title: translate('text_header.start_date'),
                              subTitle: startDate,
                              height: 20,
                            ),
                            DetailRowWidget(
                              flex: 4,
                              underline: false,
                              title: translate('text_header.remain'),
                              subTitle: countDown,
                              height: 20,
                            ),
                          ]),
                        ),
                      ))
                ],
              ),
            ),
          )),
    );
  }
}
