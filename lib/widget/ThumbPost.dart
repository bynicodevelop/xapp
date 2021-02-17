import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xapp/models/PostModel.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/FullPost.dart';

class ThumbPost extends StatefulWidget {
  final AuthProvider authProvider;
  final FirestoreProvider firestoreProvider;
  final FunctionProvider functionProvider;

  final PostModel post;

  const ThumbPost({
    Key key,
    this.authProvider,
    this.firestoreProvider,
    this.functionProvider,
    this.post,
  }) : super(key: key);

  @override
  _ThumbPostState createState() => _ThumbPostState();
}

class _ThumbPostState extends State<ThumbPost> {
  Image _image(
    String imageURL,
    double height,
    double width,
  ) {
    return Image(
      width: width,
      height: height,
      image: NetworkImage(imageURL),
      fit: BoxFit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullPost(
            authProvider: widget.authProvider,
            firestoreProvider: widget.firestoreProvider,
            functionProvider: widget.functionProvider,
            post: widget.post,
          ),
        ),
      ),
      child: Hero(
        tag: widget.post.id,
        child: widget.authProvider.isAuthenticated
            ? Container(
                child: _image(
                  widget.post.imageURL,
                  height,
                  width,
                ),
              )
            : Container(
                constraints: BoxConstraints.expand(),
                child: Stack(
                  children: [
                    _image(
                      widget.post.imageURL,
                      height,
                      width,
                    ),
                    Positioned(
                      width: width,
                      height: height,
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
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
