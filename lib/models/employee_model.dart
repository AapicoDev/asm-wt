import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  String? username;
  String? email;
  String? employeeID;
  String? staffId;
  bool? isActivated;
  String? deviceID;
  String? phoneModel;
  String? userUID;
  String? phoneNumber;
  final String? deviceToken;
  String? profileURL;
  String? profileFileName;
  String? organization_id;
  String? firstname_en;
  String? firstname_th;
  String? lastname_en;
  String? lastname_th;
  String? title_en;
  String? title_th;
  String? site_th;
  String? site_en;
  final String? userStatus;
  Timestamp? updatedAt;

  EmployeeModel(
      {this.username,
      this.email,
      this.userUID,
      this.employeeID,
      this.staffId,
      this.isActivated,
      this.deviceID,
      this.phoneModel,
      this.phoneNumber,
      this.deviceToken,
      this.profileFileName,
      this.userStatus,
      this.profileURL,
      this.firstname_en,
      this.firstname_th,
      this.lastname_en,
      this.lastname_th,
      this.title_en,
      this.title_th,
      this.updatedAt,
      this.site_en,
      this.site_th,
      this.organization_id});

  factory EmployeeModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return EmployeeModel(
      employeeID: snapshot.id,
      username: data['username'],
      email: data['email'],
      staffId: data['employee_id'],
      isActivated: data['isActivated'],
      phoneModel: data['phone_model'],
      deviceToken: data['device_token'],
      phoneNumber: data['phone_number'],
      deviceID: data['device_id'],
      profileURL: data['profile_url'],
      profileFileName: data['profile_file_name'],
      userStatus: data['user_status'],
      organization_id: data['organization_id'],
      site_en: data['site_en'],
      site_th: data['site_th'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['email'] = email;
    data['phone_number'] = phoneNumber;
    data['isActivated'] = isActivated;
    data['profile_url'] = profileURL;
    data['device_id'] = deviceID;
    data['user_uid'] = userUID;
    data['phone_model'] = phoneModel;
    data['updated_at'] = Timestamp.now();
    data['user_status'] = "Available";

    return data;
  }
}
