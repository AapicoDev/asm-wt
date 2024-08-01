import 'package:cloud_firestore/cloud_firestore.dart';

class NewFeedsModel {
  final String? notificationId;
  late String? toId;
  late String? fromId;
  late String? title;
  late String? typeId;
  late String? desc;
  late Timestamp? createdDate;
  late String? color;
  late String? type;
  late String? status;
  NewFeedsModel(
      {this.notificationId,
      this.toId,
      this.fromId,
      this.title,
      this.desc,
      this.typeId,
      this.createdDate,
      this.color,
      this.type,
      this.status});

  factory NewFeedsModel.fromDocumentSnapshot(DocumentSnapshot snapshot) {
    final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return NewFeedsModel(
        notificationId: snapshot.id,
        toId: data['to_id'],
        desc: data['desc'],
        title: data['title'],
        fromId: data['from_id'],
        createdDate: data['created_date'],
        typeId: data['type_id'],
        color: data['color'],
        status: data['status'],
        type: data['type']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['to_id'] = toId;
    data['desc'] = desc;
    data['from_id'] = fromId;
    data['created_date'] = DateTime.now();
    data['title'] = title;
    data['type_id'] = typeId;
    data['type'] = type;
    data['status'] = status;
    return data;
  }
}
