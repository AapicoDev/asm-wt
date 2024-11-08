import 'dart:io';
import 'dart:math';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:asm_wt/app/tasks/task_manual/task_manual_view.dart';
import 'package:asm_wt/util/showExitConfirmationDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:ionicons/ionicons.dart';
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

  const TasksRootView({Key? key, required this.appService}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TasksRootViewState();
}

class _TasksRootViewState extends StateMVC<TasksRootView>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TasksRootController _controller;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _notificationStream;
  MyAccountController _myAccountController = MyAccountController();
  late PageController _pageController;
  late NotchBottomBarController _bottomBarController;

  final List<IconData> _iconList = [
    Ionicons.today_outline,
    Ionicons.calendar_outline,
    Ionicons.time_outline,
    Ionicons.person_outline,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _bottomBarController.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  _TasksRootViewState() : super(TasksRootController()) {
    _controller = controller as TasksRootController;
  }

  @override
  void initState() {
    super.initState();
    print("App init ${widget.appService.navNum}");
    _controller.getDriverId();
    _initializeNotificationStream();
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController(initialPage: widget.appService.navNum);
    _bottomBarController =
        NotchBottomBarController(index: widget.appService.navNum);
  }

  // Initialize notification stream to listen to employee data changes
  void _initializeNotificationStream() {
    _notificationStream = FirebaseFirestore.instance
        .collection(TableName.dbEmployeeTable)
        .where('employee_id', isEqualTo: _controller.userId)
        .snapshots();

    _notificationStream?.listen(_handleEmployeeUpdates);
  }

  // Handle employee data changes from Firestore
  Future<void> _handleEmployeeUpdates(
      QuerySnapshot<Map<String, dynamic>> snapshot) async {
    try {
      if (snapshot.docs.isEmpty) return;

      final deviceInfo = await _getDeviceInfo();

      for (var doc in snapshot.docs) {
        final employee = EmployeeModel.fromDocumentSnapshot(doc);
        await _validateEmployeeAndDevice(employee, deviceInfo);
      }
    } catch (e) {
      debugPrint('Error in notification stream: $e');
      showToastMessage(context, translate("error.something_went_wrong"),
          Theme.of(context).colorScheme.error);
    }
  }

  // Get device information (either iOS or Android)
  Future<String> _getDeviceInfo() async {
    if (Platform.isIOS) {
      final deviceInfo = await DeviceInfoPlugin().iosInfo;
      return "${deviceInfo.name}-v${deviceInfo.systemName}";
    } else if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      return deviceInfo.id;
    }
    throw PlatformException(code: 'UNSUPPORTED_PLATFORM');
  }

  // Validate if employee is activated and the device matches
  Future<void> _validateEmployeeAndDevice(
      EmployeeModel employee, String deviceId) async {
    final isTestAccount = employee.phoneNumber == '+66646666666' ||
        employee.phoneNumber == '+66647777777';

    if (!employee.isActivated!) {
      debugPrint("Account not activated");
      _handleAuthenticationFailure("authentication.please_register");
      return;
    }

    if (!isTestAccount && employee.deviceID != deviceId) {
      debugPrint("Device ID mismatch");
      _handleAuthenticationFailure("authentication.unrecognise_device");
    }
  }

  // Handle authentication failure (e.g., show toast and sign out)
  void _handleAuthenticationFailure(String messageKey) {
    showToastMessage(context, translate(messageKey),
        Theme.of(context).colorScheme.onSurface);
    _myAccountController.onSignOutPressed(context);
  }

  // Build the widget tree
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    LocalNotification.initialize();

    final pages = [
      TodayTaskView(userId: _controller.userId ?? ''),
      TaskCalendarView(userId: _controller.userId ?? ''),
      TaskManualView(userId: _controller.userId ?? ''),
      MyAccountView(userId: _controller.userId ?? ''),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        return ExitConfirmationHandler.onWillPop(context);
      },
      child: widget.appService.bioAuth
          ? UpgradeAlert(
              upgrader: Upgrader(
                debugDisplayAlways: false,
                minAppVersion: _controller.appController.appVersion,
              ),
              child: Scaffold(
                appBar: AppBarWidget(
                  color: theme.colorScheme.primary,
                  isDiscard: false,
                  type: StaticModelType.notification,
                  title: _getAppBarTitle(widget.appService.navNum),
                  leadingBack: false,
                  icon: Icons.notifications_active,
                  userId: _controller.userId,
                  onRightPressed: () {
                    context.pushNamed(RouteNames.notification,
                        pathParameters: {'userId': _controller.userId!});
                  },
                ),
                body: // pages[widget.appService.navNum],
                    PageView(
                  controller: _pageController,
                  onPageChanged: (value) {
                    setState(() {
                      widget.appService.navNum = value;
                    });
                  },
                  children:
                      List.generate(pages.length, (index) => pages[index]),
                ),
                bottomNavigationBar: _buildBottomNavigationBar(theme),
              ),
            )
          : Container(),
    );
  }

  // Get the app bar title based on the selected tab
  String _getAppBarTitle(int navNum) {
    switch (navNum) {
      case 0:
        return translate('app_bar.today_task');
      case 1:
        return translate('app_bar.task_calendar');
      case 2:
        return translate('app_bar.task_manual');
      case 3:
        return translate('app_bar.my_account');
      default:
        return '';
    }
  }

  // Build the bottom navigation bar
  Widget _buildBottomNavigationBar(ThemeData theme) {
    return AnimatedNotchBottomBar(
      /// Provide NotchBottomBarController
      notchBottomBarController: _bottomBarController,
      color: theme.colorScheme.primary,
      showLabel: true,
      textOverflow: TextOverflow.visible,
      maxLine: 1,
      shadowElevation: 10,
      kBottomRadius: 28.0,

      showBlurBottomBar: true,
      blurOpacity: 0.9,
      blurFilterX: 5.0,
      blurFilterY: 10.0,
      // notchShader: const SweepGradient(
      //   startAngle: 0,
      //   endAngle: pi / 2,
      //   colors: [Colors.red, Colors.green, Colors.orange],
      //   tileMode: TileMode.mirror,
      // ).createShader(Rect.fromCircle(center: Offset.zero, radius: 8.0)),
      notchColor: Colors.black87,

      /// restart app if you change removeMargins
      removeMargins: false,
      bottomBarWidth: 200,
      showShadow: true,
      durationInMilliSeconds: 300,

      // itemLabelStyle: const TextStyle(fontSize: 10),
      bottomBarItems: [
        ..._iconList
            .asMap()
            .map(
              (index, e) => MapEntry(
                index,
                BottomBarItem(
                  inActiveItem: Icon(
                    e,
                    color: Colors.yellow,
                  ),
                  activeItem: Icon(
                    e,
                    color: Colors.white,
                  ),
                  itemLabelWidget: Text(
                    _getAppBarTitle(index), // Use the index here
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
            .values
            .toList()
      ],
      onTap: (index) {
        debugPrint('current selected index $index');
        // widget.appService.navNum = index;

        _pageController.jumpToPage(index);
        // _pageController.animateToPage(index,
        //     duration: Duration(milliseconds: 100), curve: Curves.bounceIn);
      },
      kIconSize: 24.0,
    );
  }
}
