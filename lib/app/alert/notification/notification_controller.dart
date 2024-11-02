import 'dart:async';

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

  TasksService _tasksService = TasksService();
  NotificationService _notificationService = NotificationService();
  StreamController<List<DocumentSnapshot>> streamController =
      StreamController<List<DocumentSnapshot>>.broadcast();
  List<DocumentSnapshot> _notifications = [];
  bool _isRequesting = false;
  bool _isFinish = false;
  String? userId;

  final ScrollController scrollController =
      ScrollController(initialScrollOffset: 0);

  @override
  void dispose() {
    // streamController.close();
    super.dispose();
  }

  @override
  void initState() {
    _notifications = [];
    FirebaseFirestore.instance
        .collection(TableName.dbNotificationsTable)
        .snapshots()
        .listen((data) => onChangeData(data.docChanges));

    _isRequesting = false;
    _isFinish = false;

    requestNextPage();

    super.initState();
  }

  late LocalizationDelegate localizationDelegate =
      LocalizedApp.of(appState.context).delegate;

  String timeUntil(DateTime date) {
    return timeago.format(date,
        locale: localizationDelegate.currentLocale.languageCode,
        allowFromNow: true);
  }

  void onChangeData(List<DocumentChange> documentChanges) {
    bool isChange = false;

    documentChanges.forEach((notificationChange) {
      if (notificationChange.type == DocumentChangeType.removed) {
        _notifications.removeWhere((product) {
          return notificationChange.doc.id == product.id;
        });
        isChange = true;
      } else {
        if (notificationChange.type == DocumentChangeType.modified) {
          int indexWhere = _notifications.indexWhere((product) {
            return notificationChange.doc.id == product.id;
          });

          if (indexWhere >= 0) {
            _notifications[indexWhere] = notificationChange.doc;
          }
          isChange = true;
        }
      }
    });

    if (isChange) {
      streamController.add(_notifications);
    }
  }

  Future<void> requestNextPage() async {
    if (!_isRequesting && !_isFinish) {
      QuerySnapshot querySnapshot;
      setState(() {
        _isRequesting = true;
      });
      if (_notifications.isEmpty) {
        querySnapshot = await FirebaseFirestore.instance
            .collection(TableName.dbNotificationsTable)
            .where('to_id', isEqualTo: userId)
            .orderBy('created_date', descending: true)
            .limit(10)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection(TableName.dbNotificationsTable)
            .orderBy('created_date', descending: true)
            .where('to_id', isEqualTo: userId)
            .startAfterDocument(_notifications[_notifications.length - 1])
            .limit(5)
            .get();
      }

      // if (querySnapshot != null) {
      // _notifications = [];
      int oldSize = _notifications.length;
      _notifications.addAll(querySnapshot.docs);
      int newSize = _notifications.length;

      if (oldSize != newSize) {
        streamController.add(_notifications);
      } else {
        setState(() {
          _isFinish = true;
        });
      }
      // }
      setState(() {
        _isRequesting = false;
      });
    }
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
}
