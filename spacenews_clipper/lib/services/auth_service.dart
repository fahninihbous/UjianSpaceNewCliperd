import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constant.dart';

class AuthService {
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> register(String name, String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse(ApiConstant.register),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    print('REGISTER (${response.statusCode}): ${response.body}');
    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return true;
    }
    return false;
  } catch (e) {
    print('ERROR REGISTER: $e');
    return false;
  }
}

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(ApiConstant.login),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return true;
    }
    return false;
  }

  Future<dynamic> getUserProfile() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(ApiConstant.user),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Gagal mengambil profil user');
  }

  Future<void> logout() async {
    final token = await getToken();
    await http.post(
      Uri.parse(ApiConstant.logout),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}