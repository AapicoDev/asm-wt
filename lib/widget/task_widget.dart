import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/tasks_model.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskCardWidget extends StatelessWidget {
  final String title;
  final DateTime subTitle;
  final TaskModel taskModel;
  final VoidCallback? onPressed;
  final DateTime now;

  TaskCardWidget(
      {super.key,
      required this.title,
      required this.subTitle,
      required this.taskModel,
      required this.now,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var selectedCard = Colors.white;
    Color cardColor = taskModel.isDisable ?? false
        ? const Color.fromRGBO(85, 105, 187, -1)
        : theme.colorScheme.tertiary;
    Color? clockInColor = theme.colorScheme.onSurface;
    Color? clockOutColor = theme.colorScheme.onSurface;
    bool isChecking = false;

    var startDate = DateTime.fromMicrosecondsSinceEpoch(
        taskModel.start_date!.microsecondsSinceEpoch);

    if (taskModel.status != TaskStatus.Done &&
        taskModel.driverStartAt == null) {
      //allow driver to check In 1 hour before start time(schedule);
      // var canCheckTask = dateTime.difference(now).inHours == 0;
      // var canCheckTask =
      //     dateTime.difference(dateNow).inDays ==
      //         0; => hight line for today task;

      var canCheckTask = startDate.compareTo(now);
      if (canCheckTask == 0 || canCheckTask < 0) {
        clockInColor = theme.colorScheme.onBackground;
      }
    } else {
      if (taskModel.clock_in_status == ClockStatus.Late) {
        clockInColor = theme.colorScheme.onBackground;
      } else if (taskModel.clock_in_status == ClockStatus.Early) {
        clockInColor = theme.colorScheme.background;
      }

      if (taskModel.clock_out_status == ClockStatus.Late) {
        clockOutColor = theme.colorScheme.background;
      } else if (taskModel.clock_out_status == ClockStatus.Early) {
        clockOutColor = theme.colorScheme.onBackground;
      }
    }

    if (taskModel.status == TaskStatus.Done) {
      cardColor = theme.colorScheme.background;
      isChecking = true;
    } else if (taskModel.status == TaskStatus.Start) {
      cardColor = theme.colorScheme.onSecondary;
      isChecking = true;
    } else if (taskModel.status == TaskStatus.Skip) {
      cardColor = theme.colorScheme.onBackground;
      isChecking = true;
    } else if (taskModel.status == TaskStatus.Confirm) {
      cardColor = theme.colorScheme.onSurface;
      if (taskModel.isDisable ?? false) {
        cardColor = const Color.fromRGBO(85, 105, 187, -1);
      }
      isChecking = true;
    }

    var startTime = DateTime.fromMicrosecondsSinceEpoch(
        taskModel.start_date!.microsecondsSinceEpoch);
    var finishTime = DateTime.fromMicrosecondsSinceEpoch(
        taskModel.finish_date!.microsecondsSinceEpoch);

    // Color.fromRGBO(109, 7, 209, 100)

    return Card(
      elevation: 5.0,
      color: taskModel.status == TaskStatus.Skip
          ? theme.colorScheme.onBackground
          : taskModel.type == TaskStatus.Request
              ? const Color.fromRGBO(109, 7, 209, 1)
              : cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(StaticDataConfig.border_radius),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      child: SizedBox(
        height: 75,
        child: ListTile(
            onTap: onPressed,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
            leading: Container(
              padding: const EdgeInsets.only(right: 5.0),
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(
                          width: 1.0, color: theme.colorScheme.onPrimary))),
              child: Column(
                children: <Widget>[
                  Text(
                    '${startTime.day}',
                    style: theme.textTheme.headlineLarge?.merge(
                        TextStyle(color: isChecking ? selectedCard : null)),
                  ),
                  Text(DateFormat('E').format(startTime),
                      style: theme.textTheme.headlineMedium?.merge(
                          TextStyle(color: isChecking ? selectedCard : null)))
                ],
              ),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.merge(
                      TextStyle(color: isChecking ? selectedCard : null)),
                ),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                            StaticDataConfig.border_radius),
                        color: theme.colorScheme.onPrimary,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Text(
                          "${taskModel.type}",
                          style: theme.textTheme.headlineSmall?.merge(
                              TextStyle(color: theme.colorScheme.primary)),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    taskModel.status == TaskStatus.Skip
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  StaticDataConfig.border_radius),
                              color: theme.colorScheme.onPrimary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: Text(
                                "${taskModel.status?.toUpperCase()}",
                                style: theme.textTheme.headlineSmall?.merge(
                                    TextStyle(
                                        color: theme.colorScheme.primary)),
                              ),
                            ),
                          )
                        : SizedBox.shrink()
                  ],
                )
              ],
            ),
            // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    Material(
                      type: MaterialType.transparency,
                      child: Ink(
                        decoration: BoxDecoration(
                            border: Border.all(color: clockInColor, width: 2),
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(40.0)), //<-- SEE HERE
                        child: InkWell(
                          borderRadius: BorderRadius.circular(40.0),
                          onTap: () {},
                          child: Padding(
                            padding: EdgeInsets.all(1.0),
                            child: Icon(
                              Icons.timer,
                              color: clockInColor,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      " : ${DateFormat.jm().format(subTitle)}",
                      style: theme.textTheme.bodyMedium?.merge(
                          TextStyle(color: isChecking ? selectedCard : null)),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
                Row(
                  children: [
                    taskModel.status == TaskStatus.Done
                        ? Material(
                            type: MaterialType.transparency,
                            child: Ink(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: clockOutColor, width: 2),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      40.0)), //<-- SEE HERE
                              child: InkWell(
                                borderRadius: BorderRadius.circular(40.0),
                                onTap: () {},
                                child: Padding(
                                  padding: EdgeInsets.all(1.0),
                                  child: Icon(
                                    Icons.timer,
                                    color: clockOutColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    Text(
                      " : ${DateFormat.jm().format(finishTime)}",
                      style: theme.textTheme.headlineSmall?.merge(
                          TextStyle(color: isChecking ? selectedCard : null)),
                      textAlign: TextAlign.justify,
                    )
                  ],
                )
              ],
            ),
            trailing: Icon(
              Icons.keyboard_arrow_right,
              size: 25.0,
              color: isChecking ? selectedCard : null,
            )),
      ),
    );
  }
}
