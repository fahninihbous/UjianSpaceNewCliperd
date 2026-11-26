import 'mission_model.dart';

class ClippedNewsModel {
  final int id;
  final int missionId;
  final String title;
  final String? newsSite;
  final String? imageUrl;
  final String? notes;
  final MissionModel? mission;

  ClippedNewsModel({
    required this.id,
    required this.missionId,
    required this.title,
    this.newsSite,
    this.imageUrl,
    this.notes,
    this.mission,
  });

  factory ClippedNewsModel.fromJson(Map<String, dynamic> json) {
    return ClippedNewsModel(
      id: json['id'],
      missionId: int.parse(json['mission_id'].toString()),
      title: json['title'],
      newsSite: json['news_site'],
      imageUrl: json['image_url'],
      notes: json['notes'],
      mission: json['mission'] != null ? MissionModel.fromJson(json['mission']) : null,
    );
  }
}