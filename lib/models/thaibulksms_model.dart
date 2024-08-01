class ThaiBulkSMSModel {
  String? status;
  String? token;
  String? refno;
  String? pin;
  String? key;
  String? secret;

  ThaiBulkSMSModel(
      {this.status, this.token, this.refno, this.pin, this.key, this.secret});

  factory ThaiBulkSMSModel.fromDocumentSnapshot(Map<String, dynamic> data) {
    return ThaiBulkSMSModel(
      status: data['status'],
      token: data['token'],
      refno: data['refno'],
      pin: data['pin'],
      key: data['key'],
      secret: data['secret'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['token'] = token;
    data['key'] = '1774454879201372';
    data['secret'] = '1c347ed8e895eaf1aa54690fd80b5bde';
    data['pin'] = pin;
    return data;
  }
}
