import 'dart:convert';

import 'package:asm_wt/models/location_model.dart';
import 'package:asm_wt/service/appwrite_service.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/models.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

class TaskManualProvider extends ChangeNotifier {
  final AppwriteService _appwriteService = AppwriteService();

  DocumentList? _taskData;
  bool _isLoading = false;

  DocumentList? get taskData => _taskData;
  bool get isLoading => _isLoading;

  Future<String?> saveClockInData(
      String userId, Map<String, dynamic> clockInData) async {
    try {
      // Replace 'your_collection_id' with your actual collection ID
      var saveData = await _appwriteService.saveClockIn({
        'emp_id': userId,
        ...clockInData,
      });
      notifyListeners();
      return saveData.$id;
    } catch (error) {
      debugPrint('Failed to save clock-in data: $error');
      return null;
    }
  }

  Future<String?> updateClockInData(
      String clockInId, Map<String, dynamic> clockInData) async {
    try {
      // Replace 'your_collection_id' with your actual collection ID
      var saveData = await _appwriteService.updateClockIn(clockInId, {
        ...clockInData,
      });
      notifyListeners();
      return saveData.$id;
    } catch (error) {
      debugPrint('Failed to save clock-in data: $error');
      return null;
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

  Future<LocationModel?> getAreaName(lat, lng) async {
    try {
      var dio = Dio();
      var response = await dio.request(
        'https://api.powermap.live/api/geofence/geofencing-checkpoint?lat=${lat}&lng=${lng}&organization=asm',
        options: Options(
          method: 'GET',
        ),
      );

      print(response.statusCode);
      print(response.data);
      if (response.statusCode == 200) {
        if (jsonEncode(response.data).length > 0) {
          return LocationModel.fromJson(response.data[0]);
        } else {
          return null;
        }
      } else {
        print(response.statusMessage);
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
