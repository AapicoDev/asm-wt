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
  final storageRef = FirebaseStorage.instance.ref();
  // final AuthService _authService = FirebaseAuthService();

  Future<UserModel?> getUserByUserId(String? userId) async {
    final DocumentSnapshot snapshot = await _firestoreService.getDocumentById(
        TableName.dbEmployeeTable, userId ?? '');

    if (snapshot.exists) {
      return UserModel.fromDocumentSnapshot(snapshot);
    } else {
      print('Document does not exist');
      return null;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserSnapshotByStaffID(
      String? staffID) {
    return FirebaseFirestore.instance
        .collection(TableName.dbEmployeeTable)
        .where('employee_id', isEqualTo: staffID)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserSnapshotByUserId(
      String? userId) {
    return FirebaseFirestore.instance
        .collection(TableName.dbEmployeeTable)
        .where('employee_id', isEqualTo: userId)
        .snapshots();
  }

  Future<EmployeeModel?> checkPhoneNumberIsExist(String? phoneNumber) async {
    EmployeeModel? userModel;

    await _firestoreService
        .getDocumentByOneIdInside(
            TableName.dbEmployeeTable, "phone_number", phoneNumber)
        .then((snapshot) => {
              if (snapshot != null)
                {
                  userModel = EmployeeModel.fromDocumentSnapshot(snapshot),
                }
            });

    return userModel;
  }

  Future<List<EmployeeModel>?> getEmployeeByDepartmentId(
      String? departmentId) async {
    List<EmployeeModel> userModel = [];

    await _firestoreService
        .getRecentDocumentByOneIdInside(
            TableName.dbEmployeeTable,
            "departmentRef",
            _firestore.doc("${TableName.dbDepartmentTable}/$departmentId"))
        .then((snapshot) => {
              if (snapshot != null)
                {
                  for (var data in snapshot)
                    {
                      userModel.add(EmployeeModel.fromDocumentSnapshot(data)),
                    }
                }
            });

    return userModel;
  }

  Future<BaseService> createUserAccount(
      Map<String, dynamic> data, String userId) async {
    return await _userRef
        .doc(userId)
        .update(data)
        .then((value) => BaseService('S', '', data));
  }

  Future<BaseService> updateUserProfilPhotoByUserID(
      String? userID, XFile userProfileFile, String? previousImageName) async {
    //uploade image to fire storage;
    Map<String, dynamic> data = <String, dynamic>{};

    String uniuqeFileName = DateTime.now().millisecondsSinceEpoch.toString();

    //empty folder before upload a new one;
    storageRef.child("images/$userID/profile/$previousImageName").delete();
    final imageRefDir = storageRef.child("images/$userID/profile");
    final imageFile = File(userProfileFile.path);

    final refImageToUpload =
        imageRefDir.child("$uniuqeFileName-${userProfileFile.name}");
    try {
      await refImageToUpload.putFile(imageFile);
      var imageUrl = await refImageToUpload.getDownloadURL();
      data['profile_url'] = imageUrl;
      data['profile_file_name'] = "$uniuqeFileName-${userProfileFile.name}";

      // ignore: unused_catch_clause
    } on FirebaseException catch (e) {
      // ...
    }

    return await _firestoreService
        .updateData("${TableName.dbEmployeeTable}/$userID", data)
        .then((value) => BaseService('S', 'Success', data));
  }

  Future<BaseService> updateEmployeeAtivatedStatusByEmpUID(
      String? empUID, Map<String, dynamic> data) async {
    return await _firestoreService
        .updateData("${TableName.dbEmployeeTable}/$empUID", data)
        .then((value) => BaseService('S', 'Success', data));
  }

  Future<BaseService> updateUserInfoByUserId(
      String? userId, Map<String, dynamic> data) async {
    return await _firestoreService
        .updateData("${TableName.dbEmployeeTable}/$userId", data)
        .then((value) => BaseService('S', 'Success', data));
  }
}
