import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:asm_wt/app/my_account/my_account_controller.dart';
import 'package:asm_wt/models/settings_model.dart';
import 'package:asm_wt/service/RESTAPI/geofencing_service.dart';
import 'package:asm_wt/service/base_service.dart';
import 'package:asm_wt/service/settings_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:asm_wt/app/app_key.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/geofence_model.dart';
import 'package:asm_wt/models/new_feeds_model.dart';
import 'package:asm_wt/models/tasks_model.dart';
import 'package:asm_wt/router/router_name.dart';
import 'package:asm_wt/service/new_feeds_service.dart';
import 'package:asm_wt/service/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:asm_wt/service/task_status_report_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/button_widget.dart';
import 'package:asm_wt/widget/loading_overlay_widget.dart';
import 'package:asm_wt/widget/multi_text_field_widget.dart';
import 'package:ntp/ntp.dart';
import 'package:asm_wt/widget/network_error_widget.dart';

class TodayTaskController extends ControllerMVC {
  late AppStateMVC appState;
  late TaskModel taskModel;
  late String userId;
  final TasksService tasksService;
  final SettingsService settingsService;

  User? user;
  late StreamSubscription subscription;
  List<ConnectivityResult>? connectivityResult;
  TextEditingController skipTaskReasonCon = TextEditingController();
  DateTime now = DateTime.now();
  SharedPreferences prefs = GetIt.instance<SharedPreferences>();
  NewFeedsService newFeedsService = NewFeedsService();
  TaskStatusReportService taskStatusReportService = TaskStatusReportService();

  List<_MarkerState> _markerStates = [];
  GeoFencingService? geoFencingService;
  MaplibreMapController? _mapController;
  TasksService _tasksService = TasksService();
  bool onClockInOrClockOutPress = false;
  SettingsModel? settingsModel;
  String? taskStatusReportDocId;

  MyAccountController? conUser;

  factory TodayTaskController() => _this ??= TodayTaskController._();
  TodayTaskController._()
      : taskModel = TaskModel(),
        tasksService = TasksService(),
        settingsService = SettingsService(),
        conUser = MyAccountController(),
        super();
  static TodayTaskController? _this;

  @override
  void dispose() {
    subscription.cancel();
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    getConnectivity();
    loadSettingDb();
    onClockInOrClockOutPress = false;
    debugPrint("Userdata ${conUser?.userModel?.toJson().toString()}");
  }

  Future<void> loadSettingDb() async {
    await settingsService
        .getSettingsDataByorgId(prefs.getString('organizationId') ?? '')
        .then((res) => setState(
              () {
                settingsModel = res;
              },
            ));
    notifyListeners();
  }

  Future<void> loadTimeServer() async {
    try {
      var serverTime = await NTP.now();
      setState(() {
        now = serverTime;
      });
    } on Exception catch (_) {
      setState(() {
        now = DateTime.now();
      });
      rethrow;
    }
  }

  void showActionConfirmSkipFunc(
      context, title, content, TaskModel taskModel, String fromWhere) {
    skipTaskReasonCon.text = "";
    var theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (context) {
        Map<String, dynamic> data = Map<String, dynamic>();
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(StaticDataConfig.border_radius)),
          contentTextStyle: theme.textTheme.bodyMedium,
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            color: theme.colorScheme.primary,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(
                  top: StaticDataConfig.app_padding,
                  bottom: StaticDataConfig.app_padding),
              child: Text(
                title,
                style: theme.textTheme.headlineLarge
                    ?.merge(TextStyle(color: theme.colorScheme.onSecondary)),
              ),
            ),
          ),
          content: Column(
            children: [
              Divider(),
              Text(content),
              SizedBox(
                height: 5,
              ),
              Form(
                key: AppKeys.skipTaskReason,
                child: MultiTextFieldWidget(
                  maxLines: null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: skipTaskReasonCon,
                  title: translate('text_header.reason'),
                  hint: translate("text_header.reason_hint"),
                  boolSuffixIcon: false,
                  keyboardType: TextInputType.multiline,
                  prefixIcon: const Icon(Icons.emoji_objects_outlined),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                  ]),
                ),
              )
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(translate('button.cancel')),
                ),
                TextButton(
                  onPressed: () async => {
                    if (AppKeys.skipTaskReason.currentState!.validate())
                      {
                        if (connectivityResult == ConnectivityResult.none)
                          {
                            showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (_) => NetworkErrorDialog(
                                onPressed: Navigator.of(context).pop,
                              ),
                            ),
                          }
                        else
                          {
                            LoadingOverlay.of(context).show(),
                            data["status"] = TaskStatus.Skip,
                            data["skip_reason"] = skipTaskReasonCon.text,
                            await tasksService
                                .updateTaskStatusByTaskId(
                                    taskModel.taskId, data)
                                .then((res) => {
                                      if (res.status == "S")
                                        {
                                          if (fromWhere == "fromCalendar")
                                            {
                                              context.pushNamed(
                                                  RouteNames.taskCalendar)
                                            }
                                          else
                                            {Navigator.of(context).pop()}
                                        }
                                    }),
                            LoadingOverlay.of(context).hide(),
                          }
                      }
                  },
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).colorScheme.primary)),
                  child: Text(translate('button.skip'),
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
          if (connectivityResult != ConnectivityResult.none) {
            loadTimeServer();
          }
          setState(() {
            connectivityResult = result;
          });
        },
      );

  Future<void> createClockInOutNewFeedsFunc(
      TaskModel taskModel, String? status, String? clockInOutEvent) async {
    NewFeedsModel newFeedsModel = NewFeedsModel();

    newFeedsModel.title = clockInOutEvent;
    newFeedsModel.fromId = taskModel.userId;
    newFeedsModel.toId = prefs.getString("organizationId");
    newFeedsModel.createdDate = Timestamp.now();
    newFeedsModel.type = NewFeedsType.Task;
    newFeedsModel.typeId = taskModel.taskId;
    newFeedsModel.desc = "Worker Performce";
    newFeedsModel.status = status;

    //create new feed;
    await newFeedsService.createNewFeeds(newFeedsModel.toJson());
  }

  Future<void> showCustomPermissionDialog(BuildContext context) async {
    var theme = Theme.of(context);
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(translate("permission.location_title1"),
              style: theme.textTheme.titleLarge),
          content: SizedBox(
            height: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text.rich(
                    TextSpan(style: theme.textTheme.bodyMedium, children: [
                      TextSpan(
                          text: "${translate("permission.location_title2")}  ",
                          style: theme.textTheme.headlineSmall),
                      TextSpan(
                          text: translate("permission.location_contents_1"),
                          style: theme.textTheme.bodyMedium)
                    ]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text.rich(
                    TextSpan(style: theme.textTheme.bodyMedium, children: [
                      TextSpan(
                          text: "${translate("app_bar.demo_title")}  ",
                          style: theme.textTheme.headlineSmall),
                      TextSpan(
                          text: translate("permission.location_contents_2"),
                          style: theme.textTheme.bodyMedium)
                    ]),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(translate("button.deny"),
                  style: theme.textTheme.bodyMedium),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(theme.colorScheme.primary)),
              child: Text(translate("button.accept"),
                  style: theme.textTheme.headlineSmall
                      ?.merge(TextStyle(color: theme.colorScheme.onPrimary))),
              onPressed: () async {
                // Open app settings so the user can manually grant permission
                setState(() {
                  onClockInOrClockOutPress = false;
                });
                await Permission.location.request();

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> getLocationEnable() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      Geolocator.openLocationSettings();
    } else {
      return true;
    }
    return false;
  }

  Future<Position?> determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Geolocator.openLocationSettings();
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('------Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (Platform.isAndroid) {
        await showCustomPermissionDialog(context);
      } else {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    // return await Geolocator.getCurrentPosition();
    return await Geolocator.getLastKnownPosition();
  }

  Future<void> onClockOutPressed(
      BuildContext context, TaskModel? taskModel, String? type) async {
    TextEditingController clockOutCommand = TextEditingController();
    var theme = Theme.of(context);

    var geofenceResult =
        await geoFencingService?.getGeofencingAreaByOrganizationId();

    if (geofenceResult?.status == 'S') {
      await determinePosition(context).then((position) async => {
            setState(() {
              onClockInOrClockOutPress = false;
            }),
            notifyListeners(),
            geoFencingService?.geoAreadList = [],
            geoFencingService?.clockInOutAreaNameEn = [],
            geoFencingService?.clockInOutAreaNameTh = [],
            modelConfirmWidgetFunc(
                context,
                translate("text_header.confirm_location"),
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    ButtonWidget(
                      enable: true,
                      fullStyle: true,
                      color: Theme.of(context).colorScheme.primary,
                      // onPressed: () => con.onCheckInPressed(context),
                      onPressed: () => onClockOutConfirmPressed(
                          context,
                          taskModel,
                          type,
                          clockOutCommand.text,
                          taskStatusReportDocId),
                      title: translate('button.confirm'),
                    ),
                  ],
                ),
                position,
                clockOutCommand),
            if (position?.latitude == 0 && position?.longitude == 0)
              {
                showToastMessage(
                    context,
                    translate('task_checkIn.position_0_content'),
                    theme.colorScheme.onBackground)
              }
            else if (position?.latitude == null && position?.longitude == null)
              {
                showToastMessage(
                    context,
                    translate('task_checkIn.position_null_content'),
                    theme.colorScheme.onBackground),
              }
          });
    } else {
      showToastMessage(context, "Server Not Respone : Get list geofence error!",
          theme.colorScheme.onBackground);
    }
  }

  Future<void> clockOutProcess(BuildContext context, TaskModel? taskModel,
      String? type, BaseService? userIsInGeofencing) async {
    LoadingOverlay.of(context).show();
    DateTime serverTimeNow = await NTP.now();

    var finishDate = DateTime.fromMicrosecondsSinceEpoch(
        taskModel!.finish_date!.microsecondsSinceEpoch);

    taskModel.clockOutAreaEn = geoFencingService?.clockInOutAreaNameEn;
    taskModel.clockOutAreaTh = geoFencingService?.clockInOutAreaNameTh;
    taskModel.driverFinishAt = Timestamp.fromDate(serverTimeNow);
    taskModel.status = TaskStatus.Done;

    var canCheckTask = finishDate.compareTo(serverTimeNow);
    if (canCheckTask == 0) {
      taskModel.clock_out_status = ClockStatus.Same;
    } else if (canCheckTask < 0) {
      taskModel.clock_out_status = ClockStatus.Late;
    } else {
      taskModel.clock_out_status = ClockStatus.Early;
      await taskStatusReportService
          .increaseEarlyFinishTaskByDocID(taskStatusReportDocId);
    }

    await _tasksService
        .updateTaskStatusByTaskId(taskModel.taskId, taskModel.toJson(false)) //
        .then((res) async => {
              if (res.status == "S")
                {
                  await taskStatusReportService
                      .increaseCompletedTaskByDocID(taskStatusReportDocId),
                  await createClockInOutNewFeedsFunc(
                      taskModel, TaskStatus.Done, ClockInOutEvent.ClockOut),
                  showToastMessage(
                      context,
                      userIsInGeofencing?.data != null
                          ? "${userIsInGeofencing?.message} : ${geoFencingService?.clockInOutAreaNameEn}"
                          : "${userIsInGeofencing?.message}",
                      userIsInGeofencing?.data != null
                          ? Theme.of(context).colorScheme.background
                          : Theme.of(context).colorScheme.onBackground),
                  if (type == "fromCalendar") {Navigator.of(context).pop()}
                },
            });

    LoadingOverlay.of(context).hide();
  }

  Future<void> onClockOutConfirmPressed(
      BuildContext context,
      TaskModel? taskModel,
      String? type,
      String? clockOutCommand,
      String? taskStatusReportDocId) async {
    var currentUserPosition = await determinePosition(context);

    var userIsInGeofencing = await geoFencingService?.confirmInGeofencingArea(
        LatLng(currentUserPosition?.latitude ?? 0,
            currentUserPosition?.longitude ?? 0));

    if (userIsInGeofencing?.status == 'S') {
      taskModel?.clockOutCommand = clockOutCommand;

      taskModel?.clock_out_location = GeoPoint(
          currentUserPosition?.latitude ?? 0,
          currentUserPosition?.longitude ?? 0);

      if (userIsInGeofencing?.data != null) {
        await clockOutProcess(context, taskModel, type, userIsInGeofencing)
            .then((v) => Navigator.pop(context));
      } else {
        showActionConfirmFunc(
            context,
            translate('button.confirm'),
            "${userIsInGeofencing?.message}",
            Theme.of(context).colorScheme.onBackground,
            () async => await clockOutProcess(
                        context, taskModel, type, userIsInGeofencing)
                    .then((v) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }));
      }
    } else {
      showToastMessage(context, "${userIsInGeofencing?.message}",
          Theme.of(context).colorScheme.onBackground);
    }
  }

  Future<void> onClockInPressed(
      BuildContext context, TaskModel? taskModel, String? type) async {
    // Map<String, dynamic> taskData = <String, dynamic>{};
    var theme = Theme.of(context);
    TextEditingController clockInCommand = TextEditingController();

    var geofenceResult =
        await geoFencingService?.getGeofencingAreaByOrganizationId();
    if (geofenceResult?.status == 'S') {
      await determinePosition(context).then((position) async => {
            setState(() {
              onClockInOrClockOutPress = false;
            }),
            notifyListeners(),
            geoFencingService?.geoAreadList = [],
            geoFencingService?.clockInOutAreaNameEn = [],
            geoFencingService?.clockInOutAreaNameTh = [],

            //show clock in model;
            modelConfirmWidgetFunc(
              context,
              translate("text_header.confirm_location"),
              Column(
                children: [
                  ButtonWidget(
                    enable: true,
                    fullStyle: true,
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => {
                      onClockInConfirmPressed(context, taskModel, type,
                          clockInCommand.text, taskStatusReportDocId)
                    },
                    title: translate('button.confirm'),
                  ),
                ],
              ),
              position,
              clockInCommand,
            ),

            if (position?.latitude == 0 && position?.longitude == 0)
              {
                showToastMessage(
                    context,
                    translate('task_checkIn.position_0_content'),
                    theme.colorScheme.onBackground)
              }
            else if (position?.latitude == null && position?.longitude == null)
              {
                showToastMessage(
                    context,
                    translate('task_checkIn.position_null_content'),
                    theme.colorScheme.onBackground),
              }
          });
    } else {
      showToastMessage(context, "Server Not Respone : Get list geofence error!",
          theme.colorScheme.onBackground);
    }
  }

  Future<void> clockInProcess(BuildContext context, TaskModel? taskModel,
      String? type, BaseService? userIsInGeofencing) async {
    LoadingOverlay.of(context).show();
    DateTime serverTimeNow = await NTP.now();

    var startDate = DateTime.fromMicrosecondsSinceEpoch(
        taskModel!.start_date!.microsecondsSinceEpoch);

    taskModel.clockInAreaEn = geoFencingService?.clockInOutAreaNameEn;
    taskModel.clockInAreaTh = geoFencingService?.clockInOutAreaNameTh;
    taskModel.status = TaskStatus.Start;

    taskModel.driverStartAt = Timestamp.fromDate(serverTimeNow);

    var canCheckTask = startDate.compareTo(serverTimeNow);
    if (canCheckTask < 0) {
      taskModel.clock_in_status = ClockStatus.Late;
      await taskStatusReportService
          .increaseLateStartTaskByDocID(taskStatusReportDocId);
    } else if (canCheckTask == 0) {
      taskModel.clock_in_status = ClockStatus.Same;
    } else {
      taskModel.clock_in_status = ClockStatus.Early;
    }

    await _tasksService.updateTaskStatusByTaskId(taskModel.taskId, {
      ...taskModel.toJson(false),
      "site_th": conUser?.userModel?.siteTH,
      "site_en": conUser?.userModel?.siteEN,
      "section_code": conUser?.userModel?.sectionCode,
      "section_th": conUser?.userModel?.sectionTH,
      "section_en": conUser?.userModel?.sectionEN,
      "job_code": conUser?.userModel?.jobCode,
      "site_code": conUser?.userModel?.siteCode,
      "job_th": conUser?.userModel?.jobTH,
      "job_en": conUser?.userModel?.jobEN,
      "firstname_th": conUser?.userModel?.firstnameTH,
      "firstname_en": conUser?.userModel?.firstnameEN,
      "lastname_th": conUser?.userModel?.lastnameTH,
      "lastname_en": conUser?.userModel?.lastnameEN
    }).then((res) async => {
          if (res.status == "S")
            {
              await createClockInOutNewFeedsFunc(
                  taskModel, TaskStatus.Start, ClockInOutEvent.ClockIn),
              showToastMessage(
                  context,
                  userIsInGeofencing?.data != null
                      ? "${userIsInGeofencing?.message} : ${geoFencingService?.clockInOutAreaNameEn}"
                      : "${userIsInGeofencing?.message}",
                  userIsInGeofencing?.data != null
                      ? Theme.of(context).colorScheme.background
                      : Theme.of(context).colorScheme.onBackground),
              if (type == "fromCalendar") {Navigator.of(context).pop()}
            },
        });

    LoadingOverlay.of(context).hide();
  }

  Future<void> onClockInConfirmPressed(
      BuildContext context,
      TaskModel? taskModel,
      String? type,
      String? clockInCommand,
      String? taskStatusReportDocId) async {
    var currentUserPosition = await determinePosition(context);

    //check if user in geofencing area;
    var userIsInGeofencing = await geoFencingService?.confirmInGeofencingArea(
        LatLng(currentUserPosition?.latitude ?? 0,
            currentUserPosition?.longitude ?? 0));

    if (userIsInGeofencing?.status == 'S') {
      taskModel?.clock_in_location = GeoPoint(
          currentUserPosition?.latitude ?? 0,
          currentUserPosition?.longitude ?? 0);
      taskModel?.clockInCommand = clockInCommand;

      if (userIsInGeofencing?.data != null) {
        await clockInProcess(context, taskModel, type, userIsInGeofencing)
            .then((v) => Navigator.pop(context));
      } else {
        showActionConfirmFunc(
            context,
            translate('button.confirm'),
            "${userIsInGeofencing?.message}",
            Theme.of(context).colorScheme.onBackground,
            () async => await clockInProcess(
                        context, taskModel, type, userIsInGeofencing)
                    .then((v) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }));
      }
    } else {
      showToastMessage(context, "${userIsInGeofencing?.message}",
          Theme.of(context).colorScheme.onBackground);
    }

    // LoadingOverlay.of(context).hide();
    // Navigator.pop(context);
  }

//Map area code;
  Future<dynamic> onMapCreated(MaplibreMapController controller) async {
    _mapController = controller;

    controller.addListener(() {
      if (controller.isCameraMoving) {
        _updateMarkerPosition();
      }
    });
  }

  void _onCameraIdleCallback() {
    _updateMarkerPosition();
  }

  void _updateMarkerPosition() {
    final coordinates = <LatLng>[];

    for (final markerState in _markerStates) {
      coordinates.add(markerState.getCoordinate());
    }

    _mapController?.toScreenLocationBatch(coordinates).then((points) {
      _markerStates.asMap().forEach((i, value) {
        _markerStates[i].updatePosition(points[i]);
      });
    });
  }

  void _onStyleLoadedCallback() async {
    await geoFencingService?.getGeofencingAreaByOrganizationId();
    await _mapController?.addSource("geofencing",
        GeojsonSourceProperties(data: geoFencingService?.geoJsonData));

    for (GeoFenceStrapiAPIModel data
        in geoFencingService?.geofenceStrapiAPIList ?? []) {
      if (data.attributes?.isChecked ?? false) {
        await _mapController?.addFillLayer(
          "geofencing",
          "${data.id}",
          const FillLayerProperties(fillColor: [
            Expressions.interpolate,
            ['exponential', 0.5],
            [Expressions.zoom],
            11,
            'red',
            18,
            'green'
          ], fillOpacity: 0.4),
          filter: ['==', 'id', data.id],
        );
      }
    }
  }

  Future<void> modelConfirmWidgetFunc(
      BuildContext context,
      String title,
      Widget confirmBtn,
      Position? position,
      TextEditingController controler) async {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    DateTime serverTimeNow = await NTP.now();

    showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0))),
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Padding(
              padding: const EdgeInsets.all(StaticDataConfig.app_padding - 10),
              child: SizedBox(
                height: height / 1.4,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                        ),
                        Container(
                            decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: height / 80,
                            width: width / 7),
                        Text(
                            DateFormat('hh:mm a').format(
                                DateTime.fromMillisecondsSinceEpoch(
                                    serverTimeNow.millisecondsSinceEpoch)),
                            style: theme.textTheme.bodyMedium)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                              child: Text(title,
                                  style: theme.textTheme.headlineLarge)),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: controler,
                        decoration: InputDecoration(
                            focusedBorder: const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.grey, width: 0.0),
                            ),
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                            hintText: translate("text_header.remark"),
                            hintStyle: Theme.of(context).textTheme.bodyMedium,
                            border: const OutlineInputBorder(),
                            fillColor: Theme.of(context).colorScheme.tertiary),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: MaplibreMap(
                        dragEnabled: false,
                        compassViewPosition: CompassViewPosition.bottomLeft,
                        logoViewMargins: const Point<num>(-100, -100),
                        attributionButtonMargins: const Point<num>(-100, -100),
                        styleString:
                            "https://maps.powermap.live/api/v2/map/vtile/styles?name=thailand_th&access_token=b378c575291af30a29f59919fd7e7e4c012d45c4",

                        compassEnabled: false,
                        scrollGesturesEnabled: false,
                        annotationOrder: const [],
                        onCameraIdle: _onCameraIdleCallback,
                        onStyleLoadedCallback: _onStyleLoadedCallback,
                        // onUserLocationUpdated: (location) async {
                        //   await geoFencingService
                        //       ?.confirmInGeofencingArea(location.position);
                        // },
                        onMapCreated: (controller) =>
                            onMapCreated(controller).then((dynamic data) {
                          if (data != null) {
                            _mapController?.animateCamera(
                              CameraUpdate.newCameraPosition(
                                CameraPosition(target: data, zoom: 10),
                              ),
                            );
                          }
                        }),
                        // myLocationRenderMode: MyLocationRenderMode.GPS,
                        myLocationTrackingMode:
                            MyLocationTrackingMode.trackingGps,
                        myLocationEnabled: true,
                        trackCameraPosition: true,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(position?.latitude ?? 14.240,
                              position?.longitude ?? 100.5925057),
                          zoom: 15,
                        ),

                        onMapClick: (point, latlng) {},
                        // onStyleLoadedCallback: () => con.callbackStyleload(filterData),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // geoFencingService!.isHasGeofence
                          //     ? geoFencingService?.geoAreadList.length != 0
                          //         ? Row(
                          //             children: [
                          //               Text(
                          //                 translate(
                          //                     "task_checkIn.geo_location_message"),
                          //                 style: theme.textTheme.bodySmall,
                          //               ),
                          //               Column(
                          //                 children: List.generate(
                          //                     geoFencingService
                          //                             ?.geoAreadList.length ??
                          //                         0,
                          //                     (index) => Text(
                          //                           "${geoFencingService?.geoAreadList[index].name_th}",
                          //                           style: theme
                          //                               .textTheme.bodySmall,
                          //                         )),
                          //               ),
                          //             ],
                          //           )
                          //         : Center(
                          //             child: Text(
                          //               translate(
                          //                   "task_checkIn.geo_check_message"),
                          //               style: theme.textTheme.bodySmall?.merge(
                          //                   TextStyle(
                          //                       color: theme
                          //                           .colorScheme.onBackground)),
                          //             ),
                          //           )
                          //     : SizedBox.shrink(),

                          confirmBtn
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class Marker extends StatefulWidget {
  final Point _initialPosition;
  final LatLng _coordinate;
  final void Function(_MarkerState) _addMarkerState;

  Marker(
      String key, this._coordinate, this._initialPosition, this._addMarkerState)
      : super(key: Key(key));

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    final state = _MarkerState(_initialPosition);
    _addMarkerState(state);
    return state;
  }
}

class _MarkerState extends State with TickerProviderStateMixin {
  final _iconSize = 20.0;

  Point _position;

  late AnimationController _controller;
  late Animation<double> _animation;

  _MarkerState(this._position);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var ratio = 1.0;

    //web does not support Platform._operatingSystem
    if (!kIsWeb) {
      // iOS returns logical pixel while Android returns screen pixel
      ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
    }

    return Positioned(
        left: _position.x / ratio - _iconSize / 2,
        top: _position.y / ratio - _iconSize / 2,
        child: RotationTransition(
            turns: _animation,
            child: Image.asset('lib/assets/images/custom-marker.png',
                height: _iconSize)));
  }

  void updatePosition(Point<num> point) {
    setState(() {
      _position = point;
    });
  }

  LatLng getCoordinate() {
    return (widget as Marker)._coordinate;
  }
}
