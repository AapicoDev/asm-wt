import 'dart:async';

import 'package:asm_wt/service/base_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asm_wt/app/app_key.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/new_feeds_model.dart';
import 'package:asm_wt/models/tasks_model.dart';
import 'package:asm_wt/service/new_feeds_service.dart';
import 'package:asm_wt/service/task_service.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/loading_overlay_widget.dart';
import 'package:asm_wt/widget/network_error_widget.dart';
import 'package:ntp/ntp.dart';

class TaskCalendarController extends ControllerMVC {
  late final AppStateMVC appState;
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime dateNow = DateTime.now();
  DateTime? selectedDay;
  late DateTime selectedFinishDay = DateTime.now();
  late DateTime selectedStartDay = DateTime.now();
  late TasksService tasksService;
  late NewFeedsService newFeedsService;
  TextEditingController command = TextEditingController();
  late Map<DateTime, List<TaskModel>> selectedEvents;
  List<TaskModel> eventList = <TaskModel>[];
  bool tasksLoading = false;
  String? userId;
  int taskSelectionType = 0;

  late StreamSubscription subscription;
  List<ConnectivityResult>? connectivityResult;

  final SharedPreferences prefs = GetIt.instance<SharedPreferences>();

  Time? startTimePicker;
  Time? finishTimePicker;

  factory TaskCalendarController([StateMVC? state]) =>
      _this ??= TaskCalendarController._(state);
  TaskCalendarController._(StateMVC? state)
      : tasksService = TasksService(),
        newFeedsService = NewFeedsService(),
        super(state);
  static TaskCalendarController? _this;

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedEvents = {};
    initConnectivity();
    getConnectivity();
    loadTimeServer();

    userId = prefs.getString('userId');
  }

  Future<void> loadTimeServer() async {
    try {
      var serverTime = await NTP.now();
      setState(() {
        dateNow = serverTime;
        selectedStartDay = serverTime;
        selectedFinishDay = serverTime;
        selectedDay = serverTime;
      });

      startTimePicker =
          Time(hour: dateNow.hour, minute: dateNow.minute, second: 00);
      finishTimePicker =
          Time(hour: dateNow.hour + 1, minute: dateNow.minute, second: 00);
    } on Exception catch (_) {
      setState(() {
        selectedStartDay = dateNow;
        selectedFinishDay = dateNow;
        selectedDay = dateNow;
      });
      rethrow;
    }
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> results;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      results = await Connectivity().checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status : $e');
      return null;
    }
    connectivityResult = results;
  }

  Future<void> getConnectivity() async =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> result) async {
          if (connectivityResult != ConnectivityResult.none) {
            loadTimeServer();
          }
          setState(() {
            connectivityResult = result;
          });
        },
      );

  void stopLoading() {
    setState(() {
      tasksLoading = false;
    });
  }

  Future<DateTime?> selectDate(
      BuildContext context, Function setState, bool isStartDay) async {
    var now = await NTP.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDay ? selectedStartDay : selectedFinishDay,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2040),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: TextTheme(
              bodyMedium: Theme.of(context).textTheme.bodyMedium,
              bodySmall: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: 400, maxHeight: 600),
                child: child,
              )
            ],
          ),
        );
      },
    );
    if (picked != null && picked != selectedFinishDay ||
        picked != null && picked != selectedStartDay) {
      setState(() {
        isStartDay ? selectedStartDay = picked : selectedFinishDay = picked;
      });
    }

    return picked;
  }

  void onTimePickerOpen(BuildContext context, Function setState, bool isStart) {
    Navigator.of(context).push(
      showPicker(
        showSecondSelector: false,
        is24HrFormat: false,
        dialogInsetPadding: EdgeInsets.only(left: 5, right: 5),
        borderRadius: StaticDataConfig.border_radius,
        cancelText: translate("button.cancel"),
        okText: translate("button.ok"),
        okStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        buttonStyle: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StaticDataConfig.border_radius),
          )),
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).colorScheme.primary),
        ),
        cancelButtonStyle: ButtonStyle(
          padding: MaterialStateProperty.all(EdgeInsets.zero),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(StaticDataConfig.border_radius),
          )),
          backgroundColor:
              MaterialStateProperty.all(Theme.of(context).colorScheme.tertiary),
        ),
        context: context,
        value: (isStart ? startTimePicker : finishTimePicker) ??
            Time(hour: 12, minute: 00),
        onChange: (newTime) => {
          if (isStart)
            {
              setState(() {
                startTimePicker = newTime;
              })
            }
          else
            {
              setState(() {
                finishTimePicker = newTime;
              })
            }
        },
        sunrise: const TimeOfDay(hour: 6, minute: 00), // optional
        sunset: const TimeOfDay(hour: 18, minute: 00),
        duskSpanInMinutes: 120, // optio
        minuteInterval: TimePickerInterval.FIVE,
        // Optional onChange to receive value as DateTime
        onChangeDateTime: (DateTime dateTime) {
          // print(dateTime);
          debugPrint("[debug datetime]:  $dateTime");
        },
      ),
    );
  }

  Future<void> createNewFeedsFunc(String typeId) async {
    NewFeedsModel newFeedsModel = NewFeedsModel();

    newFeedsModel.title = NewFeedsType.Request;
    newFeedsModel.fromId = userId;
    newFeedsModel.toId = prefs.getString("organizationId");
    newFeedsModel.createdDate = Timestamp.now();
    newFeedsModel.type = NewFeedsType.Task;
    newFeedsModel.typeId = typeId;
    newFeedsModel.desc = command.text;
    newFeedsModel.status = TaskStatus.Confirm;

    //create new feed;
    await newFeedsService.createNewFeeds(newFeedsModel.toJson());
  }

  Future<void> onCreatedBtnPressed(BuildContext context) async {
    if (AppKeys.requestNoted.currentState!.validate()) {
      if (connectivityResult == ConnectivityResult.none) {
        showDialog(
          barrierDismissible: true,
          context: context,
          builder: (_) => NetworkErrorDialog(
            onPressed: Navigator.of(context).pop,
          ),
        );
      } else {
        LoadingOverlay.of(context).show();

        DateTime startDate = DateTime(
            selectedStartDay.year,
            selectedStartDay.month,
            selectedStartDay.day,
            startTimePicker!.hour,
            startTimePicker!.minute);
        DateTime finishDate = DateTime(
            selectedFinishDay.year,
            selectedFinishDay.month,
            selectedFinishDay.day,
            finishTimePicker!.hour,
            finishTimePicker!.minute);

        if (finishDate.isAfter(startDate)) {
          TaskModel newtaskModel = TaskModel();
          newtaskModel.name = "Task Requirement";
          newtaskModel.controller_id = userId;
          newtaskModel.controller_name = prefs.getString("username");
          newtaskModel.desc = command.text;
          newtaskModel.create_date = Timestamp.fromDate(dateNow);
          newtaskModel.status = TaskStatus.Confirm;
          newtaskModel.userId = userId;
          // newtaskModel.employeeModelRefData = FirebaseFirestore.instance
          //     .doc('${TableName.dbEmployeeTable}/${userId}');
          try {
            newtaskModel.employeeModelRefData = FirebaseFirestore.instance
                .doc('${TableName.dbEmployeeTable}/$userId');
          } catch (e) {
            // Handle the error
            print('Error creating document reference: $e');
          }
          newtaskModel.isDisable = false;
          newtaskModel.type = NewFeedsType.Request;
          newtaskModel.taskGroup =
              taskSelectionType == 0 ? StatusType.scheduled : StatusType.ot;
          newtaskModel.start_date = Timestamp.fromDate(DateTime(
              selectedStartDay.year,
              selectedStartDay.month,
              selectedStartDay.day,
              startTimePicker!.hour,
              startTimePicker!.minute,
              startTimePicker!.second));
          newtaskModel.finish_date = Timestamp.fromDate(DateTime(
              selectedFinishDay.year,
              selectedFinishDay.month,
              selectedFinishDay.day,
              finishTimePicker!.hour,
              finishTimePicker!.minute,
              finishTimePicker!.second));

          await tasksService
              .createUserTaskNote(newtaskModel.toJson(true))
              .then((res) async => {
                    if (res.status == "S")
                      {
                        await createNewFeedsFunc(res.data.toString()),
                        showToastMessage(
                            context,
                            translate('message.successful'),
                            Theme.of(context).colorScheme.primary),
                        Navigator.pop(context)
                      }
                  });
        } else {
          showToastMessage(context, translate('message.went_wrong'),
              Theme.of(context).colorScheme.onBackground);
        }

        LoadingOverlay.of(context).hide();
      }
    }
  }

  List<TaskModel> findSelectedTime(DateTime? day, List<TaskModel> taskModels) {
    eventList = <TaskModel>[];
    for (var task in taskModels) {
      if (task.start_date == null) {
      } else {
        var startDate = DateTime.fromMicrosecondsSinceEpoch(
            task.start_date!.microsecondsSinceEpoch);
        DateTime onlyDate =
            DateTime(startDate.year, startDate.month, startDate.day);
        if (isSameDay(day, onlyDate)) {
          eventList.add(task);
        }
      }
    }
    return eventList;
  }
}
