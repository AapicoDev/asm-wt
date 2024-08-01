import 'package:asm_wt/models/employee_model.dart';
import 'package:asm_wt/models/manage_tasks_model.dart';
import 'package:asm_wt/models/tasks_model.dart';
import 'package:asm_wt/service/RESTAPI/task_management_service.dart';
import 'package:asm_wt/service/task_service.dart';
import 'package:asm_wt/service/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:ntp/ntp.dart';

class ManageTaskController extends ControllerMVC {
  late final AppStateMVC appState;
  User? user;

  factory ManageTaskController([StateMVC? state]) =>
      _this ??= ManageTaskController._(state);
  ManageTaskController._(StateMVC? state) : super(state);
  static ManageTaskController? _this;
  TaskManagementService? taskManagementService;
  ScrollController scrollControllerTable =
      ScrollController(initialScrollOffset: 0);
  TasksService _tasksService = TasksService();
  bool sortAscending = true;
  bool sortStartDate = true;
  bool sortEmployeeId = true;
  bool sortClockGroupStatus = true;
  bool sortFinishDate = true;
  int? sortColumnIndex;
  UsersService _usersService = UsersService();
  DateTime now = DateTime.now();
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadTimeServer();
    // loadTaskByDepartmentOnControl();
  }

  Future<void> loadTimeServer() async {
    try {
      var serverTime = await NTP.now();
      setState(() {
        now = serverTime;
        start = serverTime;
        end = serverTime;
      });
    } on Exception catch (_) {
      setState(() {
        start = now;
        end = now;
      });
      rethrow;
    }
  }

  Future<DateTimeRange?> dateRangePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month - 1, now.day),
      lastDate: now.add(const Duration(days: 30)),
      initialDateRange: DateTimeRange(
        end: end,
        start: start,
      ),
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
                    const BoxConstraints(maxWidth: 350, maxHeight: 450),
                child: child,
              )
            ],
          ),
        );
      },
    );

    if (picked != null) {
      // Update state or perform any action with the selected date range
      setState(() {
        start = picked.start;
        end = picked.end;
      });
      await loadTaskControllerFromAPI();
    }

    return picked;
  }

  Future<List<ManageTaskModel>?> loadTaskControllerFromAPI() async {
    var result = await taskManagementService?.getControllerTaskWithFilterDate(
        DateFormat('MM/dd/yyyy').format(start),
        DateFormat('MM/dd/yyyy').format(end));

    return result;
  }

  Future<void> loadTaskByDepartmentOnControl() async {
    EmployeeModel? employeeModel;

    var allUserIndepartment =
        await _usersService.getEmployeeByDepartmentId("SecurityGuard");

    for (EmployeeModel emp in allUserIndepartment ?? []) {
      var allTaskFromTeam =
          await _tasksService.getRecentTasksByEmployeeRefID(emp.employeeID);

      for (TaskModel task in allTaskFromTeam ?? []) {
        await task.employeeModelRefData?.get().then((employeeData) => {
              employeeModel = EmployeeModel.fromDocumentSnapshot(employeeData),
              print("------------ ${task.desc}, ${employeeModel?.username}")
            });
      }
    }
  }

  Future<void> sampleFunc(BuildContext context) async {
    await null;
  }
}
