import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import 'post_detail_page.dart';
import 'post_form_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<PostModel>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = PostService.getAllPosts();
  }

  void _refreshPosts() {
    setState(() {
      _futurePosts = PostService.getAllPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog App'),
      ),
      body: FutureBuilder<List<PostModel>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          // 1. Masih loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Ada error (misal gagal konek ke server)
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Gagal memuat data: ${snapshot.error}'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _refreshPosts,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          // 3. Data kosong
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('Belum ada artikel'));
          }

          // 4. Data berhasil didapat, tampilkan list
          return RefreshIndicator(
            onRefresh: () async => _refreshPosts(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: post.thumbnail != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              post.thumbnail!,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.image_not_supported, size: 40),
                    title: Text(post.title),
                    subtitle: Text(post.categoryName ?? '-'),
                    onTap: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailPage(post: post),
                        ),
                      );
                      if (changed == true) {
                        _refreshPosts();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PostFormPage(),
              ),
            );
            if (result == true) {
              _refreshPosts();
            }
          },
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.edit_note_rounded, size: 24),
          label: const Text(
            'Tulis Artikel',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}