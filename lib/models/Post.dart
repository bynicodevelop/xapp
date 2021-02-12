import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:xapp/models/User.dart';

@JsonSerializable()
class Post {
  static const String ID = 'id';
  static const String IMAGE_URL = 'imageURL';
  static const String LIKES = 'likes';
  static const String DOCUMENT = 'document';
  static const String USER = 'user';

  final String id;
  final String imageURL;
  final int likes;
  final DocumentSnapshot document;
  final User user;

  const Post({
    this.id,
    this.imageURL,
    this.likes,
    this.document,
    this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

Post _$PostFromJson(Map<String, dynamic> json) {
  return Post(
    id: json[Post.ID] as String,
    imageURL: json[Post.IMAGE_URL] as String,
    likes: json[Post.LIKES] as int,
    document: json[Post.DOCUMENT] as DocumentSnapshot,
    user: json[Post.USER] as User,
  );
}

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      Post.ID: instance.id,
      Post.IMAGE_URL: instance.imageURL,
      Post.LIKES: instance.likes,
      Post.DOCUMENT: instance.document,
      Post.USER: instance.user.toJson(),
    };
