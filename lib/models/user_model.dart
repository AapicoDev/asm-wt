import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? username;
  final String? email;
  final String? userId;
  final String? userStatus;
  final String? staffId;
  final String? phoneNumber;
  final String? deviceToken;
  final String? deviceId;
  String? profileURL;
  String? profileFileName;
  String? siteTH;
  String? siteEN;
  String? sectionCode;
  String? sectionTH;
  String? sectionEN;

  String? jobCode;
  String? siteCode;
  String? jobTH;
  String? jobEN;
  String? firstnameEN;
  String? firstnameTH;
  String? lastnameEN;
  String? lastnameTH;

  UserModel({
    this.username,
    this.email,
    this.userId,
    this.userStatus,
    this.staffId,
    this.deviceToken,
    this.deviceId,
    this.profileURL,
    this.profileFileName,
    this.phoneNumber,
    this.siteTH,
    this.siteEN,
    this.sectionCode,
    this.sectionTH,
    this.sectionEN,
    this.jobCode,
    this.siteCode,
    this.jobTH,
    this.jobEN,
    this.firstnameEN,
    this.firstnameTH,
    this.lastnameEN,
    this.lastnameTH,
  });

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return UserModel(
      userId: snapshot.id,
      username: data['username'],
      email: data['email'],
      staffId: data['user_id'],
      deviceToken: data['device_token'],
      phoneNumber: data['phone_number'],
      deviceId: data['device_id'],
      profileURL: data['profile_url'] ?? null,
      profileFileName: data['profile_file_name'] ?? null,
      userStatus: data['user_status'],
      siteTH: data['site_th'] ?? null,
      siteEN: data['site_en'] ?? null,
      sectionCode: data['section_code'] ?? null,
      sectionTH: data['section_th'] ?? null,
      sectionEN: data['section_en'] ?? null,
      jobCode: data['job_code'] ?? null,
      siteCode: data['site_code'] ?? null,
      jobTH: data['job_th'] ?? null,
      jobEN: data['job_en'] ?? null,
      firstnameTH: data['firstname_th'] ?? null,
      firstnameEN: data['firstname_en'] ?? null,
      lastnameTH: data['lastname_th'] ?? null,
      lastnameEN: data['lastname_en'] ?? null,
    );
  }

  Map<String, dynamic> toJson() {
    late Map<String, dynamic> data = <String, dynamic>{};

    data['device_id'] = deviceId;
    data['username'] = username;
    data['email'] = email;
    data['user_id'] = staffId;
    data['profile_url'] = profileURL ?? null;
    data['profile_file_name'] = profileFileName ?? null;
    data['user_status'] = userStatus;
    data['site_th'] = siteTH ?? null;
    data['site_en'] = siteEN ?? null;
    data['sectionCode'] = sectionCode ?? null;
    data['sectionTH'] = sectionTH ?? null;
    data['sectionEN'] = sectionEN ?? null;

    data['jobCode'] = jobCode ?? null;
    data['siteCode'] = siteCode ?? null;
    data['jobTH'] = jobTH ?? null;
    data['jobEN'] = jobEN ?? null;
    data['firstnameTH'] = firstnameTH ?? null;
    data['firstnameEN'] = firstnameEN ?? null;
    data['lastnameTH'] = lastnameTH ?? null;
    data['lastnameEN'] = lastnameEN ?? null;

    return data;
  }
}
