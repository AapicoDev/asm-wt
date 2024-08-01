import 'dart:async';
import 'package:asm_wt/models/employee_model.dart';
import 'package:asm_wt/service/base_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  Future<BaseService> signInWithEmailAndPassword(String email, String password);
  Future<BaseService> signInWithUsernameAndPassword(
      String username, String password);
  Future<EmployeeModel?> getDriverInfo(String? driverId);
  Future<User?> currentUser();
  Future<String?> getCurrentUserId();
  Future<String?> getUserToken(String? userId);
  Future<void> signOut();
  // Future<String> createUserWithEmailAndPassword(String email, String password);
}
