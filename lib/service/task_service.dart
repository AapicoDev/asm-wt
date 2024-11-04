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

  Future<TaskModel?> getTaskByTaskId(String taskId) async {
    try {
      final DocumentSnapshot snapshot = await _firestoreService.getDocumentById(
          TableName.dbTasksTable, taskId);
      if (snapshot.exists) {
        return TaskModel.fromDocumentSnapshot(snapshot);
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching task by task ID: $e');
      return null;
    }
  }

  Future<List<TaskModel>?> getCheckedTasksByDriverId(String? driverId) async {
    if (driverId == null || driverId.isEmpty) return null;

    try {
      List<DocumentSnapshot>? documentSnapshots = await _firestoreService
          .getDocumentsByDriverId(TableName.dbTasksTable, driverId);
      if (documentSnapshots?.isNotEmpty ?? false) {
        return documentSnapshots!
            .map((snapshot) => TaskModel.fromDocumentSnapshot(snapshot))
            .toList();
      }
      return null;
    } catch (e) {
      print('Error fetching checked tasks by driver ID: $e');
      return null;
    }
  }

  Future<List<TaskModel>?> getRecentTasksByEmployeeRefID(
      String? employeeRefId) async {
    if (employeeRefId == null || employeeRefId.isEmpty) return [];

    try {
      List<DocumentSnapshot>? documentSnapshots =
          await _firestoreService.getRecentDocumentByOneIdInside(
              TableName.dbTasksTable,
              "employeeRef",
              _firestore.doc("${TableName.dbEmployeeTable}/$employeeRefId"));

      if (documentSnapshots?.isNotEmpty ?? false) {
        return documentSnapshots!
            .map((task) => TaskModel.fromDocumentSnapshot(task))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching recent tasks by employeeRefId: $e');
      return [];
    }
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      getRecentTasksSnapshotByDriverId(String? driverId) async {
    try {
      if (driverId == null || driverId.isEmpty) return Stream.empty();

      return _firestore
          .collection(TableName.dbTasksTable)
          .where('driver_id', isEqualTo: driverId)
          .where('is_checked_in', isEqualTo: false)
          .where('driver_start_at', isNull: true)
          .orderBy('start_at')
          .snapshots();
    } catch (e) {
      print('Error fetching recent tasks snapshot by driver ID: $e');
      return Stream.error('Error fetching recent tasks snapshot');
    }
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>> getTasksSnapshotByUserId(
      String? userId) async {
    try {
      if (userId == null || userId.isEmpty) return Stream.empty();

      DateTime startDate = DateTime.now().subtract(Duration(days: 15));
      DateTime endDate = DateTime.now().add(Duration(days: 5));

      return _firestore
          .collection(TableName.dbTasksTable)
          .where('employee_id', isEqualTo: userId)
          .where('status', isNotEqualTo: TaskStatus.Delete)
          .where('start_time', isGreaterThanOrEqualTo: startDate)
          .where('start_time', isLessThanOrEqualTo: endDate)
          .orderBy('start_time')
          .snapshots();
    } catch (e) {
      print('Error fetching tasks snapshot by user ID: $e');
      return Stream.error('Error fetching tasks snapshot');
    }
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      getTodayTaskSnapshotByDriverId(String? driverId) async {
    try {
      if (driverId == null || driverId.isEmpty) return Stream.empty();

      DateTime now = DateTime.now();
      DateTime dateNow = DateTime(now.year, now.month, now.day - 1);
      DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);

      return _firestore
          .collection(TableName.dbTasksTable)
          .where('employee_id', isEqualTo: driverId)
          .where('is_disabled', isEqualTo: false)
          .where(Filter.or(Filter("status", isEqualTo: TaskStatus.Start),
              Filter("status", isEqualTo: TaskStatus.Confirm)))
          .where('start_time', isGreaterThan: dateNow, isLessThan: tomorrow)
          .orderBy('start_time')
          .snapshots();
    } catch (e) {
      print('Error fetching today task snapshot by driver ID: $e');
      return Stream.error('Error fetching today task snapshot');
    }
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      getStartTasksSnapshotByDriverId(String? driverId) async {
    try {
      if (driverId == null || driverId.isEmpty) return Stream.empty();

      return _firestore
          .collection(TableName.dbTasksTable)
          .where('driver_id', isEqualTo: driverId)
          .where('is_checked_in', isEqualTo: false)
          .where('driver_start_at', isNull: false)
          .snapshots();
    } catch (e) {
      print('Error fetching start tasks snapshot by driver ID: $e');
      return Stream.error('Error fetching start tasks snapshot');
    }
  }

  Future<BaseService> updateTaskStatusByTaskId(
      String? taskId, Map<String, dynamic> data) async {
    if (taskId == null || taskId.isEmpty)
      return BaseService('F', 'Invalid task ID', null);

    try {
      await _firestoreService.updateData(
          "${TableName.dbTasksTable}/$taskId", data);
      return BaseService('S', 'Success', data);
    } catch (e) {
      print('Error updating task status by task ID: $e');
      return BaseService('F', 'Failed to update task status', null);
    }
  }

  Future<BaseService> createUserTaskNote(Map<String, dynamic> data) async {
    try {
      DocumentReference docRef = await _taskRef.add(data);
      return BaseService('S', 'Success', docRef.id);
    } catch (e) {
      print('Error creating user task note: $e');
      return BaseService('F', 'Failed to create user task note', null);
    }
  }

  Future<BaseService> deleteTaskNotedById(String taskId) async {
    if (taskId == null || taskId.isEmpty)
      return BaseService('F', 'Invalid task ID', null);

    try {
      await _firestoreService.deleteData("${TableName.dbTasksTable}/$taskId");
      return BaseService('S', translate("message.successful"), null);
    } catch (e) {
      print('Error deleting task note by ID: $e');
      return BaseService('F', 'Failed to delete task note', null);
    }
  }
}
