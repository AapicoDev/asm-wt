import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/models/tasks_model.dart';
import 'package:asm_wt/service/base_service.dart';
import 'package:asm_wt/util/custom_func.dart';

class TasksService {
  final FirestoreService _firestoreService = FirestoreServiceImpl();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _taskRef =
      FirebaseFirestore.instance.collection(TableName.dbTasksTable);
  // final AuthService _authService = FirebaseAuthService();

  Future<TaskModel?> getTaskByTaskId(String taskId) async {
    final DocumentSnapshot snapshot =
        await _firestoreService.getDocumentById(TableName.dbTasksTable, taskId);

    if (snapshot.exists) {
      return TaskModel.fromDocumentSnapshot(snapshot);
    } else {
      print('Document does not exist');
      return null;
    }
  }

  Future<List<TaskModel>?> getCheckedTasksByDriverId(String? driverId) async {
    //return all tasks if collect`ion match with userID;
    List<DocumentSnapshot>? documentSnapshots = await _firestoreService
        .getDocumentsByDriverId(TableName.dbTasksTable, driverId);

    //map the result to the Task Model;
    if (documentSnapshots?.isNotEmpty ?? false) {
      final List<TaskModel> taskListMap = documentSnapshots!
          .map((documentSnapshot) =>
              TaskModel.fromDocumentSnapshot(documentSnapshot))
          .toList();
      return taskListMap;
    }

    return null;
  }

  Future<List<TaskModel>?> getRecentTasksByEmployeeRefID(
      String? employeeRefId) async {
    List<TaskModel> taskModelList = [];

    List<DocumentSnapshot>? documentSnapshots =
        await _firestoreService.getRecentDocumentByOneIdInside(
            TableName.dbTasksTable,
            "employeeRef",
            _firestore.doc("${TableName.dbEmployeeTable}/$employeeRefId"));

    if (documentSnapshots?.isNotEmpty ?? false) {
      for (var task in documentSnapshots!) {
        taskModelList.add(TaskModel.fromDocumentSnapshot(task));
      }

      return taskModelList;
    }

    return taskModelList;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRecentTasksSnapshotByDriverId(
      String? driverId) {
    return FirebaseFirestore.instance
        .collection(TableName.dbTasksTable)
        .where('driver_id', isEqualTo: driverId)
        .where('is_checked_in', isEqualTo: false)
        .where('driver_start_at', isNull: true)
        .orderBy('start_at')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTasksSnapshotByUserId(
      String? userId) {
    return FirebaseFirestore.instance
        .collection(TableName.dbTasksTable)
        .where('employee_id', isEqualTo: userId)
        .orderBy('start_time')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTodayTaskSnapshotByDriverId(
      String? driverId) {
    DateTime now = DateTime.now();
    DateTime dateNow = DateTime(now.year, now.month, now.day - 1);
    DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
    // final Timestamp nowTimeStamp = Timestamp.fromDate(dateNow);

    return FirebaseFirestore.instance
        .collection(TableName.dbTasksTable)
        .where('employee_id', isEqualTo: driverId)
        .where('is_disabled', isEqualTo: false)
        .where(Filter.or(Filter("status", isEqualTo: TaskStatus.Start),
            Filter("status", isEqualTo: TaskStatus.Confirm)))
        .where('start_time', isGreaterThan: dateNow, isLessThan: tomorrow)
        .orderBy('start_time')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStartTasksSnapshotByDriverId(
      String? driverId) {
    return FirebaseFirestore.instance
        .collection(TableName.dbTasksTable)
        .where('driver_id', isEqualTo: driverId)
        .where('is_checked_in', isEqualTo: false)
        .where('driver_start_at', isNull: false)
        .snapshots();
  }

  Future<BaseService> updateTaskStatusByTaskId(
      String? taskId, Map<String, dynamic> data) async {
    return await _firestoreService
        .updateData("${TableName.dbTasksTable}/$taskId", data)
        .then((value) => BaseService('S', 'Success', data));
  }

  Future<BaseService> createUserTaskNote(Map<String, dynamic> data) async {
    return await _taskRef
        .add(data)
        .then((value) => BaseService('S', 'Success', value.id));
  }

  Future<BaseService> deleteTaskNotedById(String taskId) async {
    return await _firestoreService
        .deleteData("${TableName.dbTasksTable}/$taskId")
        .then(
            (value) => BaseService('S', translate("message.successful"), null));
  }
}
