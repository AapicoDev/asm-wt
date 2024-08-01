import 'package:cloud_firestore/cloud_firestore.dart';

abstract class FirestoreService {
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String path);
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(String path);
  Future<DocumentSnapshot> getDocumentById(String collection, String id);
  // Future<DocumentSnapshot?> getDocumentByUserId(
  //     String collection, String? userId);
  Future<DocumentSnapshot?> getDocumentByOneIdInside(
      String collection, String feildCheck, String? insidId);
  Future<List<DocumentSnapshot>?> getRecentsDocumentByTwoIdInside(
      String collection,
      String feildCheck1,
      String? insidId1,
      String feildCheck2,
      String? insidId2);
  Future<List<DocumentSnapshot>?> getRecentDocumentByOneIdInside(
      String collection, String feildCheck1, DocumentReference insidId1);
  Future<List<DocumentSnapshot>?> getDocumentsByDriverId(
      String collection, String? driverId);
  Future<List<QueryDocumentSnapshot>?> getDocumentListByDriverId(
      String collection, String? driverId);
  Future<void> setData(String path, Map<String, dynamic> data);
  Future<void> updateData(String path, Map<String, dynamic> data);
  Future<void> deleteData(String path);
}
