import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/post_service.dart';
import 'post_detail_page.dart';

class CategoryPostsPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryPostsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryPostsPage> createState() => _CategoryPostsPageState();
}

class _CategoryPostsPageState extends State<CategoryPostsPage> {
  late Future<List<PostModel>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = _loadPosts();
  }

  Future<List<PostModel>> _loadPosts() async {
    final all = await PostService.getAllPosts();
    return all.where((post) => post.categoryId == widget.categoryId).toList();
  }

  void _refresh() {
    setState(() => _futurePosts = _loadPosts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: FutureBuilder<List<PostModel>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Gagal memuat data: ${snapshot.error}'),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _refresh, child: const Text('Coba Lagi')),
                ],
              ),
            );
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('Belum ada artikel di kategori ini'));
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
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
                    onTap: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailPage(post: post),
                        ),
                      );
                      if (changed == true) _refresh();
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}