import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String? notificationId;
  late String? toId;
  late String? fromId;
  late String? title;
  late String? titleId;
  late String? desc = "";
  late Timestamp? createdDate;
  final bool? view;
  final String? color;
  final String? notifyCode;
  late String? status;
  NotificationModel({
    this.notificationId,
    this.toId,
    this.fromId,
    this.title,
    this.desc,
    this.titleId,
    this.createdDate,
    this.view,
    this.color,
    this.notifyCode,
    this.status,
  });

  factory NotificationModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return NotificationModel(
        notificationId: snapshot.id,
        toId: data['to_id'],
        desc: data['desc'],
        title: data['title'],
        fromId: data['from_id'],
        createdDate: data['created_date'],
        titleId: data['title_id'],
        view: data['view'],
        color: data['color'],
        notifyCode: data['noti_code'],
        status: data['status']);
  }

  Map<String, dynamic> toJson() {
    return {
      'to_id': toId,
      'desc': desc,
      'from_id': fromId,
      'created_date': DateTime.now(),
      'title': title,
      'title_id': titleId,
      'view': false,
      'noti_code': 'task',
      'status': status
    };
  }
}
