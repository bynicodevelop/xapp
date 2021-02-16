import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:xapp/models/UserModel.dart';

@JsonSerializable()
class PostModel {
  static const String ID = 'id';
  static const String IMAGE_URL = 'imageURL';
  static const String LIKES = 'likes';
  static const String DOCUMENT = 'document';
  static const String USER = 'user';

  final String id;
  final String imageURL;
  final int likes;
  final DocumentSnapshot document;
  final UserModel user;

  const PostModel({
    this.id,
    this.imageURL,
    this.likes,
    this.document,
    this.user,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);
}

PostModel _$PostModelFromJson(Map<String, dynamic> json) {
  return PostModel(
    id: json[PostModel.ID] as String,
    imageURL: json[PostModel.IMAGE_URL] as String,
    likes: json[PostModel.LIKES] as int,
    document: json[PostModel.DOCUMENT] as DocumentSnapshot,
    user: json[PostModel.USER] as UserModel,
  );
}

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      PostModel.ID: instance.id,
      PostModel.IMAGE_URL: instance.imageURL,
      PostModel.LIKES: instance.likes,
      PostModel.DOCUMENT: instance.document,
      PostModel.USER: instance.user.toJson(),
    };
