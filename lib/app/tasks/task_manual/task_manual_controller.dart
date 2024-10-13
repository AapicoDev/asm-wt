import 'package:asm_wt/service/appwrite_service.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import 'package:intl/intl.dart';

class TaskManualProvider extends ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService();

  DocumentList? _taskData;
  bool _isLoading = false;

  DocumentList? get taskData => _taskData;
  bool get isLoading => _isLoading;

  Future<void> saveClockInData(
      String userId, Map<String, dynamic> clockInData) async {
    try {
      // Replace 'your_collection_id' with your actual collection ID
      await _appwriteService.saveClockIn({
        'emp_id': userId,
        ...clockInData,
      });
      notifyListeners();
    } catch (error) {
      throw Exception('Failed to save clock-in data: $error');
    }
  }

  Future<void> fetchTaskData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _taskData = await _appwriteService.getTaskData(userId);
    } catch (e) {
      print('Error fetching task data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
