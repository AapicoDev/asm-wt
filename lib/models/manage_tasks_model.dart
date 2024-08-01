import 'package:cloud_firestore/cloud_firestore.dart';

class ManageTaskModel {
  String? taskId;
  String? userId;
  String? name;
  String? controller_name;
  String? controller_id;
  GeoPoint? location;
  String? location_name;
  GeoPoint? clock_in_location;
  GeoPoint? clock_out_location;
  String? desc;
  String? progress;
  bool? isCheckIn;
  bool? isDisable;
  String? vehicleId;
  String? status;
  String? vehicleName;
  DateTime? start_date;
  DateTime? driverStartAt;
  DateTime? driverFinishAt;
  DateTime? create_date;
  DateTime? finish_date;
  String? clock_in_status;
  String? clock_out_status;
  String? clockOutCommand;
  String? clockInCommand;
  String? type;
  String? taskGroup;
  String? skipReason;

  ManageTaskModel({
    this.taskId,
    this.userId,
    this.controller_id,
    this.controller_name,
    this.name,
    this.desc,
    this.status,
    this.location,
    this.location_name,
    this.clock_in_location,
    this.clock_out_location,
    this.progress,
    this.isCheckIn,
    this.isDisable,
    this.driverStartAt,
    this.driverFinishAt,
    this.start_date,
    this.create_date,
    this.finish_date,
    this.vehicleId,
    this.vehicleName,
    this.clock_in_status,
    this.clock_out_status,
    this.clockOutCommand,
    this.type,
    this.clockInCommand,
    this.taskGroup,
    this.skipReason,
  });

  factory ManageTaskModel.fromMapStringDynamice(Map<String, dynamic> data) {
    return ManageTaskModel(
      // location: data['location'],
      // clock_in_location: data['clock_in_location'],
      // clock_out_location: data['clock_out_location'],
      userId: data['employee_id'],
      name: data['name'],
      desc: data['desc'],
      driverStartAt: data['employee_start_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              data['employee_start_time']['_seconds'] * 1000)
          : null,
      driverFinishAt: data['employee_finish_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              data['employee_finish_time']['_seconds'] * 1000)
          : null,
      start_date: data['start_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              data['start_time']['_seconds'] * 1000)
          : null,
      finish_date: data['finish_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              data['finish_time']['_seconds'] * 1000)
          : null,
      controller_id: data['controller_id'],
      controller_name: data['controller_name'],
      isDisable: data['is_disabled'],
      status: data['status'],
      clock_in_status: data['clock_in_status'],
      clock_out_status: data['clock_out_status'],
      clockOutCommand: data['clock_out_command'],
      clockInCommand: data['clock_in_command'],
      type: data['type'],
      taskGroup: data['task_group'],
      // location_name: data['location_name'],
      skipReason: data['skip_reason'],
      // create_date: data['created_at']
    );
  }
}
