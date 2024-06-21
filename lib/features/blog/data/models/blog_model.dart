import 'package:blog_app/features/blog/domain/entities/blog.dart';

class BlogModel extends Blog {
  BlogModel({
    required super.id,
    required super.posterId,
    required super.title,
    required super.content,
    required super.imageUrl,
    required super.topics,
    required super.updatedAt,
  });

  factory BlogModel.fromJson(Map<String, dynamic> json) {
    return BlogModel(
      id: json['id'],
      posterId: json['poster_id'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['image_url'],
      topics: List<String>.from(json['topics']),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': super.id,
      'poster_id': super.posterId,
      'title': super.title,
      'content': super.content,
      'image_url': super.imageUrl,
      'topics': super.topics,
      'updated_at': super.updatedAt.toIso8601String(),
    };
  }

  BlogModel copyWith({
    String? id,
    String? posterId,
    String? title,
    String? content,
    String? imageUrl,
    List<String>? topics,
    DateTime? updatedAt,
  }) {
    return BlogModel(
      id: id ?? super.id,
      posterId: posterId ?? super.posterId,
      title: title ?? super.title,
      content: content ?? super.content,
      imageUrl: imageUrl ?? super.imageUrl,
      topics: topics ?? super.topics,
      updatedAt: updatedAt ?? super.updatedAt,
    );
  }
}
