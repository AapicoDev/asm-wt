import 'package:asm_wt/app/my_account/my_account_controller.dart';
import 'package:asm_wt/app/tasks/today_task/today_task_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asm_wt/app/app_controller.dart';
import 'package:asm_wt/models/new_feeds_model.dart';
import 'package:asm_wt/models/notification_model.dart';
import 'package:asm_wt/models/tasks_model.dart';
import 'package:asm_wt/service/new_feeds_service.dart';
import 'package:asm_wt/service/notification_service.dart';
import 'package:asm_wt/service/task_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/loading_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class TasksDetailController extends ControllerMVC {
  late AppStateMVC appState;
  late String taskId;
  TasksService _tasksService;
  NotificationService _notificationService;
  late NewFeedsService newFeedsService;
  TaskModel taskModel = TaskModel();
  final SharedPreferences prefs = GetIt.instance<SharedPreferences>();
  TodayTaskController todayTaskController = TodayTaskController();
  MyAccountController? conUser;

  factory TasksDetailController() => _this ??= TasksDetailController._();
  TasksDetailController._()
      : newFeedsService = NewFeedsService(),
        _tasksService = TasksService(),
        _notificationService = NotificationService(),
        conUser = MyAccountController(),
        super();
  static TasksDetailController? _this;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // setupToken();
    /// Retrieve the 'app level' State object
    appState = rootState!;

    /// You're able to retrieve the Controller(s) from other State objects.
    var con = appState.controller;
    con = appState.controllerByType<AppController>();
    con = appState.controllerById(con?.keyId);
    conUser?.initState();
    debugPrint("Userdata ${conUser?.userModel?.toJson().toString()}");
  }

  Future<void> createNewFeedsFunc(String? typeId) async {
    NewFeedsModel newFeedsModel = NewFeedsModel();

    newFeedsModel.title = NewFeedsType.Accept;
    newFeedsModel.fromId = taskModel.userId;
    newFeedsModel.toId = prefs.getString("organizationId");
    newFeedsModel.createdDate = Timestamp.now();
    newFeedsModel.type = NewFeedsType.Task;
    newFeedsModel.typeId = typeId;
    newFeedsModel.desc = "Accepted Task";
    newFeedsModel.status = TaskStatus.Confirm;

    //create new feed;
    await newFeedsService.createNewFeeds(newFeedsModel.toJson());
  }

  Future<void> createNotification(TaskModel? taskModel, String action) async {
    NotificationModel notificationModel = NotificationModel();
    notificationModel.desc = "Action on : ${DateTime.now()}";
    notificationModel.title = "Task $action";
    notificationModel.titleId = taskModel?.taskId;
    notificationModel.fromId = taskModel?.userId;
    notificationModel.status = action;
    notificationModel.toId = taskModel?.controller_id;
    await _notificationService
        .createMaintenanceNotification(notificationModel.toJson());
  }

  Future<void> onAcceptPressed(
      BuildContext context, TaskModel? taskModel) async {
    LoadingOverlay.of(context).show();
    Map<String, dynamic> taskData = <String, dynamic>{};
    taskData['status'] = TaskStatus.Confirm;

    debugPrint("userData ${conUser?.userModel?.toJson().toString()}");
    await _tasksService.updateTaskStatusByTaskId(taskModel?.taskId, {
      ...taskData,
      "site_th": conUser?.userModel?.siteTH,
      "site_en": conUser?.userModel?.siteEN,
      "section_code": conUser?.userModel?.sectionCode,
      "section_th": conUser?.userModel?.sectionTH,
      "section_en": conUser?.userModel?.sectionEN,
      "job_code": conUser?.userModel?.jobCode,
      "site_code": conUser?.userModel?.siteCode,
      "job_th": conUser?.userModel?.jobTH,
      "job_en": conUser?.userModel?.jobEN,
      "firstname_th": conUser?.userModel?.firstnameTH,
      "firstname_en": conUser?.userModel?.firstnameEN,
      "lastname_th": conUser?.userModel?.lastnameTH,
      "lastname_en": conUser?.userModel?.lastnameEN
    }).then((res) async => {
          if (res.status == "S")
            {
              await createNewFeedsFunc(taskModel?.taskId),
              await createNotification(taskModel, TaskStatus.Confirm),
              LoadingOverlay.of(context).hide(),
              Navigator.of(context).pop()
            }
        });
  }
}
