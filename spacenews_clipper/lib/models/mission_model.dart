class MissionModel {
  final int id;
  final String name;

  MissionModel({required this.id, required this.name});

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(id: json['id'], name: json['name']);
  }
}