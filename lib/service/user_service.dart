import 'dart:io';
import 'package:asm_wt/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/models/employee_model.dart';
import 'package:asm_wt/service/base_service.dart';

class UsersService {
  final FirestoreService _firestoreService = FirestoreServiceImpl();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection(TableName.dbEmployeeTable);
  final Reference _storageRef = FirebaseStorage.instance.ref();

  Future<UserModel?> getUserByUserId(String? userId) async {
    if (userId == null) return null;

    try {
      final snapshot = await _firestoreService.getDocumentById(
          TableName.dbEmployeeTable, userId);
      if (snapshot.exists) {
        return UserModel.fromDocumentSnapshot(snapshot);
      } else {
        print('Document does not exist');
        return null;
      }
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserSnapshotByStaffID(
      String? staffID) {
    try {
      return _firestore
          .collection(TableName.dbEmployeeTable)
          .where('employee_id', isEqualTo: staffID ?? '')
          .snapshots();
    } catch (e) {
      print('Error fetching user snapshot by staff ID: $e');
      rethrow; // rethrowing since this is a stream
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserSnapshotByUserId(
      String? userId) {
    try {
      return _firestore
          .collection(TableName.dbEmployeeTable)
          .where('employee_id', isEqualTo: userId ?? '')
          .snapshots();
    } catch (e) {
      print('Error fetching user snapshot by user ID: $e');
      rethrow;
    }
  }

  Future<EmployeeModel?> checkPhoneNumberIsExist(String? phoneNumber) async {
    if (phoneNumber == null) return null;

    try {
      final snapshot = await _firestoreService.getDocumentByOneIdInside(
          TableName.dbEmployeeTable, "phone_number", phoneNumber);

      return snapshot != null
          ? EmployeeModel.fromDocumentSnapshot(snapshot)
          : null;
    } catch (e) {
      print('Error checking if phone number exists: $e');
      return null;
    }
  }

  Future<List<EmployeeModel>?> getEmployeeByDepartmentId(
      String? departmentId) async {
    if (departmentId == null) return [];

    try {
      final snapshot = await _firestoreService.getRecentDocumentByOneIdInside(
        TableName.dbEmployeeTable,
        "departmentRef",
        _firestore.doc("${TableName.dbDepartmentTable}/$departmentId"),
      );

      return snapshot
              ?.map((data) => EmployeeModel.fromDocumentSnapshot(data))
              .toList() ??
          [];
    } catch (e) {
      print('Error fetching employees by department ID: $e');
      return [];
    }
  }

  Future<BaseService> createUserAccount(
      Map<String, dynamic> data, String userId) async {
    try {
      return await _userRef
          .doc(userId)
          .update(data)
          .then((_) =>
              BaseService('S', 'User account updated successfully', data))
          .catchError((error) =>
              BaseService('E', 'Failed to update user account: $error', null));
    } catch (e) {
      print('Error creating user account: $e');
      return BaseService('E', 'Failed to create user account', null);
    }
  }

  Future<BaseService> updateUserProfilePhotoByUserID(
      String? userID, XFile userProfileFile, String? previousImageName) async {
    if (userID == null) return BaseService('E', 'Invalid user ID', null);

    try {
      if (previousImageName != null) {
        await _storageRef
            .child("images/$userID/profile/$previousImageName")
            .delete();
      }

      final uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      final imageRefDir = _storageRef.child("images/$userID/profile");
      final refImageToUpload =
          imageRefDir.child("$uniqueFileName-${userProfileFile.name}");
      final imageFile = File(userProfileFile.path);

      await refImageToUpload.putFile(imageFile);
      final imageUrl = await refImageToUpload.getDownloadURL();

      final data = {
        'profile_url': imageUrl,
        'profile_file_name': "$uniqueFileName-${userProfileFile.name}",
      };

      return await _firestoreService
          .updateData("${TableName.dbEmployeeTable}/$userID", data)
          .then((_) =>
              BaseService('S', 'Profile photo updated successfully', data));
    } catch (e) {
      print('Error updating profile photo: $e');
      return BaseService('E', 'Failed to update profile photo', null);
    }
  }

  Future<BaseService> updateEmployeeActivatedStatusByEmpUID(
      String? empUID, Map<String, dynamic> data) async {
    if (empUID == null) return BaseService('E', 'Invalid employee UID', null);

    try {
      return await _firestoreService
          .updateData("${TableName.dbEmployeeTable}/$empUID", data)
          .then((_) =>
              BaseService('S', 'Employee status updated successfully', data))
          .catchError((error) => BaseService(
              'E', 'Failed to update employee status: $error', null));
    } catch (e) {
      print('Error updating employee status: $e');
      return BaseService('E', 'Failed to update employee status', null);
    }
  }

  Future<BaseService> updateUserInfoByUserId(
      String? userId, Map<String, dynamic> data) async {
    if (userId == null) return BaseService('E', 'Invalid user ID', null);

    try {
      return await _firestoreService
          .updateData("${TableName.dbEmployeeTable}/$userId", data)
          .then((_) => BaseService('S', 'User info updated successfully', data))
          .catchError((error) =>
              BaseService('E', 'Failed to update user info: $error', null));
    } catch (e) {
      print('Error updating user info: $e');
      return BaseService('E', 'Failed to update user info', null);
    }
  }
}
