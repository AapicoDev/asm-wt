import 'package:asm_wt/service/RESTAPI/geofencing_service.dart';
import 'package:asm_wt/widget/network_error_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asm_wt/app/tasks/today_task/today_task_controller.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/tasks_model.dart';
import 'package:asm_wt/service/task_service.dart';
import 'package:asm_wt/service/task_status_report_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/widget/task_detail_widget.dart';

class TodayTaskView extends StatefulWidget {
  final String userId;
  const TodayTaskView({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TodayTaskViewState();
}

class _TodayTaskViewState extends StateMVC<TodayTaskView> {
  late TodayTaskController con;
  final TasksService _tasksService = TasksService();
  final ScrollController scrollController =
      ScrollController(initialScrollOffset: 0);

  TaskStatusReportService taskStatusReportService = TaskStatusReportService();
  SharedPreferences prefs = GetIt.instance<SharedPreferences>();

  _TodayTaskViewState() : super(TodayTaskController()) {
    con = controller as TodayTaskController;
  }

  @override
  void initState() {
    super.initState();
    con.geoFencingService = context.read<GeoFencingService>();

    setState(() {
      con.userId = widget.userId;
    });
    con.taskStatusReportDocId =
        "${prefs.getString("organizationId")}-${con.now.year.toString()}";
    // taskStatusReportService
    //     .getTaskStatusReportModelByDocID(taskStatusReportDocId)
    //     .then((res) => {print("===============${res.jan?.late_start}")});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
        stream: _tasksService.getTodayTaskSnapshotByDriverId(widget.userId),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
                child: Center(child: CircularProgressIndicator()));
          }

          List<DocumentSnapshot>? allDocuments = snapshot.data!.docs;
          List<DocumentSnapshot> documents = allDocuments.where((doc) {
            return doc['status'] != 'deleted';
          }).toList();

          if (documents.isNotEmpty) {
            for (var doc in documents) {
              var item = TaskModel.fromDocumentSnapshot(doc);

              var startDate = DateTime.fromMicrosecondsSinceEpoch(
                  item.start_date!.microsecondsSinceEpoch);
              var finishDate = DateTime.fromMicrosecondsSinceEpoch(
                  item.finish_date!.microsecondsSinceEpoch);

              DateTime finishTime =
                  DateTime(finishDate.year, finishDate.month, finishDate.day);
              DateTime startTime =
                  DateTime(startDate.year, startDate.month, startDate.day);

              DateTime dateNow =
                  DateTime(con.now.year, con.now.month, con.now.day);

              DateTime dateNowHour = DateTime(con.now.year, con.now.month,
                  con.now.day, con.now.hour, con.now.minute);
              DateTime finishTimeHour = DateTime(
                  finishDate.year,
                  finishDate.month,
                  finishDate.day,
                  finishDate.hour,
                  finishDate.minute);

              var twoHourBeforeFinish = finishTimeHour.subtract(Duration(
                  hours: con.settingsModel?.before_clock_out_hour ?? 0));

              var canCheckStartTask = startTime.compareTo(dateNow);
              var canCheckFinishTask = finishTime.compareTo(dateNow);
              var diffHour = twoHourBeforeFinish.difference(dateNowHour);

              if ((canCheckFinishTask == 0 &&
                      item.status == TaskStatus.Start) ||
                  canCheckStartTask == 0) {
                if (item.type == StatusType.delete ||
                    item.status == TaskStatus.Skip) {
                } else {
                  return Scaffold(
                      floatingActionButtonLocation:
                          FloatingActionButtonLocation.centerFloat,
                      floatingActionButton: Padding(
                          padding: const EdgeInsets.all(
                              StaticDataConfig.app_padding),
                          child: item.status == TaskStatus.Confirm
                              ? ButtonWidget(
                                  enable: con.onClockInOrClockOutPress
                                      ? false
                                      : true,
                                  fullStyle: true,
                                  // onPressed: () => con.onCheckInPressed(context),
                                  onPressed: !con.onClockInOrClockOutPress
                                      ? () => {
                                            if (con.connectivityResult ==
                                                ConnectivityResult.none)
                                              {
                                                showDialog(
                                                  barrierDismissible: true,
                                                  context: context,
                                                  builder: (_) =>
                                                      NetworkErrorDialog(
                                                    onPressed: () => {
                                                      Navigator.pop(context),
                                                      con.setState(() {
                                                        con.onClockInOrClockOutPress =
                                                            false;
                                                      }),
                                                    },
                                                  ),
                                                )
                                              }
                                            else
                                              {
                                                con.onClockInPressed(
                                                    context, item, null)
                                              }
                                          }
                                      : null,
                                  title: translate('button.clock_in'),
                                )
                              : item.status == TaskStatus.Start
                                  ? diffHour.inHours <=
                                          con.settingsModel!
                                              .before_clock_out_hour!
                                      ? ButtonWidget(
                                          enable: con.onClockInOrClockOutPress
                                              ? false
                                              : true,
                                          fullStyle: true,
                                          onPressed: !con
                                                  .onClockInOrClockOutPress
                                              ? () => {
                                                    con.setState(() {
                                                      con.onClockInOrClockOutPress =
                                                          true;
                                                    }),
                                                    if (con.connectivityResult ==
                                                        ConnectivityResult.none)
                                                      {
                                                        showDialog(
                                                          barrierDismissible:
                                                              true,
                                                          context: context,
                                                          builder: (_) =>
                                                              NetworkErrorDialog(
                                                            onPressed: () => {
                                                              Navigator.pop(
                                                                  context),
                                                              con.setState(() {
                                                                con.onClockInOrClockOutPress =
                                                                    false;
                                                              }),
                                                            },
                                                          ),
                                                        )
                                                      }
                                                    else
                                                      {
                                                        con.onClockOutPressed(
                                                            context, item, null)
                                                      },
                                                  }
                                              : null,
                                          title: translate('button.clock_out'),
                                        )
                                      : SizedBox.shrink()
                                  : SizedBox.shrink()),
                      body: TaskDetailWidget(
                        taskModel: item,
                        isHasHeader: item.driverStartAt != null ? true : false,
                      ));
                }
              }
            }
          }
          return SizedBox(
            width: width,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.content_paste_search_outlined,
                    size: 30,
                    color: theme.colorScheme.onTertiary,
                  ),
                  Text(
                    translate('text_header.no_task'),
                    style: theme.textTheme.headlineSmall
                        ?.merge(TextStyle(color: theme.colorScheme.onTertiary)),
                  ),
                ]),
          );
        });
  }
}
