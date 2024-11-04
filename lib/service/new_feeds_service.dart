import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/service/base_service.dart';

class NewFeedsService {
  final FirestoreService _firestoreService = FirestoreServiceImpl();
  final CollectionReference _newFeedsRef =
      FirebaseFirestore.instance.collection(TableName.dbNewFeedsTable);

  Future<BaseService> updateNewFeedById(
      String newFeedsId, Map<String, dynamic> data) async {
    if (newFeedsId.isEmpty) {
      return BaseService('F', 'New Feed ID is empty', {});
    }

    try {
      await _firestoreService.updateData(
          "${TableName.dbNewFeedsTable}/$newFeedsId", data);
      return BaseService('S', 'Success', data);
    } catch (e) {
      print('Error updating new feed: $e');
      return BaseService('F', 'Error updating new feed', {});
    }
  }

  Future<BaseService> createNewFeedWithCustomID(
      Map<String, dynamic> data) async {
    try {
      await _newFeedsRef.add(data);
      return BaseService('S', 'Success', data);
    } catch (e) {
      print('Error creating new feed with custom ID: $e');
      return BaseService('F', 'Error creating new feed', {});
    }
  }

  Future<BaseService> createNewFeeds(Map<String, dynamic> data) async {
    try {
      await _firestoreService.setData(TableName.dbNewFeedsTable, data);
      return BaseService('S', 'Success', data);
    } catch (e) {
      print('Error creating new feeds: $e');
      return BaseService('F', 'Error creating new feeds', {});
    }
  }
}
