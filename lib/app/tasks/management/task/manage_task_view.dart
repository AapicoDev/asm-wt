import 'package:asm_wt/app/tasks/management/task/manage_task_controller.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/manage_tasks_model.dart';
import 'package:asm_wt/provider/nav_helper.dart';
import 'package:asm_wt/service/RESTAPI/task_management_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/app_bar_widget.dart';
import 'package:asm_wt/widget/button_outline_widget.dart';
import 'package:asm_wt/widget/datatable_2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';

class ManageTaskView extends StatefulWidget {
  ManageTaskView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ManageTaskViewState();
}

class _ManageTaskViewState extends StateMVC<ManageTaskView> {
  late ManageTaskController con;

  _ManageTaskViewState() : super(ManageTaskController()) {
    con = controller as ManageTaskController;
  }

  @override
  void initState() {
    super.initState();
    con.taskManagementService = context.read<TaskManagementService>();
  }

  Widget _userClockBadge(bool isClockIn, int index) {
    var theme = Theme.of(context);

    ManageTaskModel? manageTaskModel =
        con.taskManagementService?.manageTaskModelList?[index];

    Color clockOutColor = theme.colorScheme.primary;
    Color clockInColor = theme.colorScheme.primary;

    if (manageTaskModel?.status != TaskStatus.Done &&
        manageTaskModel?.driverStartAt == null) {
      var canCheckTask = manageTaskModel?.start_date?.compareTo(DateTime.now());
      if (canCheckTask != null) {
        if (canCheckTask == 0 || canCheckTask < 0) {
          clockInColor = theme.colorScheme.onSecondary;
        }
      }

      return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(StaticDataConfig.border_radius),
            color: clockInColor),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 2, right: 2),
            child: Text("Not Start Yet",
                style: theme.textTheme.bodySmall?.merge(TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold)),
                textAlign: TextAlign.center),
          ),
        ),
      );
    } else {
      if (manageTaskModel?.clock_in_status == ClockStatus.Late) {
        clockInColor = theme.colorScheme.onBackground;
      } else if (manageTaskModel?.clock_in_status == ClockStatus.Early) {
        clockInColor = theme.colorScheme.background;
      }

      if (manageTaskModel?.clock_out_status == ClockStatus.Late) {
        clockOutColor = theme.colorScheme.background;
      } else if (manageTaskModel?.clock_out_status == ClockStatus.Early) {
        clockOutColor = theme.colorScheme.onBackground;
      }

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(StaticDataConfig.border_radius),
          color: isClockIn ? clockInColor : clockOutColor,
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 2, right: 2),
            child: Text(
                isClockIn
                    ? "Start : ${DateFormat('dd/MM/yyyy HH:mm').format(manageTaskModel?.driverStartAt ?? DateTime(0))}"
                    : "End : ${DateFormat('dd/MM/yyyy HH:mm').format(manageTaskModel?.driverFinishAt ?? DateTime(0))}",
                style: theme.textTheme.bodySmall?.merge(TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold)),
                textAlign: TextAlign.center),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Scaffold(
      appBar: AppBarWidget(
        color: theme.colorScheme.primary,
        isDiscard: false,
        type: StaticModelType.manu,
        title: translate('app_bar.staff_management'),
        leadingBack: true,
        backIcon: Icons.arrow_back,
        icon: Icons.help,
        // iconTitle: translate('button.help'),
        iconTitle: '',
        onRightPressed: () => showActionGenFunc(
            context, translate('text_header.help'), translate('contents.help')),
      ),
      body: Padding(
        padding: EdgeInsets.only(
            top: StaticDataConfig.app_padding - 10,
            left: StaticDataConfig.app_padding - 15,
            right: StaticDataConfig.app_padding - 15),
        child: FutureBuilder<List<ManageTaskModel>?>(
            future: con.loadTaskControllerFromAPI(),
            builder: (BuildContext context,
                    AsyncSnapshot<List<ManageTaskModel>?> snapshot) =>
                Column(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ButtonOutlineWidget(
                        icon: Icons.calendar_month,
                        onPressed: () {
                          con.dateRangePicker(context);
                        },
                        title:
                            "${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(con.start.millisecondsSinceEpoch))}-${DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(con.end.millisecondsSinceEpoch))}",
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("${snapshot.data?.length}"),
                    Expanded(
                      flex: 2,
                      child: DataTable2(
                        headingCheckboxTheme: CheckboxThemeData(
                          fillColor: MaterialStateColor.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.selected)) {
                                return theme.colorScheme
                                    .primary; // the color when checkbox is selected;
                              }
                              return Colors
                                  .white; //the color when checkbox is unselected;
                            },
                          ),
                        ),
                        datarowCheckboxTheme: CheckboxThemeData(
                          fillColor: MaterialStateColor.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.selected)) {
                                return theme.colorScheme
                                    .primary; // the color when checkbox is selected;
                              }
                              return Colors
                                  .white; //the color when checkbox is unselected;
                            },
                          ),
                        ),
                        headingRowHeight: 25,
                        headingRowColor: MaterialStateProperty.all(
                            theme.colorScheme.onSecondary),
                        scrollController: con.scrollControllerTable,

                        decoration: BoxDecoration(
                            border: Border.all(
                                color: theme.colorScheme.onSecondary)),
                        columnSpacing: 5,
                        horizontalMargin: 5,
                        border: getCurrentRouteOption(context) ==
                                fixedColumnWidth
                            ? TableBorder(
                                top: BorderSide(
                                    color: theme.colorScheme.onSecondary),
                                bottom: BorderSide(color: Colors.grey[300]!),
                                left: BorderSide(color: Colors.grey[300]!),
                                right: BorderSide(color: Colors.grey[300]!),
                                verticalInside:
                                    BorderSide(color: Colors.grey[300]!),
                                horizontalInside: BorderSide(
                                    color: theme.colorScheme.onSecondary,
                                    width: 1))
                            : (getCurrentRouteOption(context) ==
                                    showBordersWithZebraStripes
                                ? TableBorder.all()
                                : null),
                        dividerThickness:
                            1, // this one will be ignored if [border] is set above
                        bottomMargin: 10,
                        minWidth: 500,
                        fixedTopRows: 1,
                        fixedLeftColumns: 1,
                        sortColumnIndex: con.sortColumnIndex,
                        onSelectAll: (val) => setState(() => {}),
                        sortAscending: con.sortAscending,
                        sortArrowIcon: Icons.arrow_upward, // custom arrow
                        sortArrowAnimationDuration: const Duration(
                            milliseconds: 500), // custom animation duration

                        columns: [
                          // DataColumn2(
                          //   fixedWidth: 22,
                          //   label: Text('N.', style: theme.textTheme.headlineSmall),
                          // ),
                          DataColumn2(
                            fixedWidth: 85,
                            label: Text("Employee Id",
                                style: theme.textTheme.headlineSmall),
                            onSort: (columnIndex, sortAscending) {
                              setState(() {
                                if (columnIndex == con.sortColumnIndex) {
                                  con.sortAscending =
                                      con.sortEmployeeId = sortAscending;
                                } else {
                                  con.sortColumnIndex = columnIndex;
                                  sortAscending = con.sortEmployeeId;
                                }
                                con.taskManagementService?.manageTaskModelList
                                    ?.sort((a, b) =>
                                        a.userId!.compareTo(b.userId!));
                                if (!sortAscending) {
                                  con.taskManagementService
                                          ?.manageTaskModelList =
                                      con.taskManagementService
                                          ?.manageTaskModelList?.reversed
                                          .toList();
                                }
                              });
                            },
                            // example of fixed 1st row
                          ),
                          DataColumn2(
                            size: ColumnSize.S,
                            label: Center(
                                child: Text("Assign Date",
                                    style: theme.textTheme.headlineSmall)),
                            // onSort: (columnIndex, sortAscending) {
                            //   setState(() {
                            //     if (columnIndex == con.sortColumnIndex) {
                            //       con.sortAscending =
                            //           con.sortStartDate = sortAscending;
                            //     } else {
                            //       con.sortColumnIndex = columnIndex;
                            //       sortAscending = con.sortStartDate;
                            //     }
                            //     con.taskManagementService?.manageTaskModelList
                            //         ?.sort((a, b) =>
                            //             a.start_date!.compareTo(b.start_date!));
                            //     if (!sortAscending) {
                            //       con.taskManagementService
                            //               ?.manageTaskModelList =
                            //           con.taskManagementService
                            //               ?.manageTaskModelList?.reversed
                            //               .toList();
                            //     }
                            //   });
                            // },
                          ),
                          DataColumn2(
                            size: ColumnSize.S,
                            label: Center(
                                child: Text("Clock In/Out",
                                    style: theme.textTheme.headlineSmall)),
                            onSort: (columnIndex, sortAscending) {
                              setState(() {
                                if (columnIndex == con.sortColumnIndex) {
                                  con.sortAscending =
                                      con.sortClockGroupStatus = sortAscending;
                                } else {
                                  con.sortColumnIndex = columnIndex;
                                  sortAscending = con.sortClockGroupStatus;
                                }
                                con.taskManagementService?.manageTaskModelList
                                    ?.sort((a, b) => a.clock_in_status!
                                        .compareTo(b.clock_in_status!));
                                if (!sortAscending) {
                                  con.taskManagementService
                                          ?.manageTaskModelList =
                                      con.taskManagementService
                                          ?.manageTaskModelList?.reversed
                                          .toList();
                                }
                              });
                            },
                          ),
                          DataColumn2(
                              fixedWidth: 80,
                              label: Text("InGeofence",
                                  style: theme.textTheme.headlineSmall),
                              onSort: (columnIndex, sortAscending) {}),
                        ],
                        empty: Center(
                            child: Container(
                                padding: const EdgeInsets.all(5),
                                color: Colors.grey[200],
                                child: Text(translate('text_header.no_data'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall))),
                        rows: List<DataRow2>.generate(
                          con.taskManagementService?.manageTaskModelList
                                  ?.length ??
                              0,
                          (int index) => DataRow2.byIndex(
                            // specificRowHeight: 35,
                            index: index,
                            color: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              // var rowData = con.taskManagementService
                              //     ?.manageTaskModelList?[index];
                              // All rows will have the same selected color.
                              if (states.contains(MaterialState.selected)) {
                                return Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.08);
                              }
                              // Even rows will have a grey color.
                              if (index.isEven) {
                                return Colors.grey.withOpacity(0.1);
                              }

                              return null;
                            }),
                            cells: (<DataCell>[
                              // DataCell(
                              //   // showEditIcon: true,
                              //   Text('${index + 1}',
                              //       style: theme.textTheme.bodyMedium,
                              //       textAlign: TextAlign.center),
                              // ),
                              DataCell(
                                // showEditIcon: true,
                                Text(
                                    '${con.taskManagementService?.manageTaskModelList?[index].userId}',
                                    style: theme.textTheme.headlineSmall,
                                    textAlign: TextAlign.center),
                              ),
                              DataCell(Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                      "Start : ${DateFormat('dd/MM/yyyy HH:mm').format(con.taskManagementService?.manageTaskModelList?[index].start_date ?? DateTime.now())}",
                                      style: theme.textTheme.bodySmall,
                                      textAlign: TextAlign.center),
                                  Text(
                                      "End : ${DateFormat('dd/MM/yyyy HH:mm').format(con.taskManagementService?.manageTaskModelList?[index].finish_date ?? DateTime.now())}",
                                      style: theme.textTheme.bodySmall,
                                      textAlign: TextAlign.center),
                                ],
                              )),
                              DataCell(Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _userClockBadge(true, index),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    con
                                                .taskManagementService
                                                ?.manageTaskModelList?[index]
                                                .driverFinishAt !=
                                            null
                                        ? _userClockBadge(false, index)
                                        : SizedBox.shrink(),
                                  ],
                                ),
                              )),
                              DataCell(
                                showEditIcon: true,
                                Text('Yes',
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center),
                              ),
                            ]),
                            // selected: con.taskManagementService?.manageTaskModelList![index].isChecked!,
                            // onSelectChanged: eachTaskModel?.status ==
                            //         TaskStatus.Start
                            //     ? (bool? value) {
                            //         if (con.taskManagementService?.manageTaskModelList![index]
                            //                 .isChecked !=
                            //             value) {
                            //           // selectedCount += value! ? 1 : -1;
                            //           // assert(selectedCount >= 0);
                            //           setState(() {
                            //             con.taskManagementService?.manageTaskModelList![index]
                            //                 .isChecked = value;
                            //           });
                            //         } else {
                            //           setState(() {
                            //             con.taskManagementService?.manageTaskModelList![index]
                            //                 .isChecked = value!;
                            //           });
                            //         }
                            //       }
                            // : (val) {},
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              height: 100,
                              child: PieChart(
                                PieChartData(sections: [
                                  PieChartSectionData(
                                    color: Colors.blue,
                                    value: 40,
                                    title: '40%',
                                    radius: 50,
                                    titleStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xffffffff)),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: 30,
                                    title: '30%',
                                    radius: 50,
                                    titleStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xffffffff)),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red,
                                    value: 15,
                                    title: '15%',
                                    radius: 50,
                                    titleStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xffffffff)),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.yellow,
                                    value: 15,
                                    title: '15%',
                                    radius: 50,
                                    titleStyle: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xffffffff)),
                                  ), // read about it in the PieChartData section
                                ]),
                                swapAnimationDuration:
                                    Duration(milliseconds: 150), // Optional
                                swapAnimationCurve: Curves.linear, // Optional
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )),
      ),
    );
  }
}
