import 'package:flutter/material.dart';
import 'package:xapp/models/Post.dart';
import 'package:xapp/widget/LikeButton.dart';

class FeedPost extends StatelessWidget {
  final Post post;

  const FeedPost({Key key, this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image(
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          image: NetworkImage(post.imageURL),
        ),
        Positioned(
          bottom: 50.0,
          right: 30.0,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 20.0,
                ),
                child: GestureDetector(
                  onTap: () => print('got to profile'),
                  child: CircleAvatar(
                    radius: 28.0,
                    backgroundImage: NetworkImage(post.user.photoURL),
                  ),
                ),
              ),
              LikeButton(
                onTap: () => print('liked'),
                hasLiked: false,
                likes: post.likes,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
