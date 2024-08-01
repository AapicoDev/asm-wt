import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';

class FirestoreServiceImpl implements FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreServiceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(String path) {
    return _firestore.doc(path).get();
  }

  @override
  Future<DocumentSnapshot> getDocumentById(String collection, String id) async {
    final DocumentReference docRef = _firestore.collection(collection).doc(id);

    final DocumentSnapshot snapshot = await docRef.get();

    return snapshot;
  }

  @override
  Future<List<QueryDocumentSnapshot>?> getDocumentListByDriverId(
      String collection, String? driverId) async {
    // final now = DateTime.now();
    // DateTime dateNow = DateTime(now.year, now.month, now.day);
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(collection)
          .where('driver_id', isEqualTo: driverId)
          // .where('start_at', isGreaterThanOrEqualTo: dateNow) => select only today task to future task;
          .orderBy('created_date')
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final List<QueryDocumentSnapshot> snapshot = querySnapshot.docs;
        return snapshot;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // @override
  // Future<DocumentSnapshot?> getDocumentByUserId(
  //     String collection, String? userId) async {
  //   try {
  //     final QuerySnapshot querySnapshot = await _firestore
  //         .collection(collection)
  //         .where('userId', isEqualTo: userId)
  //         .limit(1)
  //         .get();
  //     if (querySnapshot.docs.isNotEmpty) {
  //       final DocumentSnapshot snapshot = querySnapshot.docs.first;
  //       return snapshot;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }

  @override
  Future<DocumentSnapshot?> getDocumentByOneIdInside(
      String collection, String feildCheck, String? insidId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(collection)
          .where(feildCheck, isEqualTo: insidId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final QueryDocumentSnapshot snapshot = querySnapshot.docs[0];
        return snapshot;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<DocumentSnapshot>?> getRecentDocumentByOneIdInside(
    String collection,
    String feildCheck1,
    DocumentReference insidId1,
  ) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(collection)
          .where(feildCheck1, isEqualTo: insidId1)
          // .where('start_at', isGreaterThanOrEqualTo: DateTime.now().toString())
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final List<QueryDocumentSnapshot> snapshot = querySnapshot.docs;
        return snapshot;
      } else {
        return [];
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<DocumentSnapshot>?> getRecentsDocumentByTwoIdInside(
    String collection,
    String feildCheck1,
    String? insidId1,
    String feildCheck2,
    String? insidId2,
  ) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(collection)
          // .where('start_at', isGreaterThanOrEqualTo: DateTime.now().toString())
          .where(feildCheck1, isEqualTo: insidId1)
          .where(feildCheck2,
              isEqualTo: insidId2 == "true"
                  ? true
                  : insidId2 == "false"
                      ? false
                      : insidId2)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final List<QueryDocumentSnapshot> snapshot = querySnapshot.docs;
        return snapshot;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<DocumentSnapshot>?> getDocumentsByDriverId(
      String collection, String? driverId) async {
    // final now = DateTime.now();
    // DateTime dateNow = DateTime(now.year, now.month, now.day);
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection(collection)
          .where('employee_id', isEqualTo: driverId)
          // .where('is_checked_in', isEqualTo: isCheckedIn)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        final List<QueryDocumentSnapshot> snapshot = querySnapshot.docs;
        return snapshot;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(String path) {
    return _firestore.collection(path).get();
  }

  @override
  Future<void> setData(String path, Map<String, dynamic> data) {
    return _firestore.collection(path).add(data);
  }

  @override
  Future<void> updateData(String path, Map<String, dynamic> data) {
    return _firestore.doc(path).update(data);
  }

  @override
  Future<void> deleteData(String path) {
    return _firestore.doc(path).delete();
  }
}

// class FireStoreService {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

//   Future<void> setupToken() async {
//     String? token = await _firebaseMessaging.getToken();
//     print('----token: ' + token!);

//     // Save the initial token to the database
//     await saveTokenToDatabase(token);

//     // Any time the token refreshes, store this in the database too.
//     _firebaseMessaging.onTokenRefresh.listen(saveTokenToDatabase);
//   }

//   Future<void> saveTokenToDatabase(String token) async {
//     // Assume user is logged in for this example
//     String? userId = _firebaseAuth.currentUser?.uid;
//     print(userId);

//     await _firebaseFirestore.collection('users').doc(userId).update({
//       'token': FieldValue.arrayUnion([token]),
//     });
//   }
// }