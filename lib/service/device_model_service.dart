import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/models/devices_model.dart';
import 'package:asm_wt/service/base_service.dart';

class AllDevicesService {
  final FirestoreService _firestoreService = FirestoreServiceImpl();

  Future<BaseService> incrementDeviceValueByOrganizationID(String orgID) async {
    if (orgID.isEmpty) {
      return BaseService('F', 'Organization ID is empty', null);
    }
    final field = Platform.isAndroid
        ? "android"
        : Platform.isIOS
            ? "ios"
            : null;
    if (field == null) {
      return BaseService('E', "Unsupported platform", null);
    }

    try {
      await _firestoreService.updateData(
          "${TableName.dbAllDevicesTable}/$orgID",
          {field: FieldValue.increment(1)});
      return BaseService('S', 'Success', null);
    } catch (e) {
      print('Error incrementing device value: $e');
      return BaseService('E', 'Error incrementing device value', null);
    }
  }

  Future<BaseService> reductionDeviceValueByOrganizationID(String orgID) async {
    if (orgID.isEmpty) {
      return BaseService('F', 'Organization ID is empty', null);
    }
    final field = Platform.isAndroid
        ? "android"
        : Platform.isIOS
            ? "ios"
            : null;
    if (field == null) {
      return BaseService('E', "Unsupported platform", null);
    }

    try {
      await _firestoreService.updateData(
          "${TableName.dbAllDevicesTable}/$orgID",
          {field: FieldValue.increment(-1)});
      return BaseService('S', 'Success', null);
    } catch (e) {
      print('Error reducing device value: $e');
      return BaseService('E', 'Error reducing device value', null);
    }
  }

  Future<DevicesModel?> getAllDevicesModelByOrganizationID(String orgID) async {
    if (orgID.isEmpty) {
      print('Organization ID is empty');
      return null;
    }
    try {
      DocumentSnapshot doc = await _firestoreService
          .getDocument("${TableName.dbAllDevicesTable}/$orgID");
      return DevicesModel.fromDocumentSnapshot(doc);
    } catch (e) {
      print('Error retrieving device model: $e');
      return null;
    }
  }
}
