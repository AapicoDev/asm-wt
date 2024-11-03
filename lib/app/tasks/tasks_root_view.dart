import 'dart:io';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:asm_wt/app/tasks/task_manual/task_manual_view.dart';
import 'package:asm_wt/util/showExitConfirmationDialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:ionicons/ionicons.dart';
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

class _TasksRootView extends StateMVC<TasksRootView>
    with TickerProviderStateMixin {
  late TasksRootController con;
  SharedPreferences prefs = GetIt.instance<SharedPreferences>();
  ConnectivityResult? connectivityResult;
  Stream<QuerySnapshot<Map<String, dynamic>>>? notificationStream;
  MyAccountController myAccountController = MyAccountController();
  // late final FirebaseMessaging _messaging;
  // PushNotification? _notificationInfo;

  final autoSizeGroup = AutoSizeGroup();
  late AnimationController _borderRadiusAnimationController;
  late Animation<double> fabAnimation;
  late Animation<double> borderRadiusAnimation;
  late CurvedAnimation borderRadiusCurve;
  late AnimationController _hideBottomBarAnimationController;

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

    _borderRadiusAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    borderRadiusCurve = CurvedAnimation(
      parent: _borderRadiusAnimationController,
      curve: Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );

    borderRadiusAnimation = Tween<double>(begin: 0, end: 1).animate(
      borderRadiusCurve,
    );

    _hideBottomBarAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    Future.delayed(
      Duration(seconds: 1),
      () => _borderRadiusAnimationController.forward(),
    );
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
          if ((employee.deviceID != (androidInfo?.id ?? identifier)) &&
              employee.phoneNumber != '+66646666666' &&
              employee.phoneNumber != '+66647777777') {
            debugPrint("signout 1");
            showToastMessage(
                context,
                translate("authentication.unrecognise_device"),
                Theme.of(context).colorScheme.onSurface);
            myAccountController.onSignOutPressed(context);
          }
        } else {
          debugPrint("signout 2");
          showToastMessage(context, translate("authentication.please_register"),
              Theme.of(context).colorScheme.onSurface);
          myAccountController.onSignOutPressed(context);
        }
      }
    });
  }

  @override
  dispose() {
    _borderRadiusAnimationController.dispose();
    _hideBottomBarAnimationController.dispose(); // you need this
    super.dispose();
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
      TaskManualView(
        userId: con.userId ?? '',
      ),
      // const LiveMapView(),
      MyAccountView(
        userId: con.userId ?? '',
      )
    ];
    final theme = Theme.of(context);
    LocalNotification.initialize();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        debugPrint("back button");
        return ExitConfirmationHandler.onWillPop(context);
      },
      child: widget.appService.bioAuth
          ? UpgradeAlert(
              upgrader: Upgrader(
                debugDisplayAlways: false,
                minAppVersion: con.appController.appVersion,
              ),
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
                              ? translate('app_bar.task_manual')
                              : widget.appService.navNum == 3
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
                bottomNavigationBar: AnimatedBottomNavigationBar.builder(
                  itemCount: iconList.length,
                  tabBuilder: (int index, bool isActive) {
                    final color = isActive ? Colors.yellow : Colors.white;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconList[index],
                          size: 28,
                          color: color,
                        ),
                        // const SizedBox(height: 4),
                        index == widget.appService.navNum
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: AutoSizeText(
                                  iconName[index],
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: color,
                                    fontFamily: "Kanit Light",
                                  ),
                                  group: autoSizeGroup,
                                ),
                              )
                            : Container()
                      ],
                    );
                  },
                  backgroundColor: theme.colorScheme.primary,
                  activeIndex: widget.appService.navNum,
                  splashColor: Colors.yellow,
                  // notchAndCornersAnimation: borderRadiusAnimation,
                  splashSpeedInMilliseconds: 300,
                  notchSmoothness: NotchSmoothness.defaultEdge,
                  gapLocation: GapLocation.none,
                  leftCornerRadius: 32,
                  rightCornerRadius: 32,
                  onTap: (index) =>
                      setState(() => widget.appService.navNum = index),
                  hideAnimationController: _hideBottomBarAnimationController,
                  shadow: BoxShadow(
                    offset: Offset(0, 1),
                    blurRadius: 12,
                    spreadRadius: 0.5,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            )
          : Container(),
    );
  }

  final iconList = <IconData>[
    Ionicons.today_outline,
    Ionicons.calendar_outline,
    Ionicons.time_outline,
    Ionicons.person_outline,
  ];

  final iconName = [
    translate("app_bar.today_task"),
    translate("app_bar.my_task"),
    translate("app_bar.task_manual"),
    translate("app_bar.my_account"),
  ];

  bool onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.metrics.axis == Axis.vertical) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _hideBottomBarAnimationController.reverse();
          break;
        case ScrollDirection.reverse:
          _hideBottomBarAnimationController.forward();
          break;
        case ScrollDirection.idle:
          break;
      }
    }
    return false;
  }
}
