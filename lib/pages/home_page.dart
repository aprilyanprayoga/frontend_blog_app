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

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  Future<void> _openDetail(PostModel post) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
    );
    if (changed == true) _refreshPosts();
  }

  Widget _categoryPill(String? name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name ?? '-',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _featuredCard(PostModel post) {
    return GestureDetector(
      onTap: () => _openDetail(post),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            SizedBox(
              height: 240,
              width: double.infinity,
              child: post.thumbnail != null
                  ? Image.network(post.thumbnail!, fit: BoxFit.cover)
                  : Container(color: Colors.grey[300]),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0),
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.4, 1],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _categoryPill(post.categoryName),
                  const SizedBox(height: 10),
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(post.updatedAt),
                    style: TextStyle(color: Colors.grey[300], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _postRow(PostModel post) {
    return InkWell(
      onTap: () => _openDetail(post),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: post.thumbnail != null
                  ? Image.network(
                      post.thumbnail!,
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 76,
                      height: 76,
                      color: Colors.grey[200],
                      child: Icon(Icons.image_not_supported, color: Colors.grey[500]),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _categoryPill(post.categoryName),
                  const SizedBox(height: 6),
                  Text(
                    post.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(post.updatedAt),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/artics_blog_app.jpeg', height: 28),
            const SizedBox(width: 10),
            const Text('Artics'),
          ],
        ),
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
                  ElevatedButton(onPressed: _refreshPosts, child: const Text('Coba Lagi')),
                ],
              ),
            );
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(child: Text('Belum ada artikel'));
          }

          final featured = posts.first;
          final rest = posts.skip(1).toList();

          return RefreshIndicator(
            onRefresh: () async => _refreshPosts(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                _featuredCard(featured),
                if (rest.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Artikel Lainnya',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      letterSpacing: 0.2,
                    ),
                  ),
                  const Divider(height: 20),
                  ...rest.map(
                    (post) => Column(
                      children: [
                        _postRow(post),
                        if (post != rest.last) const Divider(height: 1),
                      ],
                    ),
                  ),
                ],
              ],
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
              MaterialPageRoute(builder: (context) => const PostFormPage()),
            );
            if (result == true) _refreshPosts();
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
