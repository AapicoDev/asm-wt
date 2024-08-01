import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:asm_wt/app/app_key.dart';
import 'package:asm_wt/app/tasks/task_calendar/task_calendar_controller.dart';
import 'package:asm_wt/app/tasks/task_calendar/task_dismiss_widget.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/tasks_model.dart';
import 'package:asm_wt/router/router_name.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/widget/button_widget.dart';
import 'package:asm_wt/widget/task_widget.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:asm_wt/widget/text_field_widget.dart';

class TaskCalendarView extends StatefulWidget {
  final String userId;

  const TaskCalendarView({Key? key, required this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TaskCalendarViewState();
}

class _TaskCalendarViewState extends StateMVC<TaskCalendarView> {
  late TaskCalendarController con;
  List<TaskModel> taskModels = [];

  _TaskCalendarViewState() : super(TaskCalendarController()) {
    con = controller as TaskCalendarController;
  }

  @override
  void initState() {
    setState(() {
      con.userId = widget.userId;
    });
    super.initState();
  }

  Widget timeComponent(String title, Widget? widget) {
    var theme = Theme.of(context);
    return Row(children: <Widget>[
      Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: const Text('.'),
        ),
      ),
      Expanded(
        flex: 1,
        child: Text(
          title,
          style: theme.textTheme.headlineSmall,
        ),
      ),
      Expanded(
        flex: 2,
        child: widget ?? const SizedBox.shrink(),
      ),
    ]);
  }

  void onCreateNotePressed(
      BuildContext context, String title, String subTitle) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    con.command.text = '';
    con.taskSelectionType = 0;

    showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0))),
        builder: (context) {
          if (!mounted) {
            Navigator.pop(context);
            return const SizedBox.shrink();
          } else {
            return Form(
              key: AppKeys.requestNoted,
              child: Padding(
                padding:
                    const EdgeInsets.all(StaticDataConfig.app_padding - 10),
                child: SizedBox(
                  height: height / 1.25,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                          decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          height: height / 70,
                          width: width / 7),
                      Container(
                        // alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        child:
                            Text(title, style: theme.textTheme.headlineLarge),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(
                              StaticDataConfig.app_padding - 10),
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                subTitle,
                                style: theme.textTheme.bodyMedium,
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 9,
                          child: StatefulBuilder(
                            builder: (BuildContext context, setState) => Column(
                              children: [
                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Radio(
                                          fillColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) => theme
                                                      .colorScheme.primary),
                                          value: 0,
                                          groupValue: con.taskSelectionType,
                                          onChanged: (v) => {
                                            setState(
                                                () => con.taskSelectionType = 0)
                                          },
                                        ),
                                        TextButton(
                                            onPressed: () => {
                                                  setState(() =>
                                                      con.taskSelectionType = 0)
                                                },
                                            child: Text(
                                                translate(
                                                    "text_header.schedule"),
                                                style:
                                                    theme.textTheme.bodyMedium))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio(
                                          fillColor:
                                              MaterialStateColor.resolveWith(
                                                  (states) => theme
                                                      .colorScheme.primary),
                                          value: 1,
                                          groupValue: con.taskSelectionType,
                                          onChanged: (v) => {
                                            setState(
                                                () => con.taskSelectionType = 1)
                                          },
                                        ),
                                        TextButton(
                                            onPressed: () => {
                                                  setState(() =>
                                                      con.taskSelectionType = 1)
                                                },
                                            child: Text(
                                                translate("text_header.ot"),
                                                style:
                                                    theme.textTheme.bodyMedium))
                                      ],
                                    )
                                  ],
                                ),
                                TextFieldWidget(
                                  autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                  controller: con.command,
                                  title: translate('text_header.noted'),
                                  hint: translate("text_header.task_noted"),
                                  boolSuffixIcon: false,
                                  keyboardType: TextInputType.text,
                                  prefixIcon: const Icon(Icons.task),
                                  validator: FormBuilderValidators.compose([
                                    FormBuilderValidators.required(),
                                  ]),
                                ),
                                timeComponent(
                                    translate("text_header.start_date"),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => con.selectDate(
                                              context, setState, true),
                                          child: Text.rich(
                                            TextSpan(
                                                style:
                                                    theme.textTheme.bodyMedium,
                                                children: [
                                                  TextSpan(
                                                      text: DateFormat.yMMMEd()
                                                          .format(con
                                                              .selectedStartDay),
                                                      style: theme.textTheme
                                                          .headlineMedium),
                                                ]),
                                          ),
                                        )
                                      ],
                                    )),
                                timeComponent(
                                  translate("text_header.start_time"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => con.onTimePickerOpen(
                                            context, setState, true),
                                        child: Text(
                                          "${con.startTimePicker!.hour > 9 ? con.startTimePicker?.hour : "0${con.startTimePicker?.hour}"} : ${con.startTimePicker!.minute > 9 ? con.startTimePicker?.minute : "0${con.startTimePicker?.minute}"}",
                                          style: theme.textTheme.headlineLarge,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.punch_clock,
                                          color: theme.colorScheme.primary,
                                        ),
                                        onPressed: () => con.onTimePickerOpen(
                                            context, setState, true),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(),
                                timeComponent(
                                    translate("text_header.finish_date"),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () => con.selectDate(
                                              context, setState, false),
                                          child: Text.rich(
                                            TextSpan(
                                                style:
                                                    theme.textTheme.bodyMedium,
                                                children: [
                                                  TextSpan(
                                                      text: DateFormat.yMMMEd()
                                                          .format(con
                                                              .selectedFinishDay),
                                                      style: theme.textTheme
                                                          .headlineMedium),
                                                ]),
                                          ),
                                        )
                                      ],
                                    )),
                                timeComponent(
                                  translate("text_header.finish_time"),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => con.onTimePickerOpen(
                                            context, setState, false),
                                        child: Text(
                                          "${con.finishTimePicker!.hour > 9 ? con.finishTimePicker?.hour : "0${con.finishTimePicker?.hour}"} : ${con.finishTimePicker!.minute > 9 ? con.finishTimePicker?.minute : "0${con.finishTimePicker?.minute}"}",
                                          style: theme.textTheme.headlineLarge,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.punch_clock,
                                          color: theme.colorScheme.primary,
                                        ),
                                        onPressed: () => con.onTimePickerOpen(
                                            context, setState, false),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(
                        height: 5,
                      ),
                      ButtonWidget(
                          enable: true,
                          fullStyle: true,
                          title: translate('button.create'),
                          onPressed: () async =>
                              con.onCreatedBtnPressed(context))
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // double width = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        floatingActionButton: InkWell(
          onTap: () {
            onCreateNotePressed(context, translate("text_header.create_task"),
                translate("contents.create_task"));
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
            ),
            child: Icon(
              Icons.add,
              color: theme.colorScheme.onPrimary,
              size: 30,
            ),
          ),
        ),
        body: con.tasksLoading
            ? const SizedBox(child: Center(child: CircularProgressIndicator()))
            : StreamBuilder<QuerySnapshot>(
                stream:
                    con.tasksService.getTasksSnapshotByUserId(widget.userId),
                builder: (context, snapshot) {
                  taskModels = [];

                  if (snapshot.hasData) {
                    List<DocumentSnapshot>? documents = snapshot.data!.docs;
                    for (var doc in documents) {
                      var task = TaskModel.fromDocumentSnapshot(doc);
                      if (task.type != StatusType.delete) {
                        taskModels.add(task);
                      }
                    }
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        TableCalendar(
                          firstDay: kFirstDay,
                          calendarBuilders: CalendarBuilders(
                            dowBuilder: (context, day) {
                              final text = DateFormat.E().format(day);
                              return Center(
                                child: Text(
                                  text,
                                  style: TextStyle(
                                      color: day.weekday == DateTime.sunday ||
                                              day.weekday == DateTime.saturday
                                          ? theme.colorScheme.onBackground
                                          : Colors.black,
                                      fontSize: 14),
                                ),
                              );
                            },
                            singleMarkerBuilder:
                                (context, date, TaskModel taskModel) {
                              Color dotMarkColor = theme.colorScheme.onTertiary;

                              if (taskModel.status == TaskStatus.Done) {
                                dotMarkColor = theme.colorScheme.background;
                              } else if (taskModel.status == TaskStatus.Start) {
                                dotMarkColor = theme.colorScheme.onSecondary;
                              } else if (taskModel.status ==
                                  TaskStatus.Confirm) {
                                dotMarkColor = theme.colorScheme.onSurface;
                              }

                              return Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: dotMarkColor), //Change color
                                width: 5.0,
                                height: 5.0,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 1),
                              );
                            },
                          ),
                          lastDay: kLastDay,
                          focusedDay: con.dateNow,
                          rowHeight: 40,
                          calendarStyle: CalendarStyle(
                              defaultTextStyle: const TextStyle(
                                  fontSize: 14, fontFamily: "Gilroy Light"),
                              weekendTextStyle: TextStyle(
                                  color: theme.colorScheme.onBackground,
                                  fontSize: 14),
                              canMarkersOverflow: true,
                              todayTextStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontFamily: "Gilroy Light",
                                  fontWeight: FontWeight.bold),
                              selectedTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: "Gilroy Light",
                                  fontWeight: FontWeight.bold),
                              selectedDecoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  shape: BoxShape.circle),
                              todayDecoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary,
                                  shape: BoxShape.circle)),
                          headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: TextStyle(
                                  fontSize: 16,
                                  fontFamily: "Gilroy Bold",
                                  fontWeight: FontWeight.bold)),
                          calendarFormat: con.calendarFormat,
                          availableGestures: AvailableGestures.all,
                          selectedDayPredicate: (day) {
                            // Use `selectedDayPredicate` to determine which day is currently selected.
                            // If this returns true, then `day` will be marked as selected.

                            // Using `isSameDay` is recommended to disregard
                            // the time-part of compared DateTime objects.
                            return isSameDay(con.selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            if (!isSameDay(con.selectedDay, selectedDay)) {
                              // Call `setState()` when updating the selected day
                              setState(() {
                                con.selectedDay = selectedDay;
                                con.dateNow = focusedDay;

                                // con.eventList = con.getEventsForDay(selectedDay);
                              });
                            }
                          },
                          onFormatChanged: (format) {
                            if (con.calendarFormat != format) {
                              // Call `setState()` when updating calendar format
                              setState(() {
                                con.calendarFormat = format;
                              });
                            }
                          },
                          onPageChanged: (focusedDay) {
                            // No need to call `setState()` here
                            con.dateNow = focusedDay;
                          },
                          eventLoader: (day) {
                            return con.findSelectedTime(day, taskModels);
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Text(
                            translate('text_header.all_task_list'),
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                        ...con
                            .findSelectedTime(con.selectedDay, taskModels)
                            .map((TaskModel taskModel) =>
                                taskModel.type == TaskStatus.Request
                                    ? TaskDismissWidget(
                                        taskModel: taskModel,
                                        now: con.dateNow,
                                      )
                                    : TaskCardWidget(
                                        now: con.dateNow,
                                        taskModel: taskModel,
                                        onPressed: () {
                                          try {
                                            if (taskModel.isDisable ?? false) {
                                            } else {
                                              context.pushNamed(
                                                  RouteNames.tasksDetail,
                                                  extra: taskModel);
                                            }
                                          } catch (e) {
                                            print(e);
                                          }
                                        },
                                        title: taskModel.desc ?? '',
                                        subTitle:
                                            DateTime.fromMicrosecondsSinceEpoch(
                                                taskModel.start_date!
                                                    .microsecondsSinceEpoch),
                                      )),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
