import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:asm_wt/app/app_service.dart';
import 'package:asm_wt/app/my_account/my_account_controller.dart';
import 'package:asm_wt/app/my_account/my_account_view.dart';
import 'package:asm_wt/app/tasks/task_calendar/task_calendar_view.dart';
import 'package:asm_wt/app/tasks/tasks_root_controller.dart';
import 'package:asm_wt/app/tasks/today_task/today_task_view.dart';
import 'package:asm_wt/core/local_notification.dart';
import 'package:asm_wt/models/employee_model.dart';
import 'package:asm_wt/router/router_name.dart';
import 'package:asm_wt/service/base_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/app_bar_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class TasksRootView extends StatefulWidget {
  final AppService appService;
  TasksRootView({Key? key, required this.appService}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TasksRootView();
}

class _TasksRootView extends StateMVC<TasksRootView> {
  late TasksRootController con;
  SharedPreferences prefs = GetIt.instance<SharedPreferences>();
  ConnectivityResult? connectivityResult;
  Stream<QuerySnapshot<Map<String, dynamic>>>? notificationStream;
  MyAccountController myAccountController = MyAccountController();
  // late final FirebaseMessaging _messaging;
  // PushNotification? _notificationInfo;

  _TasksRootView() : super(TasksRootController()) {
    con = controller as TasksRootController;
  }

  @override
  void initState() {
    super.initState();
    con.getDriverId();
    notificationStream = FirebaseFirestore.instance
        .collection(TableName.dbEmployeeTable)
        .where('employee_id', isEqualTo: con.userId)
        .snapshots();

    employeeIsActivatedStreamFunc();
  }

  Future<void> employeeIsActivatedStreamFunc() async {
    String? identifier;
    AndroidDeviceInfo? androidInfo;

    notificationStream?.listen((event) async {
      var docs = event.docs;
      if (event.docs.isEmpty) {
        return;
      }
      for (var doc in docs) {
        var employee = EmployeeModel.fromDocumentSnapshot(doc);
        if (Platform.isIOS) {
          final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
          var data = await deviceInfoPlugin.iosInfo;
          identifier = "${data.name}-v${data.systemName}";
        } else if (Platform.isAndroid) {
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          androidInfo = await deviceInfo.androidInfo;
        }

        if (employee.isActivated ?? true) {
          // if (employee.deviceID != (androidInfo?.id ?? identifier)) {
          //   myAccountController.onSignOutPressed(context);
          // }
        } else {
          myAccountController.onSignOutPressed(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      // const MyTasksView(),
      TodayTaskView(
        userId: con.userId ?? '',
      ),
      // const MyRequestView(),
      TaskCalendarView(
        userId: con.userId ?? '',
      ),
      // const LiveMapView(),
      MyAccountView(
        userId: con.userId ?? '',
      )
    ];
    final theme = Theme.of(context);
    LocalNotification.initialize();

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: widget.appService.bioAuth
          ? UpgradeAlert(
              upgrader:
                  Upgrader(debugDisplayAlways: false, minAppVersion: '2.0.1'),
              child: Scaffold(
                  appBar: AppBarWidget(
                    color: theme.colorScheme.primary,
                    isDiscard: false,
                    type: StaticModelType.notification,
                    title: widget.appService.navNum == 0
                        ? translate('app_bar.today_task')
                        : widget.appService.navNum == 1
                            ? translate('app_bar.task_calendar')
                            : widget.appService.navNum == 2
                                ? translate('app_bar.my_account')
                                : '',
                    leadingBack: false,
                    // leadingBack: widget.appService.navNum != 2 ? true : false,

                    //  backIcon: widget.appService.navNum == 2
                    // ? Icons.qr_code
                    // : Icons.assignment_ind,
                    // : null,
                    icon: Icons.notifications_active,
                    userId: con.userId,
                    // iconTitle: translate('button.help'),
                    iconTitle: '',
                    onRightPressed: () => {
                      context.pushNamed(RouteNames.notification,
                          pathParameters: {'userId': con.userId!}),
                    },
                    // onQrScanPress: () => context.goNamed(RouteNames.manageTask),

                    // con.onSignOutPressed(context),
                    // context.pushNamed(RouteNames.qrCodeScan,
                    //     params: {'id': con.userId!})
                  ),
                  body: pages[widget.appService.navNum],
                  bottomNavigationBar: Container(
                    clipBehavior: Clip
                        .hardEdge, //or better look(and cost) using Clip.antiAlias,
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20),
                        ),
                        border: Border.all(
                            color: theme.colorScheme.tertiary, width: 2)),
                    child: NavigationBarTheme(
                        data: NavigationBarThemeData(
                          labelTextStyle: MaterialStatePropertyAll(
                            TextStyle(
                              fontSize: 14,
                              fontFamily: "Gilroy Bold",
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          indicatorColor: theme.colorScheme.onSecondary,
                        ),
                        child: NavigationBar(
                          height: 60,
                          backgroundColor: Colors.white,
                          labelBehavior: NavigationDestinationLabelBehavior
                              .onlyShowSelected,
                          animationDuration: const Duration(seconds: 1),
                          destinations: [
                            NavigationDestination(
                              icon: Icon(
                                Icons.fact_check,
                                color: theme.colorScheme.onTertiary,
                              ),
                              label: translate('app_bar.today_task'),
                              selectedIcon: Icon(
                                Icons.fact_check,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            NavigationDestination(
                              icon: Icon(
                                Icons.calendar_month,
                                color: theme.colorScheme.onTertiary,
                              ),
                              label: translate('app_bar.task_calendar'),
                              selectedIcon: Icon(
                                Icons.calendar_month,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            // NavigationDestination(
                            //   icon: Icon(
                            //     Icons.place,
                            //     color: theme.colorScheme.onTertiary,
                            //   ),
                            //   label: translate('app_bar.live_map'),
                            //   selectedIcon: Icon(
                            //     Icons.place,
                            //     color: theme.colorScheme.primary,
                            //   ),
                            // ),
                            NavigationDestination(
                              icon: Icon(
                                Icons.person_4,
                                color: theme.colorScheme.onTertiary,
                              ),
                              label: translate('app_bar.my_account'),
                              selectedIcon: Icon(
                                Icons.person_4,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          ],
                          onDestinationSelected: (int index) {
                            setState(() {
                              widget.appService.navNum = index;
                            });
                          },
                          selectedIndex: widget.appService.navNum,
                        )),
                  )
                  // ),
                  ),
            )
          : Container(),
    );
  }
}
