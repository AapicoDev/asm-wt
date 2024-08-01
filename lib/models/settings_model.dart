import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsModel {
  final int? before_clock_in_hour;
  final int? before_clock_out_hour;

  SettingsModel({this.before_clock_in_hour, this.before_clock_out_hour});

  factory SettingsModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return SettingsModel(
      before_clock_in_hour: data['before_clock_in_hour'],
      before_clock_out_hour: data['before_clock_out_hour'],
    );
  }

  Map<String, dynamic> toJson() {
    late Map<String, dynamic> data = <String, dynamic>{};

    data['before_clock_in_hour'] = before_clock_in_hour;
    data['before_clock_out_hour'] = before_clock_out_hour;

    return data;
  }
}
