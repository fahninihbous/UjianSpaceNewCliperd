import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';
import '../models/mission_model.dart';
import '../models/clipped_news_model.dart';
import 'auth_service.dart';

class CrudService {
  final AuthService _auth = AuthService();

  Future<dynamic> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ================= TABEL 1: MISSIONS =================
  Future<List<MissionModel>> getMissions() async {
    final response = await http.get(Uri.parse(ApiConstant.missions), headers: await _headers());
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MissionModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat kategori misi');
  }

  Future<bool> createMission(String name) async {
    final response = await http.post(
      Uri.parse(ApiConstant.missions),
      headers: await _headers(),
      body: jsonEncode({'name': name}),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateMission(int id, String name) async {
    final response = await http.put(
      Uri.parse('${ApiConstant.missions}/$id'),
      headers: await _headers(),
      body: jsonEncode({'name': name}),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteMission(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstant.missions}/$id'),
      headers: await _headers(),
    );
    return response.statusCode == 200;
  }

  // ================= TABEL 2: CLIPPED NEWS =================
  Future<List<ClippedNewsModel>> getClippedNews({int? missionId}) async {
    String url = ApiConstant.clippedNews;
    if (missionId != null) {
      url += '?mission_id=$missionId';
    }
    final response = await http.get(Uri.parse(url), headers: await _headers());
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ClippedNewsModel.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat berita tersimpan');
  }

  Future<bool> createClippedNews({
    required int missionId,
    required String title,
    String? newsSite,
    String? imageUrl,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstant.clippedNews),
      headers: await _headers(),
      body: jsonEncode({
        'mission_id': missionId,
        'title': title,
        'news_site': newsSite,
        'image_url': imageUrl,
        'notes': notes,
      }),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateClippedNews({
    required int id,
    required int missionId,
    required String title,
    String? newsSite,
    String? imageUrl,
    String? notes,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConstant.clippedNews}/$id'),
      headers: await _headers(),
      body: jsonEncode({
        'mission_id': missionId,
        'title': title,
        'news_site': newsSite,
        'image_url': imageUrl,
        'notes': notes,
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteClippedNews(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiConstant.clippedNews}/$id'),
      headers: await _headers(),
    );
    return response.statusCode == 200;
  }
}