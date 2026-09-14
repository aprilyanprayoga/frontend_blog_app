import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

class CategoryService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<List<CategoryModel>> getAllCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data kategori');
    }
  }
}