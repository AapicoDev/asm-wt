class LocationModel {
  final int id;
  final String nameEn;
  final String nameTh;
  final String abbreviation;
  final String organization;

  LocationModel({
    required this.id,
    required this.nameEn,
    required this.nameTh,
    required this.abbreviation,
    required this.organization,
  });

  // Factory constructor for creating a new instance from a map (from JSON)
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      nameEn: json['name_en'],
      nameTh: json['name_th'],
      abbreviation: json['abbreviation'],
      organization: json['organization'],
    );
  }

  // Method for converting the instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_th': nameTh,
      'abbreviation': abbreviation,
      'organization': organization,
    };
  }
}
