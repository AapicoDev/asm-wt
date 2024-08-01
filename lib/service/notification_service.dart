import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/service/base_service.dart';

class NotificationService {
  final FirestoreService _firestoreService = FirestoreServiceImpl();
  // final AuthService _authService = FirebaseAuthService();
  final CollectionReference _notificationRef =
      FirebaseFirestore.instance.collection(TableName.dbNotificationsTable);

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotificationSnapshotByDriverId(
      String? driverId) {
    return FirebaseFirestore.instance
        .collection(TableName.dbNotificationsTable)
        .where('to_id', isEqualTo: driverId)
        .orderBy('created_date', descending: true)
        .snapshots();
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

  Stream<QuerySnapshot<Map<String, dynamic>>>
      getNotificationMaintenanceByDriverId(String? driverId) {
    return FirebaseFirestore.instance
        .collection(TableName.dbNotificationsTable)
        .where('to_id', isEqualTo: driverId)
        .where('noti_code', isEqualTo: 'maintenance')
        .where('status', isEqualTo: 'approved')
        .where('view', isEqualTo: false)
        .orderBy('created_date')
        .snapshots();
  }

  Future<BaseService> updateNotificationById(
      String? notificationId, Map<String, dynamic> data) async {
    return await _firestoreService
        .updateData("${TableName.dbNotificationsTable}/$notificationId", data)
        .then((value) => BaseService('S', 'Success', data));
  }

  Future<BaseService> createMaintenanceNotification(
      Map<String, dynamic> data) async {
    return await _notificationRef
        .add(data)
        .then((value) => BaseService('S', 'Success', data));
  }
}
