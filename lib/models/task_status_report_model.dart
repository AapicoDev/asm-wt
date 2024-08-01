import 'package:cloud_firestore/cloud_firestore.dart';

class StaticMonth {
  static const String Jan = 'jan';
  static const String Feb = 'feb';

  static const String Mar = 'mar';
  static const String Apr = 'apr';
  static const String May = 'may';
  static const String Jun = 'jun';
  static const String Jul = 'jul';
  static const String Aug = 'aug';
  static const String Sept = 'sept';
  static const String Oct = 'oct';
  static const String Nov = 'nov';
  static const String Dec = 'dec';
}

class TaskStatusReport {
  static const String Completed = 'completed';
  static const String Early_Finish = 'early_finish';
  static const String Late_Start = 'late_start';
}

class TaskStatusReportModel {
  String? repotUID;
  String? orgID;
  TaskReportStatus? jan;
  TaskReportStatus? feb;
  TaskReportStatus? mar;
  TaskReportStatus? apr;
  TaskReportStatus? may;
  TaskReportStatus? jun;
  TaskReportStatus? jul;
  TaskReportStatus? aug;
  TaskReportStatus? sept;
  TaskReportStatus? oct;
  TaskReportStatus? nov;
  TaskReportStatus? dec;

  TaskStatusReportModel(
      {this.repotUID,
      this.orgID,
      this.jan,
      this.feb,
      this.mar,
      this.apr,
      this.may,
      this.jun,
      this.jul,
      this.aug,
      this.sept,
      this.oct,
      this.nov,
      this.dec});

  factory TaskStatusReportModel.fromDocumentSnapshot(
      DocumentSnapshot snapshot) {
    final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return TaskStatusReportModel(
      repotUID: snapshot.id,
      orgID: data['organization_id'],
      jan: data[StaticMonth.Jan] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Jan])
          : null,
      feb: data[StaticMonth.Feb] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Feb])
          : null,
      mar: data[StaticMonth.Mar] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Mar])
          : null,
      apr: data[StaticMonth.Apr] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Apr])
          : null,
      may: data[StaticMonth.Mar] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Mar])
          : null,
      jun: data[StaticMonth.Jun] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Jun])
          : null,
      jul: data[StaticMonth.Jul] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Jul])
          : null,
      aug: data[StaticMonth.Aug] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Aug])
          : null,
      sept: data[StaticMonth.Sept] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Sept])
          : null,
      oct: data[StaticMonth.Oct] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Oct])
          : null,
      nov: data[StaticMonth.Nov] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Nov])
          : null,
      dec: data[StaticMonth.Dec] != null
          ? TaskReportStatus.fromJson(data[StaticMonth.Dec])
          : null,
    );
  }

  // Map<String, dynamic> toJson(TaskReportStatus? taskReportStatus) {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data[StaticMonth.Jan] = jan;
  //   data[StaticMonth.Feb] = feb;
  //   data[StaticMonth.Mar] = mar;
  //   data[StaticMonth.Apr] = apr;
  //   data[StaticMonth.Mar] = mar;
  //   data[StaticMonth.Jun] = jun;
  //   data[StaticMonth.Jul] = jul;
  //   data[StaticMonth.Aug] = aug;
  //   data[StaticMonth.Sept] = sept;
  //   data[StaticMonth.Oct] = oct;
  //   data[StaticMonth.Nov] = nov;
  //   data[StaticMonth.Dec] = dec;

  //   return data;
  // }
}

class TaskReportStatus {
  int? completed;
  int? early_finish;
  int? late_start;
  TaskReportStatus({this.completed, this.early_finish, this.late_start});

  factory TaskReportStatus.fromJson(Map<String, dynamic> data) {
    return TaskReportStatus(
      completed: data[TaskStatusReport.Completed],
      early_finish: data[TaskStatusReport.Early_Finish],
      late_start: data[TaskStatusReport.Late_Start],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data[TaskStatusReport.Completed] = completed;
    data[TaskStatusReport.Early_Finish] = early_finish;
    data[TaskStatusReport.Late_Start] = late_start;

    return data;
  }
}
