import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/models/task_status_report_model.dart';
import 'package:asm_wt/service/base_service.dart';

class TaskStatusReportService {
  final FirestoreService _firestoreService =
      FirestoreServiceImpl(); // final AuthService _authService = FirebaseAuthService();
  // final CollectionReference _newFeedsRef =
  //     FirebaseFirestore.instance.collection(TableName.dbTaskStatusReportTable);

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
    var monthNow = getMonthAbbreviation(dateNow.month);
    var obj = {
      '$monthNow.${TaskStatusReport.Completed}': FieldValue.increment(1)
    };

    return await _firestoreService
        .updateData("${TableName.dbTaskStatusReportTable}/$docID", obj)
        .then((value) => BaseService('S', 'Success', null));
  }

  Future<BaseService> increaseEarlyFinishTaskByDocID(String? docID) async {
    var monthNow = getMonthAbbreviation(dateNow.month);
    var obj = {
      '$monthNow.${TaskStatusReport.Early_Finish}': FieldValue.increment(1)
    };

    return await _firestoreService
        .updateData("${TableName.dbTaskStatusReportTable}/$docID", obj)
        .then((value) => BaseService('S', 'Success', null));
  }

  Future<BaseService> increaseLateStartTaskByDocID(String? docID) async {
    var monthNow = getMonthAbbreviation(dateNow.month);
    var obj = {
      '$monthNow.${TaskStatusReport.Late_Start}': FieldValue.increment(1)
    };

    return await _firestoreService
        .updateData("${TableName.dbTaskStatusReportTable}/$docID", obj)
        .then((value) => BaseService('S', 'Success', null));
  }

  Future<TaskStatusReportModel> getTaskStatusReportModelByDocID(
      String? docId) async {
    DocumentSnapshot doc = await _firestoreService.getDocumentById(
        TableName.dbTaskStatusReportTable, docId!);
    return TaskStatusReportModel.fromDocumentSnapshot(doc);
  }
}
