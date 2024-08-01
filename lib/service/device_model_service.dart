import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/models/devices_model.dart';
import 'package:asm_wt/service/base_service.dart';

class AllDevicesService {
  final FirestoreService _firestoreService = FirestoreServiceImpl();
  // final AuthService _authService = FirebaseAuthService();
  // final CollectionReference _newFeedsRef =
  //     FirebaseFirestore.instance.collection(TableName.dbAllDevicesTable);

  Future<BaseService> incrementDeviceValueByOrganizationID(
      String? orgID) async {
    if (Platform.isAndroid) {
      return await _firestoreService.updateData(
          "${TableName.dbAllDevicesTable}/$orgID", {
        "android": FieldValue.increment(1)
      }).then((value) => BaseService('S', 'Success', null));
    } else if (Platform.isIOS) {
      return await _firestoreService.updateData(
          "${TableName.dbAllDevicesTable}/$orgID", {
        "ios": FieldValue.increment(1)
      }).then((value) => BaseService('S', 'Success', null));
    }
    return BaseService('E', "Something Went Wrong", null);
  }

  Future<BaseService> reductionDeviceValueByOrganizationID(
      String? orgID) async {
    if (Platform.isAndroid) {
      return await _firestoreService.updateData(
          "${TableName.dbAllDevicesTable}/$orgID", {
        "android": FieldValue.increment(-1)
      }).then((value) => BaseService('S', 'Success', null));
    } else if (Platform.isIOS) {
      return await _firestoreService.updateData(
          "${TableName.dbAllDevicesTable}/$orgID", {
        "ios": FieldValue.increment(-1)
      }).then((value) => BaseService('S', 'Success', null));
    }
    return BaseService('E', "Something Went Wrong", null);
  }

  Future<DevicesModel> getAllDevicesModelByOrganizationID(String orgID) async {
    DocumentSnapshot doc = await _firestoreService
        .getDocument("${TableName.dbAllDevicesTable}/$orgID");
    return DevicesModel.fromDocumentSnapshot(doc);
  }
}
