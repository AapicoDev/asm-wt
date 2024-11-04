import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/models/task_status_report_model.dart';
import 'package:asm_wt/service/base_service.dart';

class TaskStatusReportService {
  final FirestoreService _firestoreService = FirestoreServiceImpl();

  DateTime dateNow = DateTime.now();
  TaskStatusReportModel taskStatusReportModel = TaskStatusReportModel();

  String getMonthAbbreviation(int month) {
    switch (month) {
      case DateTime.january:
        return StaticMonth.Jan;
      case DateTime.february:
        return StaticMonth.Feb;
      case DateTime.march:
        return StaticMonth.Mar;
      case DateTime.april:
        return StaticMonth.Apr;
      case DateTime.may:
        return StaticMonth.May;
      case DateTime.june:
        return StaticMonth.Jun;
      case DateTime.july:
        return StaticMonth.Jul;
      case DateTime.august:
        return StaticMonth.Aug;
      case DateTime.september:
        return StaticMonth.Sept;
      case DateTime.october:
        return StaticMonth.Oct;
      case DateTime.november:
        return StaticMonth.Nov;
      case DateTime.december:
        return StaticMonth.Dec;
      default:
        return '';
    }
  }

  Future<BaseService> increaseCompletedTaskByDocID(String? docID) async {
    if (docID == null || docID.isEmpty) {
      return BaseService('F', 'Invalid document ID', null);
    }

    var monthNow = getMonthAbbreviation(dateNow.month);
    var obj = {
      '$monthNow.${TaskStatusReport.Completed}': FieldValue.increment(1)
    };

    try {
      await _firestoreService.updateData(
          "${TableName.dbTaskStatusReportTable}/$docID", obj);
      return BaseService('S', 'Success', null);
    } catch (e) {
      print('Error increasing completed task by doc ID: $e');
      return BaseService('F', 'Failed to increase completed task', null);
    }
  }

  Future<BaseService> increaseEarlyFinishTaskByDocID(String? docID) async {
    if (docID == null || docID.isEmpty) {
      return BaseService('F', 'Invalid document ID', null);
    }

    var monthNow = getMonthAbbreviation(dateNow.month);
    var obj = {
      '$monthNow.${TaskStatusReport.Early_Finish}': FieldValue.increment(1)
    };

    try {
      await _firestoreService.updateData(
          "${TableName.dbTaskStatusReportTable}/$docID", obj);
      return BaseService('S', 'Success', null);
    } catch (e) {
      print('Error increasing early finish task by doc ID: $e');
      return BaseService('F', 'Failed to increase early finish task', null);
    }
  }

  Future<BaseService> increaseLateStartTaskByDocID(String? docID) async {
    if (docID == null || docID.isEmpty) {
      return BaseService('F', 'Invalid document ID', null);
    }

    var monthNow = getMonthAbbreviation(dateNow.month);
    var obj = {
      '$monthNow.${TaskStatusReport.Late_Start}': FieldValue.increment(1)
    };

    try {
      await _firestoreService.updateData(
          "${TableName.dbTaskStatusReportTable}/$docID", obj);
      return BaseService('S', 'Success', null);
    } catch (e) {
      print('Error increasing late start task by doc ID: $e');
      return BaseService('F', 'Failed to increase late start task', null);
    }
  }

  Future<TaskStatusReportModel?> getTaskStatusReportModelByDocID(
      String? docId) async {
    if (docId == null || docId.isEmpty) {
      print('Invalid document ID');
      return null;
    }

    try {
      DocumentSnapshot doc = await _firestoreService.getDocumentById(
          TableName.dbTaskStatusReportTable, docId);
      return TaskStatusReportModel.fromDocumentSnapshot(doc);
    } catch (e) {
      print('Error fetching task status report by doc ID: $e');
      return null;
    }
  }
}
