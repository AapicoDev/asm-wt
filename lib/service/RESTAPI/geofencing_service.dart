// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'package:asm_wt/models/geo_area_model.dart';
import 'package:asm_wt/models/geofence_model.dart';
import 'package:asm_wt/service/base_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeoFencingService extends ChangeNotifier {
  List<GeoFenceStrapiAPIModel> geofenceStrapiAPIList = [];
  GeoFenceStrapiAPIModel geoDataStrapiApi = GeoFenceStrapiAPIModel();
  List<GeoFenceDataModel>? geoDataList;
  GeoFenceDataModel geoData = GeoFenceDataModel();
  Map<String, dynamic> feature = <String, dynamic>{};
  List<Map<String, dynamic>> features = [];
  Map<String, dynamic> geoJsonData = <String, dynamic>{};
  bool isHasGeofence = false;
  List<AreaModel> geoAreadList = [];
  AreaModel areaModel = AreaModel();
  List<String>? clockInOutAreaNameEn;
  List<String>? clockInOutAreaNameTh;
  final SharedPreferences prefs = GetIt.instance<SharedPreferences>();

  Future<BaseService> confirmInGeofencingArea(LatLng? latLng) async {
    geoAreadList = [];
    clockInOutAreaNameEn = [];
    clockInOutAreaNameTh = [];
    notifyListeners();
    late String customerURL =
        "geofence/geofencing-checkpoint?lat=${latLng?.latitude}&lng=${latLng?.longitude}&organization=${prefs.getString("organizationId")}";

    final result = await http.get(Uri.parse(baseURL + customerURL), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // 'Authorization': 'Bearer $token',
      // ignore: body_might_complete_normally_catch_error
    }).catchError((e) {
      print('Error Fetching Users');
    });

    if (result.statusCode == 200) {
      if (result.body != []) {
        var jsondata = const JsonDecoder().convert(result.body);
        for (var data in jsondata) {
          areaModel = AreaModel.fromDocumentSnapshot(data);
          geoAreadList.add(areaModel);
          clockInOutAreaNameEn?.add(areaModel.name_en ?? '');
          clockInOutAreaNameTh?.add(areaModel.name_th ?? '');
          notifyListeners();
        }
        return BaseService('S', 'Success get  customers data', geoAreadList);
      } else {
        return BaseService('E', 'Data Not Found', result.body);
      }
    } else {
      return BaseService('E', 'Data Not Found', result.body);
    }
  }

  Future<BaseService> getGeofencingAreaByOrganizationId() async {
    late String customerURL =
        "geofences?filters[organizations][abbreviation][\$eq]=${prefs.getString("organizationId")}";
    geoDataList = [];
    features = [];
    geofenceStrapiAPIList = [];

    final result = await http.get(Uri.parse(baseURL + customerURL), headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // 'Authorization': 'Bearer $token',
      // ignore: body_might_complete_normally_catch_error
    }).catchError((e) {
      print('Error Fetching Users');
    });
    if (result.statusCode == 200) {
      var jsondata = const JsonDecoder().convert(result.body);

      if (jsondata['data'].length != 0) {
        isHasGeofence = true;
        notifyListeners();
      } else {
        isHasGeofence = false;
        notifyListeners();
      }

      for (var data in jsondata['data']) {
        geoDataStrapiApi = GeoFenceStrapiAPIModel.fromDocumentSnapshot(data);
        geofenceStrapiAPIList.add(geoDataStrapiApi);

        //add only selected true data to geojson;
        feature = {
          "type": "Feature",
          "id": geoDataStrapiApi.id, // web currently only supports number ids
          "properties": <String, dynamic>{'id': geoDataStrapiApi.id},
          "geometry": json.decode(geoDataStrapiApi.attributes?.json ?? '')
        };
        features.add(feature);
      }
      geoJsonData = buildFeatureCollection(features);

      notifyListeners();
      return BaseService('S', 'Success get  customers data', result.body);
    } else {
      notifyListeners();
      return BaseService('E', 'Data Not Found', result.body);
    }
  }
}
