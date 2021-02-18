import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:xapp/models/PostModel.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/LandingPage.dart';
import 'package:xapp/screens/auth/Login.dart';
import 'package:xapp/widget/LikeButton.dart';

class FeedPost extends StatefulWidget {
  final Function onProfilePressed;
  final AuthProvider authProvider;
  final FirestoreProvider firestoreProvider;
  final FunctionProvider functionProvider;
  final PostModel post;
  final bool isLast;

  const FeedPost({
    Key key,
    this.onProfilePressed,
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
  bool _isVisible = false;

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

    print('FeedPost: ${widget.post.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          child: SpinKitThreeBounce(
            color: Colors.white,
            size: 15.0,
          ),
        ),
        Image.network(
          widget.post.imageURL,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _isVisible = frame != null);
              }
            });

            return wasSynchronouslyLoaded
                ? child
                : AnimatedOpacity(
                    child: child,
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
          },
          fit: BoxFit.cover,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
        Positioned(
          bottom: 50.0,
          right: 30.0,
          child: AnimatedOpacity(
            opacity: _isVisible ? 1 : 0,
            duration: Duration(milliseconds: 800),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20.0,
                  ),
                  child: GestureDetector(
                      onTap: widget.onProfilePressed,
                      child: SizedBox(
                        width: 60.0,
                        height: 60.0,
                        child: ClipOval(
                          child: Image.network(
                            widget.post.user.photoURL,
                            frameBuilder: (context, child, frame,
                                wasSynchronouslyLoaded) {
                              return wasSynchronouslyLoaded
                                  ? child
                                  : AnimatedOpacity(
                                      child: child,
                                      opacity: frame == null ? 0 : 1,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                    );
                            },
                            fit: BoxFit.cover,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                          ),
                        ),
                      )

                      // CircleAvatar(
                      //   backgroundColor: Theme.of(context).primaryColor,
                      //   radius: 28.0,
                      //   backgroundImage: NetworkImage(widget.post.user.photoURL),
                      // ),
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
