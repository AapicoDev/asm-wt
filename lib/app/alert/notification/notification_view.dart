import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/app/alert/notification/notification_controller.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/notification_model.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:asm_wt/widget/notification_card_widget.dart';

class NotificationView extends StatefulWidget {
  final String userId;
  const NotificationView({Key? key, required this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotificationViewState();
}

class _NotificationViewState extends StateMVC<NotificationView> {
  late NotificationController con;

  _NotificationViewState() : super(NotificationController()) {
    con = controller as NotificationController;
  }

  @override
  void initState() {
    setState(() {
      con.userId = widget.userId;
    });
    super.initState();
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
        // iconTitle: translate('button.help'),
        iconTitle: '',
        onRightPressed: () => showActionGenFunc(
            context, translate('text_header.help'), translate('contents.help')),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            left: StaticDataConfig.app_padding - 15,
            right: StaticDataConfig.app_padding - 15),
        child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.maxScrollExtent ==
                  scrollInfo.metrics.pixels) {
                con.requestNextPage();
              }
              return true;
            },
            child: StreamBuilder<List<DocumentSnapshot>>(
              stream: con.streamController.stream,
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    {
                      if (snapshot.data?.isEmpty ?? true) {
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
                                      TextStyle(
                                          color: theme.colorScheme.onTertiary)),
                                ),
                              ]),
                        );
                      }
                      return Container();
                    }

                  default:
                    // log("Items: " + snapshot.data.length.toString());
                    return ListView.builder(
                        // separatorBuilder: (context, index) => Divider(
                        //       color: theme.colorScheme.onTertiary,
                        //     ),
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          final document = snapshot.data?[index];
                          var item =
                              NotificationModel.fromDocumentSnapshot(document!);

                          //write maintenance compo hear;
                          return NotificationCardWidget(
                            notificationModel: item,
                            onPressed: () =>
                                {con.onNotificationItemPress(context, item)},
                          );
                        });
                }
              },
            )),
      ),
    );
  }
}
