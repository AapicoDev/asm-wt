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

  Future<Stream<QuerySnapshot<Object?>>> getUnseenItemsSnapshotByDriverId(
      String driverId) async {
    try {
      return _notificationRef
          .where('to_id', isEqualTo: driverId)
          .where('view', isEqualTo: false)
          .orderBy('created_date')
          .snapshots();
    } catch (e) {
      print('Error fetching unseen items: $e');
      return Stream.error('Error fetching unseen items');
    }
  }

  Future<Stream<QuerySnapshot<Object?>>> getNotificationMaintenanceByDriverId(
      String driverId) async {
    try {
      return _notificationRef
          .where('to_id', isEqualTo: driverId)
          .where('noti_code', isEqualTo: 'maintenance')
          .where('status', isEqualTo: 'approved')
          .where('view', isEqualTo: false)
          .orderBy('created_date')
          .snapshots();
    } catch (e) {
      print('Error fetching maintenance notifications: $e');
      return Stream.error('Error fetching maintenance notifications');
    }
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
