class AreaModel {
  final String? name_en;
  final String? name_th;

  AreaModel({this.name_en, this.name_th});

  factory AreaModel.fromDocumentSnapshot(Map<String, dynamic> data) {
    return AreaModel(
      name_en: data['name_en'],
      name_th: data['name_th'],
    );
  }

  Map<String, dynamic> toname_th() {
    late Map<String, dynamic> data = <String, dynamic>{};

    data['name_en'] = name_en;
    data['name_th'] = name_th;

    return data;
  }
}
