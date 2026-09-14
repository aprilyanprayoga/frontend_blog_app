import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/post_model.dart';

class PostService {
  // Untuk Android emulator wajib pakai 10.0.2.2, bukan localhost
  // Untuk Chrome/web, ganti ke http://localhost:3000/api
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

  static Future<void> _attachImage(
    http.MultipartRequest request, {
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    if (kIsWeb) {
      if (imageBytes != null) {
        final name = imageName ?? 'upload.jpg';
        final ext = name.split('.').last.toLowerCase();
        final subtype = ext == 'jpg' ? 'jpeg' : ext;
        request.files.add(
          http.MultipartFile.fromBytes(
            'thumbnail',
            imageBytes,
            filename: name,
            contentType: MediaType('image', subtype),
          ),
        );
      }
    } else {
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('thumbnail', imageFile.path),
        );
      }
    }
  }

  static Future<void> createPost({
    required String title,
    required String content,
    required int categoryId,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final uri = Uri.parse('$baseUrl/posts');
    final request = http.MultipartRequest('POST', uri);

    request.fields['title'] = title;  
    request.fields['content'] = content;
    request.fields['category_id'] = categoryId.toString();

    await _attachImage(request, imageFile: imageFile, imageBytes: imageBytes, imageName: imageName);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal membuat artikel');
    }
  }

  static Future<void> updatePost({
    required int id,
    required String title,
    required String content,
    required int categoryId,
    File? imageFile, // null = thumbnail lama dipertahankan
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final uri = Uri.parse('$baseUrl/posts/$id');
    final request = http.MultipartRequest('PUT', uri);

    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['category_id'] = categoryId.toString();

    await _attachImage(request, imageFile: imageFile, imageBytes: imageBytes, imageName: imageName);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Gagal memperbarui artikel');
    }
  }
}