import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:xapp/models/PostModel.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/LandingPage.dart';
import 'package:xapp/screens/auth/Login.dart';
import 'package:xapp/widget/LikeButton.dart';

class FeedPost extends StatefulWidget {
  final AuthProvider authProvider;
  final FirestoreProvider firestoreProvider;
  final FunctionProvider functionProvider;
  final PostModel post;
  final bool isLast;

  const FeedPost({
    Key key,
    this.authProvider,
    this.firestoreProvider,
    this.functionProvider,
    this.post,
    this.isLast = false,
  }) : super(key: key);

  @override
  _FeedPostState createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();

    widget.firestoreProvider.user.listen((user) {
      if (user == null) return;

      dynamic result = user.likes.firstWhere(
          (DocumentReference like) => like.id == widget.post.id,
          orElse: () => null);

      if (mounted) {
        setState(() => _isLiked = result != null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image(
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.center,
          image: NetworkImage(widget.post.imageURL),
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
                    backgroundImage: NetworkImage(widget.post.user.photoURL),
                  ),
                ),
              ),
              LikeButton(
                onTap: () async {
                  try {
                    await widget.functionProvider.like(widget.post.id);
                  } catch (e) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(),
                      ),
                    );
                  }
                },
                hasLiked: _isLiked,
                likes: widget.post.likes,
              ),
            ],
          ),
        ),
        Visibility(
          visible: widget.isLast && !widget.authProvider.isAuthenticated,
          child: Positioned(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8.0,
                sigmaY: 8.0,
              ),
              child: Container(
                constraints: BoxConstraints.expand(),
                color: Colors.white.withOpacity(.4),
              ),
            ),
          ),
        ),
        Visibility(
          visible: widget.isLast && !widget.authProvider.isAuthenticated,
          child: Positioned(
            child: LandingPage(
              firestoreProvider: widget.firestoreProvider,
              functionProvider: widget.functionProvider,
            ),
          ),
        )
      ],
    );
  }
}
