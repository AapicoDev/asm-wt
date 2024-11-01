import "package:asm_wt/app/alert/notification/notification_view.dart";
import "package:asm_wt/app/app_controller.dart";
import "package:asm_wt/app/app_service.dart";
import "package:asm_wt/app/authentication/login/login_view.dart";
import "package:asm_wt/app/authentication/register_step1/register_step1_view.dart";
import "package:asm_wt/app/authentication/register_step2/register_step2_view.dart";
import "package:asm_wt/app/my_account/account_setting/account_setting_view.dart";
import "package:asm_wt/app/my_account/qr_code/qr_code_scanner/qr_code_view.dart";
import "package:asm_wt/app/tasks/management/task/manage_task_view.dart";
import 'package:asm_wt/app/tasks/tasks_detail/tasks_detail_view.dart';
import "package:asm_wt/app/tasks/tasks_root_view.dart";
import "package:asm_wt/models/employee_model.dart";
import "package:asm_wt/models/tasks_model.dart";
import "package:asm_wt/router/router_name.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import 'package:camera/camera.dart';
import "package:upgrader/upgrader.dart";

class AppRouter {
  late final AppService appService;
  GoRouter get router => _goRouter;
  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  AppController _appController = AppController();

  List<CameraDescription> cameras = [];

  AppRouter(this.appService);

  CustomTransitionPage buildPageWithDefaultTransition<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          // FadeTransition(opacity: animation, child: child),
          SlideTransition(
              position: Tween<Offset>(begin: Offset(-1, 0), end: Offset.zero)
                  .animate(animation),
              child: child),
    );
  }

  late final GoRouter _goRouter = GoRouter(
    navigatorKey: _rootNavigatorKey,
    errorPageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
      context: context,
      state: state,
      child: Text(state.error.toString()),
    ),
    refreshListenable: appService,
    initialLocation: RouteNames.root,
    routes: <GoRoute>[
      GoRoute(
          name: RouteNames.root,
          path: "/",
          pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: UpgradeAlert(
                    upgrader: Upgrader(
                        debugDisplayAlways: false,
                        minAppVersion: _appController.appVersion),
                    child: LoginView(key: UniqueKey())),
              ),
          routes: [
            GoRoute(
              name: RouteNames.register,
              path: RouteNames.register,
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: RegisterStep1View(
                  key: UniqueKey(),
                ),
              ),
            ),
            GoRoute(
              name: RouteNames.register2,
              path:
                  "${RouteNames.register2}/:type/:verID/:isThaiBulkSms/:token",
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: RegisterStep2View(
                  type: state.pathParameters["type"],
                  verID: state.pathParameters["verID"],
                  token: state.pathParameters["token"],
                  isThaiBulkSms: state.pathParameters["isThaiBulkSms"] == 'true'
                      ? true
                      : false,
                  employeeModel: state.extra as EmployeeModel,
                  key: UniqueKey(),
                ),
              ),
            ),
          ]),
      GoRoute(
          name: RouteNames.todayTask,
          path: "/${RouteNames.todayTask}",
          pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: TasksRootView(
                  key: UniqueKey(),
                  appService: appService,
                ),
              ),
          routes: [
            // GoRoute(
            //   name: RouteNames.onBoardTask,
            //   path: "${RouteNames.onBoardTask}/:taskId",
            //   pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
            //     context: context,
            // state: state,
            //     child: OnBoardTaskView(
            //         taskModel: state.extra as TaskModel,
            //         key: UniqueKey(),
            //         taskId: state.params["taskId"]!),
            //   ),
            // ),
            GoRoute(
              name: RouteNames.tasksDetail,
              path: RouteNames.tasksDetail,
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: TasksDetailView(
                  taskModel: state.extra as TaskModel,
                  key: UniqueKey(),
                ),
              ),
            ),

            GoRoute(
              name: RouteNames.notification,
              path: "${RouteNames.notification}/:userId",
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: NotificationView(
                    key: UniqueKey(), userId: state.pathParameters["userId"]!),
              ),
            ),
          ]),
      GoRoute(
          name: RouteNames.taskCalendar,
          path: "/${RouteNames.todayTask}/${RouteNames.taskCalendar}",
          pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: TasksRootView(
                  appService: appService,
                  key: UniqueKey(),
                ),
              ),
          routes: [
            GoRoute(
              name: RouteNames.manageTask,
              path: RouteNames.manageTask,
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: ManageTaskView(
                  key: UniqueKey(),
                ),
              ),
            ),
          ]),
      GoRoute(
          name: RouteNames.myAccount,
          path:
              "/${RouteNames.todayTask}/${RouteNames.taskCalendar}/${RouteNames.myAccount}",
          pageBuilder: (context, state) => buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: TasksRootView(
                  appService: appService,
                  key: UniqueKey(),
                ),
              ),
          routes: [
            GoRoute(
              name: RouteNames.accountSetting,
              path: RouteNames.accountSetting,
              pageBuilder: (context, state) =>
                  buildPageWithDefaultTransition<void>(
                context: context,
                state: state,
                child: AccountSettingView(
                  key: UniqueKey(),
                  appService: appService,
                ),
              ),
            ),
            GoRoute(
              name: RouteNames.qrCodeScan,
              path: "${RouteNames.qrCodeScan}/:id",
              pageBuilder: (context, state) => MaterialPage<void>(
                key: state.pageKey,
                child: QrCodeView(
                  key: UniqueKey(),
                  id: state.pathParameters["id"]!,
                ),
              ),
            ),
          ])
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final taskLocation = state.namedLocation(RouteNames.todayTask);
      final loginLocation = state.namedLocation(RouteNames.root);

      final isLogedIn = appService.loginState;
      final isInitialized = appService.initialized;

      debugPrint("isLogedIn");
      // final isOnboarded = appService.onboarding;

      // final isGoingToLogin = state.subloc == loginLocation;
      // final isGoingToOnboard = state.subloc == taskLocation;

      // if (state.matchedLocation.startsWith('/${RouteNames.todayTask}')) {
      //   return null;
      // }
      if (state.matchedLocation.startsWith('/${RouteNames.todayTask}')) {
        return null;
      } else if (state.matchedLocation == '/${RouteNames.register}') {
        return null;
      } else if (state.matchedLocation.startsWith('/${RouteNames.register2}')) {
        return null;
      } else if (!isInitialized && isLogedIn) {
        return taskLocation;
      } else if (!isInitialized && !isLogedIn) {
        return loginLocation;
      }
      return null;
    },
  );
}
