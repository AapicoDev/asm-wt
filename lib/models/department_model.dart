class DepartmentModel {
  final String? name;
  final List<DepartmentModel>? control;
  final bool? is_control_enabled;

  DepartmentModel({this.name, this.is_control_enabled, this.control});

  factory DepartmentModel.fromDocumentSnapshot(Map<String, dynamic> data) {
    return DepartmentModel(
      control: data['control'],
      name: data['name'],
      is_control_enabled: data['is_control_enabled'],
    );
  }

  Map<String, dynamic> tois_control_enabled() {
    late Map<String, dynamic> data = <String, dynamic>{};

    data['name'] = name;
    data['is_control_enabled'] = is_control_enabled;

    return data;
  }
}
