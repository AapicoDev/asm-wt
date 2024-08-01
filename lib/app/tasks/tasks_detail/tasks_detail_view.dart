import 'package:table_calendar/table_calendar.dart';
import 'package:asm_wt/app/tasks/tasks_detail/tasks_detail_controller.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/tasks_model.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/app_bar_widget.dart';
import 'package:asm_wt/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/widget/task_detail_widget.dart';

class TasksDetailView extends StatefulWidget {
  final TaskModel taskModel;
  const TasksDetailView({Key? key, required this.taskModel}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TasksDetailViewState();
}

class _TasksDetailViewState extends StateMVC<TasksDetailView> {
  late TasksDetailController con;
  String? taskStatusReportDocId;

  _TasksDetailViewState() : super(TasksDetailController()) {
    con = controller as TasksDetailController;
  }

  DateTime dateNow = DateTime.now();

  @override
  void initState() {
    super.initState();
    con.taskModel = widget.taskModel;
    taskStatusReportDocId =
        "${con.prefs.getString("organizationId")}-${dateNow.year.toString()}";
  }

  Widget buttonWidget(BuildContext context, TaskModel taskModel) {
    var startDate = DateTime.fromMicrosecondsSinceEpoch(
        taskModel.start_date!.microsecondsSinceEpoch);
    DateTime onlyDate =
        DateTime(startDate.year, startDate.month, startDate.day);
    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);

    print("================${taskModel.status}");

    switch (taskModel.status) {
      case TaskStatus.Done:
        return Text(translate('message.done_task'));
      case TaskStatus.Confirm:
        if (isSameDay(date, onlyDate)) {
          return ButtonWidget(
            enable: true,
            fullStyle: true,
            onPressed: () => con.todayTaskController
                .onClockInPressed(context, con.taskModel, 'fromCalendar'),
            title: translate('button.clock_in'),
          );
        } else {
          return Container();
        }

      case TaskStatus.Start:
        return ButtonWidget(
          enable: true,
          fullStyle: true,
          onPressed: () => {
            con.todayTaskController
                .onClockOutPressed(context, con.taskModel, 'fromCalendar'),
          },
          title: translate('button.clock_out'),
        );
      case TaskStatus.New:
        return ButtonWidget(
          enable: true,
          fullStyle: true,
          onPressed: () => con.onAcceptPressed(context, con.taskModel),
          title: translate('button.accept'),
        );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
            padding: const EdgeInsets.all(StaticDataConfig.app_padding),
            child: buttonWidget(context, con.taskModel)),
        appBar: AppBarWidget(
          color: Theme.of(context).colorScheme.primary,
          isDiscard: false,
          type: StaticModelType.manu,

          title: translate('app_bar.task_detail'),
          leadingBack: true,
          backIcon: Icons.arrow_back,
          icon: Icons.help,
          // iconTitle: translate('button.help'),
          iconTitle: '',
          onRightPressed: () => showActionGenFunc(context,
              translate('text_header.help'), translate('contents.help')),
        ),
        body: Column(
          children: [
            // con.vehicleModel != null
            //     ? VehicleDetailWidget(
            //         checkStatus: taskModel.isCheckIn,
            //         vehicleModel: con.vehicleModel)
            //     : const IndicatorWidget(),
            Expanded(
              child: SingleChildScrollView(
                  child: TaskDetailWidget(
                taskModel: con.taskModel,
                isHasHeader: false,
              )),
            ),
          ],
        ));
  }
}
