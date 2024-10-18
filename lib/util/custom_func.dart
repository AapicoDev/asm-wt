import 'package:fluttertoast/fluttertoast.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/widget/alert_dialog_widget.dart';
import 'package:asm_wt/widget/button_outline_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:go_router/go_router.dart';
import 'dart:collection';

class StaticModelType {
  static const String translate = 'translate';
  static const String navigate = 'navigate';

  static const String discard = 'discard';
  static const String alert = 'alert';
  static const String confirm = 'confirm';
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String reject = 'reject';
  static const String notification = 'notification';
  static const String manu = 'manu';
}

class StatusType {
  static const String pending = 'pending';
  static const String approved = 'approved';
  static const String reject = 'reject';
  static const String task = 'task';
  static const String scheduled = 'scheduled';
  static const String dayoff = 'dayoff';
  static const String rescheduled = 'rescheduled';
  static const String absence = 'absence';
  static const String ot = 'ot';
  static const String maintenance = 'maintenance';
  static const String delete = 'deleted';
  static const String update = 'updated';
  static const String created = 'created';
}

class TaskStatus {
  static const String New = 'new';
  static const String Confirm = 'confirm';
  static const String Start = 'start';
  static const String Done = 'done';
  static const String Delete = 'deleted';
  static const String Skip = 'skip';
  static const String Request = NewFeedsType.Request;
  static const String Assign = 'Assign';
}

class ClockStatus {
  static const String Late = 'late';
  static const String NotYetStart = 'not yet start';
  static const String Same = 'same';
  static const String Early = 'early';
}

class NewFeedsType {
  static const String Request = 'Request';
  static const String Accept = 'Accept';
  static const String Task = 'Task';
  static const String ClockInOut = 'ClockInOut';
  static const String Account = 'Account';
}

class UserStatus {
  static const String Available = 'Available';
  static const String UnAvalibale = 'Unavailable';
  static const String Offline = 'Offline';
  static const List<String> userStatusList = [Available, UnAvalibale, Offline];
}

class StaticTasksForm {
  static const String camera = 'camera';
  static const String noted = 'noted';
  static const String signature = 'signature';
}

class ClockInOutEvent {
  static const String ClockIn = 'Clock-In';
  static const String ClockOut = 'Clock-Out';
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

bool isChecked = false;
Map ticketlist = {};

void showToastMessage(BuildContext context, String message, Color color) {
  Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.BOTTOM_RIGHT,
      timeInSecForIosWeb: 1,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 14.0);
}

continuebottomSheet(BuildContext context) {
  var height = MediaQuery.of(context).size.height;
  var width = MediaQuery.of(context).size.width;
  var theme = Theme.of(context);

  return showModalBottomSheet<dynamic>(
    backgroundColor: theme.colorScheme.tertiary,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
    context: context,
    builder: (BuildContext bc) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return SizedBox(
          height: height * 0.92,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: height / 50),
              Container(
                  decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  height: height / 80,
                  width: width / 7),
              SizedBox(height: height / 70),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                            "A Terms and Conditions agreement acts as a legal contract between you (the company) and the user. It's where you maintain your rights to exclude users from your app in the event that they abuse your website/app, set out the rules for using your service and note other important details and disclaimers. Having a Terms and Conditions agreement is completely optional. No laws require you to have one. Not even the super-strict and wide-reaching General Data Protection Regulation (GDPR). Your Terms and Conditions agreement will be uniquely yours. While some clauses are standard and commonly seen in pretty much every Terms and Conditions agreement, it's up to you to set the rules and guidelines that the user must agree to. Terms and Conditions agreements are also known as Terms of Service or Terms of Use agreements. These terms are interchangeable, practically speaking. More rarely, it may be called something like an End User Services Agreement (EUSA)."),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: height / 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      checkColor: Colors.white,
                      fillColor: MaterialStateProperty.resolveWith(
                          (states) => theme.colorScheme.primary),
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                    Text(
                      "I Confirm that I am healty",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Kanit Normal',
                          color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: height / 200),
              GestureDetector(
                onTap: () {},
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        color: theme.colorScheme.primary),
                    height: height / 15,
                    width: width / 1.5,
                    child: Row(
                      children: [
                        SizedBox(width: width / 5),
                        Text("CONTINUE",
                            style: TextStyle(
                                fontFamily: 'Kanit Medium',
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        SizedBox(width: width / 7),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Image.asset("image/arrow.png"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: height / 200),
            ],
          ),
        );
      });
    },
  );
}

void modelTextContrainerFunc(BuildContext context, String title,
    String subTitle, Widget? contentsWidget) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  final theme = Theme.of(context);

  showModalBottomSheet<String>(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(StaticDataConfig.app_padding - 5),
          child: SizedBox(
            height: height / 1.4,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onTertiary,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    height: height / 80,
                    width: width / 7),
                Container(
                  // alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: Text(title, style: theme.textTheme.headlineLarge),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding:
                        const EdgeInsets.all(StaticDataConfig.app_padding - 10),
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          translate(subTitle),
                          style: theme.textTheme.bodyMedium,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Expanded(
                  flex: 6,
                  child: contentsWidget ?? SizedBox.shrink(),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      });
}

void modelBottomSheetFunc(
    BuildContext context,
    String modelType,
    List<String>? navViewName,
    List<String>? navParamVal,
    String modelHeader,
    String titleTop,
    String titleBottom,
    String? imgTop,
    String? imgBottom,
    IconData? iconTop,
    IconData? iconBottom) {
  double height = MediaQuery.of(context).size.height;
  double width = MediaQuery.of(context).size.width;
  final theme = Theme.of(context);

  showModalBottomSheet<String>(
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0))),
      builder: (context) {
        return SizedBox(
          height: height * 0.25,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  height: height / 80,
                  width: width / 7),
              SizedBox(height: height / 70),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: Text(modelHeader, style: theme.textTheme.headlineLarge),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: StaticDataConfig.app_padding),
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              switch (modelType) {
                                //swtich to test model type of image or icon;
                                case StaticModelType.navigate:
                                  {
                                    return Column(
                                      children: [
                                        ButtonOutlineWidget(
                                            title: titleTop,
                                            imagePath: imgTop,
                                            icon: iconTop,
                                            onPressed: () {
                                              context.pushNamed(navViewName![0],
                                                  pathParameters: {
                                                    'id': navParamVal![0]
                                                  });
                                            }),
                                        ButtonOutlineWidget(
                                            title: titleBottom,
                                            icon: iconBottom,
                                            imagePath: imgBottom,
                                            onPressed: () {
                                              context.pushNamed(navViewName![1],
                                                  pathParameters: {
                                                    'id': navParamVal![1]
                                                  });
                                            }),
                                      ],
                                    );
                                  }

                                case StaticModelType.translate:
                                  {
                                    return Column(
                                      children: [
                                        ButtonOutlineWidget(
                                            title: titleTop,
                                            imagePath: imgTop,
                                            icon: iconTop,
                                            onPressed: () {
                                              Navigator.pop(context, 'en');
                                            }),
                                        ButtonOutlineWidget(
                                            title: titleBottom,
                                            icon: iconBottom,
                                            imagePath: imgBottom,
                                            onPressed: () {
                                              Navigator.pop(context, 'th');
                                            }),
                                      ],
                                    );
                                  }
                                default:
                                  {
                                    return const SizedBox.shrink();
                                  }
                              }
                            })),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).then((String? value) {
    if (value != null) {
      changeLocale(context, value);
    }
  });
}

void showActionDiscardFunc(context) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialogWidget(
        title: translate('contents.msg_discard'),
        content: translate('contents.msg_discard_content'),
        type: StaticModelType.discard,
      );
    },
  );
}

void showActionConfirmFunc(
    context, title, content, Color color, VoidCallback? onPressed) {
  var theme = Theme.of(context);
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(StaticDataConfig.border_radius)),
        contentTextStyle: theme.textTheme.bodyMedium,
        titlePadding: const EdgeInsets.all(0),
        title: Container(
          color: color,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(
                top: StaticDataConfig.app_padding,
                bottom: StaticDataConfig.app_padding),
            child: Text(title,
                style: theme.textTheme.headlineLarge
                    ?.merge(TextStyle(color: theme.colorScheme.onSecondary))),
          ),
        ),
        content: Text(content),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(translate('button.cancel')),
              ),
              TextButton(
                onPressed: onPressed,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(color)),
                child: Text(translate('button.confirm'),
                    style: Theme.of(context).textTheme.headlineSmall?.merge(
                        TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary))),
              ),
            ],
          )
        ],
      );
    },
  );
}

void showActionGenFunc(context, title, content) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialogWidget(
        title: title,
        content: content,
        type: StaticModelType.alert,
      );
    },
  );
}

/// Example event class.
// class Event {
//   final String title;

//   const Event(this.title);

//   @override
//   String toString() => title;
// }

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
// final kEvents = LinkedHashMap<DateTime, List<Event>>(
//   equals: isSameDay,
//   hashCode: getHashCode,
// )..addAll(_kEventSource);

// final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
//     key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
//     value: (item) => List.generate(
//         item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
//   ..addAll({
//     kToday: [
//       Event('Today\'s Event 1'),
//       Event('Today\'s Event 2'),
//     ],
//   });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
