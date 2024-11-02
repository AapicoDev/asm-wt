import 'package:asm_wt/app/alert/notification/notification_controller.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/notification_model.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/app_bar_widget.dart';
import 'package:asm_wt/widget/notification_card_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class NotificationView extends StatefulWidget {
  final String userId;
  const NotificationView({Key? key, required this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotificationViewState();
}

class _NotificationViewState extends StateMVC<NotificationView> {
  late NotificationController con;
  List<DocumentSnapshot> notifications = [];
  bool isLoading = true;

  _NotificationViewState() : super(NotificationController()) {
    con = controller as NotificationController;
  }

  @override
  void initState() {
    super.initState();
    con.userId = widget.userId;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final data = await con.getNotifications();
    setState(() {
      notifications = data;
      isLoading = false;
    });
  }

  Future<void> _loadMoreData() async {
    if (!con.isRequesting && !con.isFinished) {
      final newData = await con.loadMoreNotifications();
      setState(() {
        notifications = newData;
      });
    }
  }

  Future<void> _onRefresh() async {
    await con.refreshNotifications();
    final data = await con.getNotifications();
    setState(() {
      notifications = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarWidget(
        color: theme.colorScheme.primary,
        isDiscard: false,
        title: translate('app_bar.notifications'),
        type: StaticModelType.manu,
        leadingBack: true,
        icon: Icons.help,
        backIcon: Icons.arrow_back,
        iconTitle: '',
        onRightPressed: () => showActionGenFunc(
            context, translate('text_header.help'), translate('contents.help')),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: StaticDataConfig.app_padding - 15,
          right: StaticDataConfig.app_padding - 15,
        ),
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!con.isRequesting &&
                  !con.isFinished &&
                  scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent) {
                _loadMoreData();
              }
              return true;
            },
            child: _buildNotificationList(theme, width),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(ThemeData theme, double width) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (notifications.isEmpty) {
      return Container(
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
              translate('text_header.empty_data'),
              style: theme.textTheme.headlineSmall?.merge(
                TextStyle(color: theme.colorScheme.onTertiary),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: notifications.length + (con.isFinished ? 0 : 1),
      itemBuilder: (BuildContext context, int index) {
        if (index == notifications.length) {
          return con.isRequesting
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : Container();
        }

        final document = notifications[index];
        var item = NotificationModel.fromDocumentSnapshot(document);

        return NotificationCardWidget(
          notificationModel: item,
          onPressed: () => con.onNotificationItemPress(context, item),
        );
      },
    );
  }
}
