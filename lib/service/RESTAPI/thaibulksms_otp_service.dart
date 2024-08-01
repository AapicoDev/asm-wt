import 'dart:async';
import 'dart:convert';
import 'package:asm_wt/models/thaibulksms_model.dart';
import 'package:asm_wt/service/base_service.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

class ThaiBulkOTPService extends ChangeNotifier {
  ThaiBulkSMSModel? thaiBulkSMSModel;

  Future<ThaiBulkSMSModel?> requestThaiBulkSmsOTP(String phonenumber) async {
    var obj = {
      "msisdn": phonenumber,
      "key": "1774454879201372",
      "secret": "1c347ed8e895eaf1aa54690fd80b5bde"
    };

    final result = await http
        .post(
      Uri.parse(bastOTPURL + "request"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(obj),
    )
        // ignore: body_might_complete_normally_catch_error
        .catchError((e) {
      print('Error Fetching Users');
    });

    if (result.statusCode == 200) {
      thaiBulkSMSModel = ThaiBulkSMSModel.fromDocumentSnapshot(
          JsonDecoder().convert(result.body));
      if (thaiBulkSMSModel?.status == 'success') {
        return thaiBulkSMSModel;
      }
      return null;
    } else {
      return null;
    }
  }

  Future<BaseService> verifyThaiBulkSmsOTP(Map<String, dynamic> data) async {
    final result = await http
        .post(
      Uri.parse(bastOTPURL + "verify"),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(data),
    )
        // ignore: body_might_complete_normally_catch_error
        .catchError((e) {
      print('Error Fetching Users');
    });

    if (result.statusCode == 200) {
      print(result.body);
      thaiBulkSMSModel = ThaiBulkSMSModel.fromDocumentSnapshot(
          JsonDecoder().convert(result.body));
      if (thaiBulkSMSModel?.status == 'success') {
        return BaseService('S', 'Success get data', thaiBulkSMSModel);
      }
      return BaseService('E', 'Something went wrong', result.body);
    } else {
      var error = JsonDecoder().convert(result.body);
      return BaseService('E', 'Data Not Found', error['errors'][0]['message']);
    }
  }
}
