import 'dart:convert';

class GeoFenceStrapiAPIModel {
  final int? id;
  final GeoFenceDataModel? attributes;

  GeoFenceStrapiAPIModel({this.id, this.attributes});

  factory GeoFenceStrapiAPIModel.fromDocumentSnapshot(
      Map<String, dynamic> data) {
    return GeoFenceStrapiAPIModel(
      id: data['id'],
      attributes: GeoFenceDataModel.fromDocumentSnapshot(data['attributes']),
    );
  }
}

class GeoFenceDataModel {
  final String? name;
  final String? json;
  bool? isChecked;

  GeoFenceDataModel({this.name, this.json, this.isChecked});

  factory GeoFenceDataModel.fromDocumentSnapshot(Map<String, dynamic> data) {
    return GeoFenceDataModel(
      name: data['abbreviation'],
      json: jsonEncode(data['json']),
      isChecked: data['is_checked'],
    );
  }

  Map<String, dynamic> toJson() {
    late Map<String, dynamic> data = <String, dynamic>{};

    data['abbreviation'] = name;
    data['json'] = json;
    data['is_checked'] = isChecked;

    return data;
  }
}
