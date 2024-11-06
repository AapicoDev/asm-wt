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
  final DBCrypt dBCrypt = DBCrypt();
  final CollectionReference _drivers =
      FirebaseFirestore.instance.collection(TableName.dbEmployeeTable);

  @override
  Future<BaseService> signInWithUsernameAndPassword(
      String username, String password) async {
    try {
      if (username.isEmpty || password.isEmpty) {
        return BaseService('E', 'Username and password required', null);
      }

      QuerySnapshot snapshot =
          await _drivers.where('username', isEqualTo: username).get();

      if (snapshot.docs.length == 1) {
        DocumentSnapshot document = snapshot.docs[0];
        String driverPassword = document['password'];

        if (dBCrypt.checkpw(password, driverPassword)) {
          String email = document['email'];
          return await signInWithEmailAndPassword(email, password);
        }
      }
      return BaseService('E', 'Authentication Failed', null);
    } catch (e) {
      return BaseService('E', 'Error Signing In', e);
    }
  }

  @override
  Future<BaseService> signInWithEmailAndPassword(
      String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      if (email.isEmpty || password.isEmpty) {
        return BaseService('E', 'Email and password required', null);
      }

      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user?.uid != null) {
        await prefs.setString(
            'username', userCredential.user?.displayName ?? '');
        await prefs.setString('userId', userCredential.user?.uid ?? '');
        await prefs.setString('email', userCredential.user?.email ?? '');
        await getUserToken(userCredential.user?.uid);
        return BaseService('S', 'Success Login', userCredential.user?.uid);
      }
      return BaseService('E', 'No user found', null);
    } on FirebaseAuthException catch (e) {
      // Handling FirebaseAuthException cases.
      return _handleAuthException(e);
    }
  }

  BaseService _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case "email-already-in-use":
        return BaseService('E', 'Email already in use. Please login.', null);
      case "wrong-password":
        return BaseService('E', 'Incorrect email/password combination.', null);
      case "user-not-found":
        return BaseService('E', 'No user found with this email.', null);
      case "user-disabled":
        return BaseService('E', 'User account disabled.', null);
      case "operation-not-allowed":
        return BaseService('E', 'Too many requests. Try again later.', null);
      case "invalid-email":
        return BaseService('E', 'Invalid email address.', null);
      default:
        return BaseService('E', 'Login failed. Please try again.', null);
    }
  }

  @override
  Future<User?> currentUser() async {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<String?> getUserToken(String? userId) async {
    if (userId == null || userId.isEmpty) return null;

    try {
      await _firebaseMessaging.deleteToken();
      String? token = await _firebaseMessaging.getToken();
      if (token != null && token.isNotEmpty) {
        await saveToken(token, userId);
      }
      return token;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveToken(String token, String userId) async {
    try {
      if (token.isNotEmpty && userId.isNotEmpty) {
        final Map<String, dynamic> data = {'device_token': token};
        await _firestoreService.updateData(
            "${TableName.dbEmployeeTable}/$userId", data);
      }
    } catch (e) {
      // Handle token save error.
    }
  }

  @override
  Future<EmployeeModel?> getDriverInfo(String? driverId) async {
    if (driverId == null || driverId.isEmpty) return null;

    try {
      DocumentSnapshot documentSnapshot = await _drivers.doc(driverId).get();
      if (documentSnapshot.exists) {
        return EmployeeModel.fromDocumentSnapshot(documentSnapshot);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _firebaseAuth.currentUser?.uid;
  }

  @override
  Future<BaseService> signOut() async {
    try {
      await _firebaseAuth.signOut();
      return BaseService('S', 'Successful sign out', null);
    } catch (e) {
      return BaseService('E', 'Error signing out', e);
    }
  }
}
