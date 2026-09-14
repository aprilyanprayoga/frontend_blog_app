class PostModel {
  final int id;
  final String title;
  final String slug;
  final String content;
  final String? thumbnail;
  final int categoryId;
  final String? categoryName;
  final String createdAt;
  final String updatedAt;

  PostModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    this.thumbnail,
    required this.categoryId,
    this.categoryName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      title: json['title'],
      slug: json['slug'] ?? '',
      content: json['content'],
      thumbnail: json['thumbnail'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'content': content,
      'thumbnail': thumbnail,
      'category_id': categoryId,
      'categoryName': categoryName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}