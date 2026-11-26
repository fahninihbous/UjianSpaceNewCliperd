import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constant.dart';
import '../models/space_article.dart';

class PublicApiService {
  Future<List<SpaceArticle>> fetchArticles() async {
    final response = await http.get(Uri.parse(ApiConstant.publicApiUrl));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List results = data['results']; // SpaceNews API menyimpan list di key 'results'
      return results.map((e) => SpaceArticle.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat berita antariksa');
    }
  }
}