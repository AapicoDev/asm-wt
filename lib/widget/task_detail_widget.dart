import 'package:asm_wt/models/employee_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:asm_wt/assets/static_data.dart';
import 'package:asm_wt/models/tasks_model.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:asm_wt/widget/detail_row_Widget.dart';
import 'package:asm_wt/widget/task_status_widget.dart';

// ignore: must_be_immutable
class TaskDetailWidget extends StatefulWidget {
  TaskModel taskModel;
  bool? isHasHeader = false;
  bool? isCanSkipTask = false;
  VoidCallback? onPressed;

  TaskDetailWidget(
      {super.key,
      required this.taskModel,
      this.isHasHeader,
      this.onPressed,
      this.isCanSkipTask});

  @override
  // ignore: library_private_types_in_public_api
  _STaskDetailWidgetState createState() => _STaskDetailWidgetState();
}

class _STaskDetailWidgetState extends State<TaskDetailWidget> {
  // MaplibreMapController? _mapController;
  // List<Marker> _markers = [];
  // List<_MarkerState> _markerStates = [];
  Dio dio = Dio();
  LocationData? locationData;
  EmployeeModel? employeeModel;

  // Future<dynamic> onMapCreated(MaplibreMapController controller) async {
  //   _mapController = controller;

  //   controller.addListener(() {
  //     if (controller.isCameraMoving) {
  //       _updateMarkerPosition();
  //     }
  //   });
  // }

  // void _onCameraIdleCallback() {
  //   _updateMarkerPosition();
  // }

  // void _updateMarkerPosition() {
  //   final coordinates = <LatLng>[];

  //   for (final markerState in _markerStates) {
  //     coordinates.add(markerState.getCoordinate());
  //   }

  //   _mapController?.toScreenLocationBatch(coordinates).then((points) {
  //     _markerStates.asMap().forEach((i, value) {
  //       _markerStates[i].updatePosition(points[i]);
  //     });
  //   });
  // }

  @override
  void initState() {
    super.initState();
    getEmployeeData();
  }

  Future<void> getEmployeeData() async {
    var employeeData = await widget.taskModel.employeeModelRefData?.get();

    setState(() {
      employeeModel = EmployeeModel.fromDocumentSnapshot(employeeData!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;

    late LocalizationDelegate localizationDelegate =
        LocalizedApp.of(context).delegate;

    return Container(
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.only(
          left: StaticDataConfig.app_padding,
          right: StaticDataConfig.app_padding),
      child: IntrinsicHeight(
        child: Column(
          children: <Widget>[
            widget.isHasHeader ?? false
                ? TaskStatusWidget(
                    enable: true,
                    title: "Task CheckIn List",
                  )
                : Container(),
            const Divider(),
            SizedBox(
              height: 5,
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    StaticDataConfig.card_detail_border_radius),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: theme.colorScheme.secondary, spreadRadius: 1),
                ],
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          StaticDataConfig.card_detail_border_radius),
                      color: theme.colorScheme.secondary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              translate('text_header.task_detail'),
                              style: theme.textTheme.headlineMedium
                                  ?.merge(TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                        Container(
                          width: width / 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                StaticDataConfig.border_radius),
                            color: theme.colorScheme.onPrimary,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 2, right: 2),
                              child: Text(
                                "${widget.taskModel.type}",
                                style: theme.textTheme.headlineSmall?.merge(
                                    TextStyle(
                                        color: theme.colorScheme.primary)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DetailRowWidget(
                    underline: false,
                    isBladge: false,
                    flex: 3,
                    title: translate('task_manage.task_id'),
                    subWidget: Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                TextSpan(
                                  text: widget.taskModel.taskId,
                                  style: TextStyle(
                                      decoration: TextDecoration.underline),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async => await Clipboard.setData(
                              ClipboardData(
                                  text: "${widget.taskModel.taskId}")),
                          child: Icon(
                            Icons.content_copy,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                  DetailRowWidget(
                    underline: false,
                    flex: 3,
                    height: 25,
                    title: translate('text_header.task_title'),
                    subTitle: widget.taskModel.name,
                  ),
                  DetailRowWidget(
                    flex: 3,
                    underline: false,
                    // height: 40,
                    title: translate('text_header.description'),
                    subTitle: widget.taskModel.desc?.capitalize(),
                  ),
                  DetailRowWidget(
                    flex: 3,
                    underline: false,
                    height: 25,
                    isBladge: true,
                    title: translate('text_header.type'),
                    subTitle: widget.taskModel.taskGroup?.toUpperCase(),
                  ),
                  DetailRowWidget(
                    flex: 3,
                    underline: true,
                    height: 25,
                    title: translate('text_header.location'),
                    subTitle:
                        localizationDelegate.currentLocale.languageCode == 'en'
                            ? employeeModel?.site_en
                            : employeeModel?.site_th,
                    icon: Icons.place,
                  ),
                  DetailRowWidget(
                    underline: false,
                    flex: 3,
                    height: 25,
                    title: translate('text_header.assign_by'),
                    subTitle: widget.taskModel.controller_name?.capitalize(),
                  ),
                  DetailRowWidget(
                      flex: 3,
                      underline: false,
                      height: 30,
                      title: translate('text_header.assign_date'),
                      subTitle: DateFormat('E, dd/MM/yyyy HH:mm:ss').format(
                          DateTime.fromMillisecondsSinceEpoch(widget
                              .taskModel.create_date!.millisecondsSinceEpoch))),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    StaticDataConfig.card_detail_border_radius),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: theme.colorScheme.secondary, spreadRadius: 1),
                ],
              ),
              // color: theme.colorScheme.tertiary, // Red
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          StaticDataConfig.card_detail_border_radius),
                      boxShadow: [
                        BoxShadow(
                            color: theme.colorScheme.secondary,
                            spreadRadius: 1),
                      ],
                    ),
                    // color: theme.colorScheme.primary,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          translate('text_header.schedule'),
                          style: theme.textTheme.headlineMedium
                              ?.merge(TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DetailRowWidget(
                      underline: false,
                      flex: 3,
                      height: 25,
                      title: translate('text_header.start_date'),
                      subTitle: DateFormat('E, dd/MM/yyyy HH:mm:ss').format(
                          DateTime.fromMillisecondsSinceEpoch(widget
                              .taskModel.start_date!.millisecondsSinceEpoch))),
                  DetailRowWidget(
                    underline: false,
                    isBladge: true,
                    flex: 3,
                    title: translate('button.clock_in'),
                    isHasProblem:
                        widget.taskModel.clock_in_status == ClockStatus.Late
                            ? true
                            : false,
                    sub2Title: widget.taskModel.driverStartAt != null
                        ? DateFormat('E, dd/MM/yyyy HH:mm:ss').format(
                            DateTime.fromMillisecondsSinceEpoch(widget.taskModel
                                .driverStartAt!.millisecondsSinceEpoch))
                        : "NONE",
                  ),
                  DetailRowWidget(
                      underline: false,
                      flex: 3,
                      height: 25,
                      title: translate('text_header.finish_date'),
                      subTitle: DateFormat('E, dd/MM/yyyy HH:mm:ss').format(
                          DateTime.fromMillisecondsSinceEpoch(widget
                              .taskModel.finish_date!.millisecondsSinceEpoch))),
                  DetailRowWidget(
                    underline: false,
                    isBladge: true,
                    flex: 3,
                    title: translate('button.clock_out'),
                    isHasProblem:
                        widget.taskModel.clock_out_status == ClockStatus.Early
                            ? true
                            : false,
                    sub2Title: widget.taskModel.driverFinishAt != null
                        ? DateFormat('E, dd/MM/yyyy HH:mm:ss').format(
                            DateTime.fromMillisecondsSinceEpoch(widget.taskModel
                                .driverFinishAt!.millisecondsSinceEpoch))
                        : "NONE",
                  ),
                ],
              ),
            ),
            widget.isCanSkipTask ?? false
                ? widget.taskModel.status == TaskStatus.Skip ||
                        widget.taskModel.status == TaskStatus.Done
                    ? SizedBox.shrink()
                    : Container(
                        height: 35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: widget.onPressed,
                              child: Text(translate('button.press_to_skip'),
                                  style: theme.textTheme.bodyMedium?.merge(
                                      TextStyle(
                                          color: theme.colorScheme.onBackground,
                                          fontStyle: FontStyle.italic))),
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.selected)) {
                                      return Colors.white;
                                    }
                                    return null; // defer to the defaults
                                  },
                                ),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color?>(
                                  (Set<MaterialState> states) {
                                    if (states
                                        .contains(MaterialState.selected)) {
                                      return Colors.indigo;
                                    }
                                    return null; // defer to the defaults
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                : SizedBox.shrink(),
            // MaplibreMap(
            //   dragEnabled: false,
            //   compassViewPosition: CompassViewPosition.BottomLeft,
            //   logoViewMargins: const Point<num>(-100, -100),
            //   attributionButtonMargins: const Point<num>(-100, -100),
            //   styleString:
            //       "https://maps.powermap.live/api/v2/map/vtile/styles?name=thailand_th&access_token=b378c575291af30a29f59919fd7e7e4c012d45c4",
            //   compassEnabled: false,
            //   annotationOrder: const [],
            //   onCameraIdle: _onCameraIdleCallback,
            //   onMapCreated: (controller) =>
            //       onMapCreated(controller).then((dynamic data) {
            //     if (data != null) {
            //       _mapController?.animateCamera(
            //         CameraUpdate.newCameraPosition(
            //           CameraPosition(target: data, zoom: 10),
            //         ),
            //       );
            //     }
            //   }),
            //   // myLocationRenderMode: MyLocationRenderMode.GPS,
            //   myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
            //   myLocationEnabled: true,
            //   trackCameraPosition: true,
            //   initialCameraPosition: CameraPosition(
            //     target: LatLng(
            //         widget.taskModel.clock_in_location?.latitude ?? 14.240,
            //         widget.taskModel.clock_in_location?.longitude ??
            //             100.5925057),
            //     zoom: 15,
            //   ),

            //   onMapClick: (point, latlng) {},
            //   // onStyleLoadedCallback: () => con.callbackStyleload(filterData),
            // ),
          ],
        ),
      ),
    );
  }
}

// class Marker extends StatefulWidget {
//   final Point _initialPosition;
//   final LatLng _coordinate;
//   final void Function(_MarkerState) _addMarkerState;

//   Marker(
//       String key, this._coordinate, this._initialPosition, this._addMarkerState)
//       : super(key: Key(key));

//   @override
//   // ignore: no_logic_in_create_state
//   State<StatefulWidget> createState() {
//     final state = _MarkerState(_initialPosition);
//     _addMarkerState(state);
//     return state;
//   }
// }

// class _MarkerState extends State with TickerProviderStateMixin {
//   final _iconSize = 20.0;

//   Point _position;

//   late AnimationController _controller;
//   late Animation<double> _animation;

//   _MarkerState(this._position);

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 2),
//       vsync: this,
//     )..repeat(reverse: true);
//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.elasticOut,
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var ratio = 1.0;

//     //web does not support Platform._operatingSystem
//     if (!kIsWeb) {
//       // iOS returns logical pixel while Android returns screen pixel
//       ratio = Platform.isIOS ? 1.0 : MediaQuery.of(context).devicePixelRatio;
//     }

//     return Positioned(
//         left: _position.x / ratio - _iconSize / 2,
//         top: _position.y / ratio - _iconSize / 2,
//         child: RotationTransition(
//             turns: _animation,
//             child: Image.asset('lib/assets/images/custom-icon.png',
//                 height: _iconSize)));
//   }

//   void updatePosition(Point<num> point) {
//     setState(() {
//       _position = point;
//     });
//   }

//   LatLng getCoordinate() {
//     return (widget as Marker)._coordinate;
//   }
// }
