import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/notification_model.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/circle_painter.dart';
import 'package:timeago/timeago.dart' as timeago;

// ignore: must_be_immutable
class NotificationCardWidget extends StatelessWidget {
  late NotificationModel notificationModel;
  final VoidCallback? onPressed;
  late LocalizationDelegate localizationDelegate;
  NotificationCardWidget({
    super.key,
    required this.notificationModel,
    this.onPressed,
  });

  String timeUntil(DateTime date) {
    return timeago.format(date,
        locale: localizationDelegate.currentLocale.languageCode,
        allowFromNow: true);
  }

  String maintenanceStatusTitle() {
    switch (notificationModel.notifyCode) {
      case StatusType.scheduled:
        return "ST";
      case StatusType.rescheduled:
        return "RS";
      case StatusType.absence:
        return "AB";
      case StatusType.dayoff:
        return "OFF";
      case StatusType.ot:
        return "OT";
      default:
        return "None";
    }
  }

  List<String>? spliteDesc() {
    final descSplit = notificationModel.desc?.split(', ');
    return descSplit;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // double width = MediaQuery.of(context).size.width;

    DateTime time = DateTime.fromMillisecondsSinceEpoch(
        notificationModel.createdDate!.millisecondsSinceEpoch);
    localizationDelegate = LocalizedApp.of(context).delegate;

    return Column(children: [
      const SizedBox(
        height: 5,
      ),
      Container(
        decoration: BoxDecoration(color: theme.colorScheme.tertiary),
        child: TextButton(
          onPressed: onPressed,
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    notificationModel.notifyCode == StatusType.rescheduled
                        ? theme.colorScheme.secondary
                        : notificationModel.notifyCode == StatusType.ot
                            ? theme.colorScheme.onSecondary
                            : notificationModel.notifyCode == StatusType.dayoff
                                ? theme.colorScheme.onTertiary
                                : theme.colorScheme.primary,
                maxRadius: 25,
                // foregroundImage: NetworkImage("enterImageUrl"),
                child: Text(
                  maintenanceStatusTitle(),
                  style: theme.textTheme.headlineLarge
                      ?.merge(const TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              StaticDataConfig.border_radius),
                          // color: theme.colorScheme.onPrimary,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${notificationModel.title}",
                              style: theme.textTheme.headlineSmall
                                  ?.merge(TextStyle(color: Colors.black)),
                            ),
                            notificationModel.view ?? false
                                ? Container()
                                : CustomPaint(
                                    size: const Size(15, 15),
                                    painter: CirclePainter(view: false),
                                  ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 4,
                            child: notificationModel.notifyCode ==
                                    StatusType.task
                                ? Text(
                                    notificationModel.desc != null &&
                                            notificationModel.desc != ""
                                        ? notificationModel.desc
                                                    ?.contains(", ") ??
                                                false
                                            ? "- ${spliteDesc()?[0]}\n- ${spliteDesc()?[1]}"
                                            : notificationModel.desc
                                                    ?.capitalize() ??
                                                ''
                                        : translate("text_header.not_found"),
                                    style: theme.textTheme.bodyMedium
                                        ?.merge(TextStyle(color: Colors.black)),
                                  )
                                : Text(
                                    notificationModel.desc != null
                                        ? "${notificationModel.desc?.capitalize()}"
                                        : translate("text_header.not_found"),
                                    style: theme.textTheme.bodyMedium
                                        ?.merge(TextStyle(color: Colors.black)),
                                  ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        StaticDataConfig.border_radius),
                                    color: notificationModel.status ==
                                            StatusType.delete
                                        ? theme.colorScheme.onBackground
                                        : notificationModel.status ==
                                                StatusType.approved
                                            ? theme.colorScheme.background
                                            : theme.colorScheme.secondary,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 3, right: 3),
                                    child: Text(
                                      "${notificationModel.status?.toUpperCase()}",
                                      style: theme.textTheme.headlineSmall
                                          ?.merge(const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12)),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    timeUntil(time).capitalize(),
                                    style: theme.textTheme.headlineSmall?.merge(
                                        TextStyle(
                                            fontSize: 12,
                                            color:
                                                theme.colorScheme.onTertiary)),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    ]);
  }
}
