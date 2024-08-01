import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:flutter/material.dart';
import 'package:asm_wt/models/tasks_model.dart';
import 'package:asm_wt/router/router_name.dart';
import 'package:asm_wt/service/task_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/loading_overlay_widget.dart';
import 'package:asm_wt/widget/network_error_widget.dart';
import 'package:asm_wt/widget/task_widget.dart';

class TaskDismissWidget extends StatefulWidget {
  final TaskModel taskModel;
  final DateTime now;
  final Future<VoidCallback>? onConfirmPressed;
  TaskDismissWidget(
      {Key? key,
      required this.taskModel,
      required this.now,
      this.onConfirmPressed});

  @override
  _TaskDismissWidgetState createState() => _TaskDismissWidgetState();
}

class _TaskDismissWidgetState extends State<TaskDismissWidget> {
  bool dismiss = false;
  List<ConnectivityResult>? connectivityResult;
  late StreamSubscription subscription;
  TasksService tasksService = TasksService();

  @override
  void initState() {
    super.initState();
    initConnectivity();
    getConnectivity();
  }

  Future<void> initConnectivity() async {
    late List<ConnectivityResult> results;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      results = await Connectivity().checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status : $e');
      return null;
    }
    connectivityResult = results;
  }

  Future<void> getConnectivity() async =>
      subscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> result) async {
          if (connectivityResult != ConnectivityResult.none) {}
          setState(() {
            connectivityResult = result;
          });
        },
      );

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Widget itemDeleteDialogue(BuildContext context, String taskId) {
    final theme = Theme.of(context);
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(StaticDataConfig.border_radius)),
      contentTextStyle: theme.textTheme.bodyMedium,
      titlePadding: const EdgeInsets.all(0),
      title: Container(
        alignment: Alignment.center,
        color: theme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.only(
              top: StaticDataConfig.app_padding,
              bottom: StaticDataConfig.app_padding),
          child: Text(
            translate("task_checkIn.delete_task_title"),
            style: theme.textTheme.headlineLarge
                ?.merge(TextStyle(color: theme.colorScheme.onSecondary)),
          ),
        ),
      ),
      content: Text.rich(
        TextSpan(style: theme.textTheme.bodyMedium, children: [
          TextSpan(
              text: translate("task_checkIn.delete_task_content"),
              style: theme.textTheme.bodyMedium),
          TextSpan(
              text: "${widget.taskModel.taskId}",
              style: theme.textTheme.headlineMedium),
        ]),
      ),
      actions: [
        TextButton(
            onPressed: () {
              dismiss = false;
              Navigator.pop(context);
            },
            child: Text(translate('button.cancel'),
                style: theme.textTheme.headlineSmall
                    ?.merge(TextStyle(color: theme.colorScheme.onTertiary)))),
        TextButton(
          onPressed: () async => {
            dismiss = true,
            LoadingOverlay.of(context).show(),
            await tasksService
                .deleteTaskNotedById(taskId)
                .then((res) => {
                      if (res.status == "S")
                        {
                          showToastMessage(context, res.message,
                              Theme.of(context).colorScheme.onBackground),
                          Navigator.of(context).pop(),
                        }
                    })
                .whenComplete(
                  () => LoadingOverlay.of(context).hide(),
                )
          },
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(theme.colorScheme.onBackground)),
          child: Text(
            translate('button.confirm'),
            style: theme.textTheme.headlineSmall
                ?.merge(TextStyle(color: Colors.white)),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dismissible(
        background: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(StaticDataConfig.border_radius),
              color: theme.colorScheme.onBackground,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              SizedBox(
                width: 20,
              ),
              const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              Text(
                translate("button.delete"),
                style: theme.textTheme.headlineSmall
                    ?.merge(TextStyle(color: Colors.white)),
              ),
            ]),
          ),
        ),
        secondaryBackground: Padding(
          padding: const EdgeInsets.all(5),
          child: Container(
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(StaticDataConfig.border_radius),
              color: theme.colorScheme.background,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              Text(
                translate("button.edit"),
                style: theme.textTheme.headlineSmall
                    ?.merge(TextStyle(color: Colors.white)),
              ),
              SizedBox(
                width: 20,
              )
            ]),
          ),
        ),
        key: Key(widget.taskModel.taskId.toString()),
        // Provide a function that tells the app
        // what to do after an item has been swiped away.
        onDismissed: (direction) {
          if (direction == DismissDirection.startToEnd) {
            print("Item deleted");
            //your code to delete item from database or local storage
          } else if (direction == DismissDirection.endToStart) {
            print("item archived");
            //your code to move item to archive
          }
        },
        dismissThresholds: {
          DismissDirection.startToEnd: 0.5,
          DismissDirection.endToStart: 0.1
        },
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            if (connectivityResult == ConnectivityResult.none) {
              await showDialog(
                context: context,
                builder: (_) => NetworkErrorDialog(
                  onPressed: Navigator.of(context).pop,
                ),
              );
            } else {
              await showDialog(
                  context: context,
                  builder: (context) {
                    return itemDeleteDialogue(
                        context, widget.taskModel.taskId ?? '');
                  });
            }

            return dismiss;
          } else if (direction == DismissDirection.endToStart) {
            showToastMessage(
                context,
                translate("message.dont_permit_to_delete"),
                theme.colorScheme.onBackground);
          }
          return null;
        },
        child: TaskCardWidget(
          now: widget.now,
          taskModel: widget.taskModel,
          onPressed: () {
            try {
              if (widget.taskModel.isDisable ?? false) {
              } else {
                context.pushNamed(RouteNames.tasksDetail,
                    extra: widget.taskModel);
              }
            } catch (e) {
              print(e);
            }
          },
          title: widget.taskModel.name ?? '',
          subTitle: DateTime.fromMicrosecondsSinceEpoch(
              widget.taskModel.start_date!.microsecondsSinceEpoch),
        ));
  }
}


// TaskDismissWidget(
//         enable: true,
//         title: 'Sign In',
//         onPressed: () => {},
//       ),
