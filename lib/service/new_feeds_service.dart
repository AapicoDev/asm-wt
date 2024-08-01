import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/service/base_service.dart';

class NewFeedsService {
  final FirestoreService _firestoreService = FirestoreServiceImpl();
  // final AuthService _authService = FirebaseAuthService();
  final CollectionReference _newFeedsRef =
      FirebaseFirestore.instance.collection(TableName.dbNewFeedsTable);

  Future<BaseService> updateNewFeedById(
      String? newFeedsId, Map<String, dynamic> data) async {
    return await _firestoreService
        .updateData("${TableName.dbNewFeedsTable}/$newFeedsId", data)
        .then((value) => BaseService('S', 'Success', data));
  }

  Future<BaseService> createNewFeedWithCustomID(
      Map<String, dynamic> data) async {
    return await _newFeedsRef
        .add(data)
        .then((value) => BaseService('S', 'Success', data));
  }

  Future<BaseService> createNewFeeds(Map<String, dynamic> data) async {
    return await _firestoreService
        .setData(TableName.dbNewFeedsTable, data)
        .then((value) => BaseService('S', 'Success', data));
  }
}
