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

  UserModel(
      {this.username,
      this.email,
      this.userId,
      this.userStatus,
      this.staffId,
      this.deviceToken,
      this.deviceId,
      this.profileURL,
      this.profileFileName,
      this.phoneNumber});

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
      profileURL: data['profile_url'],
      profileFileName: data['profile_file_name'],
      userStatus: data['user_status'],
    );
  }

  Map<String, dynamic> toJson() {
    late Map<String, dynamic> data = <String, dynamic>{};

    data['device_id'] = deviceId;

    return data;
  }
}
