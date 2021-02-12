import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class User {
  static const String ID = 'id';
  static const String PHOTO_URL = 'photoURL';
  static const String DISPLAY_NAME = 'displayName';
  static const String STATUS = 'status';
  static const String SLUG = 'slug';
  static const String FOLLOWERS = 'followers';
  static const String FOLLOWINGS = 'followings';

  final String id;
  final String photoURL;
  final String displayName;
  final String status;
  final String slug;
  final int followers;
  final int followings;

  const User({
    this.id,
    this.photoURL,
    this.displayName,
    this.status,
    this.slug,
    this.followers,
    this.followings,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json[User.ID] as String,
    photoURL: json[User.PHOTO_URL] as String,
    displayName: json[User.DISPLAY_NAME] as String,
    status: json[User.STATUS] as String,
    slug: json[User.SLUG] as String,
    followers: json[User.FOLLOWERS] as int,
    followings: json[User.FOLLOWINGS] as int,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      User.ID: instance.id,
      User.PHOTO_URL: instance.photoURL,
      User.DISPLAY_NAME: instance.displayName,
      User.STATUS: instance.status,
      User.SLUG: instance.slug,
      User.FOLLOWERS: instance.followers,
      User.FOLLOWINGS: instance.followings,
    };
