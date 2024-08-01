// ignore_for_file: no_leading_underscores_for_local_identifiers
import 'dart:async';
import 'dart:convert';
import 'package:asm_wt/models/manage_tasks_model.dart';
import 'package:asm_wt/service/base_service.dart';
import 'package:asm_wt/util/custom_func.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TaskManagementService extends ChangeNotifier {
  List<ManageTaskModel>? manageTaskModelList = [];
  final SharedPreferences prefs = GetIt.instance<SharedPreferences>();

  Future<List<ManageTaskModel>> getControllerTaskWithFilterDate(
      String? startDate, String? endDate) async {
    late String tableName = "task/";

    final result = await http.get(
        Uri.parse(baseFirebaseAdminURL +
            tableName +
            "getTaskController/${prefs.getString("userId")}?start=$startDate&end=$endDate"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // 'Authorization': 'Bearer $token',
          // ignore: body_might_complete_normally_catch_error
        }).catchError((e) {
      print('Error Fetching Users');
    });

    if (result.statusCode == 200) {
      if (result.body != []) {
        manageTaskModelList = [];

        var jsondata = const JsonDecoder().convert(result.body);
        for (var data in jsondata["data"]) {
          ManageTaskModel manageTaskModel =
              ManageTaskModel.fromMapStringDynamice(data);

          if (manageTaskModel.status != TaskStatus.Done &&
              manageTaskModel.driverStartAt == null) {
            var canCheckTask =
                manageTaskModel.start_date?.compareTo(DateTime.now());
            if (canCheckTask != null) {
              if (canCheckTask == 0 || canCheckTask < 0) {
                manageTaskModel.clock_in_status = ClockStatus.NotYetStart;
              }
            }
          }

          manageTaskModelList?.add(manageTaskModel);
        }
        notifyListeners();

        return [];
      } else {
        return [];
      }
    } else {
      return [];
    }
  }
}
