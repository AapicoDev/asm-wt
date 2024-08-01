import 'package:cloud_firestore/cloud_firestore.dart';

class DevicesModel {
  String? devicesUID;
  String? android;
  String? ios;

  DevicesModel({
    this.devicesUID,
    this.android,
    this.ios,
  });

  factory DevicesModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return DevicesModel(
      devicesUID: snapshot.id,
      android: data['android'],
      ios: data['ios'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['android'] = android;
    data['ios'] = ios;
    return data;
  }
}
