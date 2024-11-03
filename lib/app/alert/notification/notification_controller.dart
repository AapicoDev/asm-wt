import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/router/router_name.dart';
import 'package:asm_wt/service/base_service.dart';
import 'package:asm_wt/service/notification_service.dart';
import 'package:asm_wt/service/task_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:asm_wt/widget/loading_overlay_widget.dart';

class NotificationController extends ControllerMVC {
  late final AppStateMVC appState;

  factory NotificationController([StateMVC? state]) =>
      _this ??= NotificationController._(state);
  NotificationController._(StateMVC? state) : super(state);
  static NotificationController? _this;

  final TasksService _tasksService = TasksService();
  final NotificationService _notificationService = NotificationService();

  List<DocumentSnapshot> _notifications = [];
  bool _isRequesting = false;
  bool _isFinish = false;
  String? userId;

  final ScrollController scrollController =
      ScrollController(initialScrollOffset: 0);

  @override
  void initState() {
    _notifications = [];
    _isRequesting = false;
    _isFinish = false;
    super.initState();
  }

  late LocalizationDelegate localizationDelegate =
      LocalizedApp.of(appState.context).delegate;

  String timeUntil(DateTime date) {
    return timeago.format(date,
        locale: localizationDelegate.currentLocale.languageCode,
        allowFromNow: true);
  }

  Future<List<DocumentSnapshot>> getNotifications() async {
    if (_notifications.isEmpty) {
      return await _getInitialNotifications();
    } else {
      return _notifications;
    }
  }

  Future<List<DocumentSnapshot>> _getInitialNotifications() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(TableName.dbNotificationsTable)
          .where('to_id', isEqualTo: userId)
          .orderBy('created_date', descending: true)
          .limit(10)
          .get();

      _notifications = querySnapshot.docs;
      return _notifications;
    } catch (e) {
      debugPrint('Error getting initial notifications: $e');
      return [];
    }
  }

  Future<List<DocumentSnapshot>> loadMoreNotifications() async {
    if (!_isRequesting && !_isFinish && _notifications.isNotEmpty) {
      try {
        setState(() {
          _isRequesting = true;
        });

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(TableName.dbNotificationsTable)
            .orderBy('created_date', descending: true)
            .where('to_id', isEqualTo: userId)
            .startAfterDocument(_notifications[_notifications.length - 1])
            .limit(5)
            .get();

        int oldSize = _notifications.length;
        _notifications.addAll(querySnapshot.docs);
        int newSize = _notifications.length;

        if (oldSize == newSize) {
          setState(() {
            _isFinish = true;
          });
        }

        setState(() {
          _isRequesting = false;
        });

        return _notifications;
      } catch (e) {
        debugPrint('Error loading more notifications: $e');
        setState(() {
          _isRequesting = false;
        });
        return _notifications;
      }
    }
    return _notifications;
  }

  Future<void> refreshNotifications() async {
    _notifications = [];
    _isFinish = false;
    _isRequesting = false;
    await _getInitialNotifications();
    setState(() {});
  }

  Future<void> onNotificationItemPress(BuildContext context, item) async {
    if (!item.view) {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['view'] = true;
      await _notificationService.updateNotificationById(
          item.notificationId, data);
    }

    if (item.notifyCode == StatusType.dayoff ||
        item.notifyCode == StatusType.absence) {
      // ignore: use_build_context_synchronously
      showActionGenFunc(context, translate('text_header.cannot_view'),
          translate("contents.cannot_view_msg"));
    } else {
      if (item.notifyCode == StatusType.scheduled ||
          item.notifyCode == StatusType.rescheduled ||
          item.notifyCode == StatusType.ot) {
        LoadingOverlay.of(context).show();
        await _tasksService.getTaskByTaskId(item.titleId).then(
          (res) {
            if (res?.type != StatusType.delete) {
              context.pushNamed(RouteNames.tasksDetail, extra: res);
            } else {
              showToastMessage(context, translate("message.task_delete"),
                  Theme.of(context).colorScheme.onBackground);
            }
            LoadingOverlay.of(context).hide();
          },
        );
      }
    }
  }

  bool get isRequesting => _isRequesting;
  bool get isFinished => _isFinish;
}
