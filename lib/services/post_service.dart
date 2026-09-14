import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class PostService {
  // Untuk Chrome/web & desktop, pakai localhost biasa
  // Kalau nanti pindah ke emulator Android, ganti ke 10.0.2.2
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<List<PostModel>> getAllPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data artikel');
    }
  }
}