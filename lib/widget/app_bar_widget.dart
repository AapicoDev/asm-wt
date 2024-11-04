import 'package:asm_wt/router/router_name.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:flutter/material.dart';
import 'package:asm_wt/service/notification_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? icon;
  IconData? backIcon;
  final String? iconTitle;
  final String type;
  final VoidCallback? onRightPressed;
  final VoidCallback? onBackPressed;
  final VoidCallback? onQrScanPress;
  final String? userId;
  final bool leadingBack;
  final bool isDiscard;
  Color? color;

  AppBarWidget(
      {super.key,
      required this.title,
      this.icon,
      this.backIcon,
      this.onRightPressed,
      this.onQrScanPress,
      this.onBackPressed,
      required this.isDiscard,
      required this.leadingBack,
      this.iconTitle,
      required this.type,
      this.userId,
      this.color});

  Size get preferredSize => Size.fromHeight(60.0);

  final NotificationService _notificationService = NotificationService();
  final SharedPreferences prefs = GetIt.instance<SharedPreferences>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: color,
      title: Text(title,
          style: theme.textTheme.headlineLarge
              ?.merge(TextStyle(color: theme.colorScheme.onPrimary))),
      elevation: 0,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft:
                  Radius.circular(StaticDataConfig.app_bar_border_radius),
              bottomRight:
                  Radius.circular(StaticDataConfig.app_bar_border_radius))),
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: leadingBack
          ? IconButton(
              onPressed: onQrScanPress ??
                  () => isDiscard
                      ? showActionDiscardFunc(context)
                      : Navigator.pop(context),
              icon: Icon(
                backIcon,
                color: onQrScanPress != null
                    ? theme.colorScheme.onSecondary
                    : theme.colorScheme.onPrimary,
              ))
          : onQrScanPress != null
              ? IconButton(
                  onPressed: () {
                    context.pushNamed(RouteNames.qrCodeScan, pathParameters: {
                      'id': prefs.getString("userId") ?? ''
                    });
                  },
                  icon: Icon(
                    backIcon,
                    color: theme.colorScheme.onPrimary,
                  ))
              : SizedBox.shrink(),
      // IconButton(
      //     onPressed: onQrScanPress,
      //     icon: const Icon(Icons.qr_code_scanner)),
      // : Padding(
      //     padding: const EdgeInsets.all(5.0),
      //     child: Image.asset('lib/assets/images/aapico-logo.png'),
      //   ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: GestureDetector(
            onTap: onRightPressed,
            child: Stack(
              children: <Widget>[
                IconButton(
                    icon: Icon(icon),
                    color: theme.colorScheme.onPrimary,
                    onPressed: onRightPressed),
                type == StaticModelType.notification
                    ? StreamBuilder<QuerySnapshot>(
                        stream: _notificationService
                            .getUnseenItemsSnapshotByDriverId(userId!),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Container();
                          }

                          final List<DocumentSnapshot> documents =
                              snapshot.data!.docs;

                          return Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                '${documents.length}',
                                style: theme.textTheme.headlineSmall?.merge(
                                    const TextStyle(color: Colors.white)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        })
                    : type == StaticModelType.translate
                        ? Positioned(
                            left: 13,
                            bottom: -2,
                            child: Container(
                              child: iconTitle != ''
                                  ? Text(
                                      iconTitle!,
                                      style: theme.textTheme.bodySmall?.merge(
                                          TextStyle(
                                              color:
                                                  theme.colorScheme.onPrimary)),
                                    )
                                  : null,
                            ),
                          )
                        : Container()
              ],
            ),
          ),
        ),
      ],
    );
  }
}
