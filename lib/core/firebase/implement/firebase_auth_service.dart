import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:asm_wt/core/firebase/auth_service.dart';
import 'package:asm_wt/core/firebase/firestore_service.dart';
import 'package:asm_wt/core/firebase/implement/firestore_service_impl.dart';
import 'package:asm_wt/models/employee_model.dart';
import 'package:asm_wt/service/base_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dbcrypt/dbcrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreServiceImpl();
  DBCrypt dBCrypt = DBCrypt();
  final CollectionReference _drivers =
      FirebaseFirestore.instance.collection(TableName.dbEmployeeTable);

  @override
  Future<BaseService> signInWithUsernameAndPassword(
      String username, String password) async {
    try {
      QuerySnapshot snapshot =
          await _drivers.where('username', isEqualTo: username).get();

      if (snapshot.docs.length == 1) {
        DocumentSnapshot document = snapshot.docs[0];
        String driverPassword = document['password'];

        if (dBCrypt.checkpw(password, driverPassword)) {
          String email = document['email'];
          // Authentication successful.
          return await signInWithEmailAndPassword(email, password);
        }
      }

      // Authentication failed.
      return BaseService('E', 'Authenication Fail', null);
    } catch (e) {
      // Authentication failed.
      return BaseService('E', 'Error Sign In', e);
    }
  }

  @override
  Future<BaseService> signInWithEmailAndPassword(
      String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user?.uid != null) {
        await prefs.setString(
            'username', userCredential.user?.displayName ?? '');
        await prefs.setString('userId', userCredential.user?.uid ?? '');
        await prefs.setString('email', userCredential.user?.email ?? '');
        getUserToken(userCredential.user?.uid);
        var message =
            BaseService('S', 'Success Login', userCredential.user?.uid);
        return message;
      }

      return BaseService('E', 'No user found.', null);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
        case "account-exists-with-different-credential":
        case "email-already-in-use":
          return BaseService(
              'E', 'Email already used. Go to login page.', null);
        case "ERROR_WRONG_PASSWORD":
        case "wrong-password":
          return BaseService('E', 'Wrong email/password combination.', null);
        case "ERROR_USER_NOT_FOUND":
        case "user-not-found":
          return BaseService('E', 'No user found with this email.', null);
        case "ERROR_USER_DISABLED":
        case "user-disabled":
          return BaseService('E', 'User disabled.', null);
        case "ERROR_TOO_MANY_REQUESTS":
        case "operation-not-allowed":
          return BaseService(
              'E', 'Too many requests to log into this account.', null);
        case "ERROR_OPERATION_NOT_ALLOWED":
          return BaseService(
              'E', 'Server error, please try again later.', null);
        case "ERROR_INVALID_EMAIL":
        case "invalid-email":
          return BaseService('E', 'Email address is invalid.', null);
        default:
          return BaseService('E', 'Login failed. Please try again.', null);
      }
    }
  }

  @override
  Future<User?> currentUser() async {
    var user = _firebaseAuth.currentUser;
    if (user?.uid != null) {
      return user!;
    } else {
      return null;
    }
  }

  @override
  Future<String?> getUserToken(String? userId) async {
    var token;
    _firebaseMessaging.deleteToken().then((value) async => {
          token = await _firebaseMessaging.getToken(),
          if (token!.isNotEmpty)
            {
              saveToken(token, userId ?? ''),
            }
        });

    return token;
  }

  Future<void> saveToken(String token, String userId) async {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['device_token'] = token;
    await _firestoreService.updateData(
        "${TableName.dbEmployeeTable}/$userId", data);
  }

  @override
  Future<EmployeeModel?> getDriverInfo(String? driverId) async {
    try {
      DocumentSnapshot documentSnapshot = await _drivers.doc(driverId).get();
      if (documentSnapshot.exists) {
        // Authentication failed.
        return EmployeeModel.fromDocumentSnapshot(documentSnapshot);
      }
      return null;
    } catch (e) {
      // Authentication failed.
      return null;
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    // final prefs = await SharedPreferences.getInstance();
    var user = _firebaseAuth.currentUser;
    if (user?.uid != null) {
      return user!.uid;
    } else {
      return null;
    }

    // return prefs.getString("userId");
  }

  @override
  Future<BaseService> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return BaseService('S', 'Successful Sign out', null);
    } catch (e) {
      return BaseService('E', 'Error While sign out!', e);
    }
  }
}
