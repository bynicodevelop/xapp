import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class UserModel {
  static const String ID = 'id';
  static const String EMAIL = 'email';
  static const String PHOTO_URL = 'photoURL';
  static const String DISPLAY_NAME = 'displayName';
  static const String STATUS = 'status';
  static const String SLUG = 'slug';
  static const String FOLLOWERS = 'followers';
  static const String FOLLOWINGS = 'followings';

  final String id;
  final String email;
  final String photoURL;
  final String displayName;
  final String status;
  final String slug;
  final int followers;
  final int followings;

  const UserModel({
    this.id,
    this.email,
    this.photoURL,
    this.displayName,
    this.status,
    this.slug,
    this.followers,
    this.followings,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json[UserModel.ID] as String,
    email: json[UserModel.EMAIL] as String,
    photoURL: json[UserModel.PHOTO_URL] as String,
    displayName: json[UserModel.DISPLAY_NAME] as String,
    status: json[UserModel.STATUS] as String,
    slug: json[UserModel.SLUG] as String,
    followers: json[UserModel.FOLLOWERS] as int,
    followings: json[UserModel.FOLLOWINGS] as int,
  );
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      UserModel.ID: instance.id,
      UserModel.EMAIL: instance.email,
      UserModel.PHOTO_URL: instance.photoURL,
      UserModel.DISPLAY_NAME: instance.displayName,
      UserModel.STATUS: instance.status,
      UserModel.SLUG: instance.slug,
      UserModel.FOLLOWERS: instance.followers,
      UserModel.FOLLOWINGS: instance.followings,
    };
