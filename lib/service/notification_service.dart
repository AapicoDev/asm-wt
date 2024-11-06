import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/service/base_service.dart';

class NotificationService {
  final FirestoreService _firestoreService = FirestoreServiceImpl();
  final CollectionReference _notificationRef =
      FirebaseFirestore.instance.collection(TableName.dbNotificationsTable);

  Future<Stream<QuerySnapshot<Object?>>> getNotificationSnapshotByDriverId(
      String driverId) async {
    try {
      return _notificationRef
          .where('to_id', isEqualTo: driverId)
          .orderBy('created_date', descending: true)
          .snapshots();
    } catch (e) {
      print('Error fetching notifications: $e');
      return Stream.error('Error fetching notifications');
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUnseenItemsSnapshotByDriverId(
      String? driverId) {
    return FirebaseFirestore.instance
        .collection(TableName.dbNotificationsTable)
        .where('to_id', isEqualTo: driverId)
        .where('view', isEqualTo: false)
        .orderBy('created_date')
        .snapshots();
  }

  Stream<QuerySnapshot<Object?>> getNotificationMaintenanceByDriverId(
      String driverId) {
    return _notificationRef
        .where('to_id', isEqualTo: driverId)
        .where('noti_code', isEqualTo: 'maintenance')
        .where('status', isEqualTo: 'approved')
        .where('view', isEqualTo: false)
        .orderBy('created_date')
        .snapshots()
        .handleError((e) {
      print('Error fetching maintenance notifications: $e');
    });
  }

  Future<BaseService> updateNotificationById(
      String notificationId, Map<String, dynamic> data) async {
    if (notificationId.isEmpty) {
      return BaseService('F', 'Notification ID is empty', {});
    }

    try {
      await _firestoreService.updateData(
          "${TableName.dbNotificationsTable}/$notificationId", data);
      return BaseService('S', 'Success', data);
    } catch (e) {
      print('Error updating notification: $e');
      return BaseService('F', 'Error updating notification', {});
    }
  }

  Future<BaseService> createMaintenanceNotification(
      Map<String, dynamic> data) async {
    try {
      await _notificationRef.add(data);
      return BaseService('S', 'Success', data);
    } catch (e) {
      print('Error creating maintenance notification: $e');
      return BaseService('F', 'Error creating notification', {});
    }
  }
}
