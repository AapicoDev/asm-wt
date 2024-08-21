import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
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
  Timestamp? start_date;
  Timestamp? driverStartAt;
  Timestamp? driverFinishAt;
  Timestamp? create_date;
  Timestamp? finish_date;
  String? clock_in_status;
  String? clock_out_status;
  String? clockOutCommand;
  String? clockInCommand;
  List<String>? clockInAreaEn;
  List<String>? clockInAreaTh;
  List<String>? clockOutAreaEn;
  List<String>? clockOutAreaTh;
  String? type;
  String? taskGroup;
  String? skipReason;
  DocumentReference? employeeModelRefData;

  TaskModel(
      {this.taskId,
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
      this.employeeModelRefData,
      this.clockInAreaEn,
      this.clockInAreaTh,
      this.clockOutAreaTh,
      this.clockOutAreaEn
      // required this.vehicle,
      });

  factory TaskModel.fromDocumentSnapshot(DocumentSnapshot? snapshot) {
    final Map<String, dynamic> data = snapshot?.data() as Map<String, dynamic>;

    // EmployeeModel? employeeModel;

    // if (data['employeeRef'] != null) {
    //   data['employeeRef'].get().then((employeeData) => {
    //         employeeModel = EmployeeModel.fromDocumentSnapshot(employeeData),
    //       });
    // }

    return TaskModel(
        taskId: snapshot?.id,
        location: data['location'],
        clock_in_location: data['clock_in_location'],
        clock_out_location: data['clock_out_location'],
        userId: data['employee_id'],
        name: data['name'],
        desc: data['desc'],
        driverStartAt: data['employee_start_time'],
        driverFinishAt: data['employee_finish_time'],
        start_date: data['start_time'],
        finish_date: data['finish_time'],
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
        location_name: data['location_name'],
        employeeModelRefData:
            data['employeeRef'] != null ? data['employeeRef'] : null,
        skipReason: data['skip_reason'],
        create_date: data['created_at']);
  }

  Map<String, dynamic> toJson(bool? isCreateNew) {
    late Map<String, dynamic> data = <String, dynamic>{};
    data['location'] = location;
    data['clock_in_location'] = clock_in_location;
    data['location_name'] = "Suvarnabhumi Airport";
    data['clock_out_location'] = clock_out_location;
    data['employee_id'] = userId;
    data['name'] = name;
    data['desc'] = desc;
    data['employee_start_time'] = driverStartAt;
    data['employee_finish_time'] = driverFinishAt;
    data['start_time'] = start_date;
    data['is_disabled'] = isDisable;
    data['finish_time'] = finish_date;
    data['controller_id'] = controller_id;
    data['controller_name'] = controller_name;
    data['status'] = status;
    data['clock_in_status'] = clock_in_status;
    clockInAreaEn != null ? data['clock_in_area_en'] = clockInAreaEn : null;
    clockInAreaTh != null ? data['clock_in_area_th'] = clockInAreaTh : null;
    clockOutAreaEn != null ? data['clock_out_area_en'] = clockOutAreaEn : null;
    clockOutAreaTh != null ? data['clock_out_area_th'] = clockOutAreaTh : null;
    data['clock_out_status'] = clock_out_status;
    if (isCreateNew ?? false) {
      data['created_at'] = FieldValue.serverTimestamp();
    }

    data['clock_out_command'] = clockOutCommand;
    data['clock_in_command'] = clockInCommand;
    data['type'] = type;
    data['task_group'] = taskGroup;
    data['skip_reason'] = skipReason;

    employeeModelRefData != null
        ? data['employeeRef'] = employeeModelRefData
        : null;

    return data;
  }

  // @override
  // String toString() {
  //   return '{name: ${name}, userId: ${userId}}';
  // }
}
