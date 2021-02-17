import 'package:flutter/material.dart';
import 'package:xapp/models/PostModel.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/widget/FeedPost.dart';

class FullPost extends StatelessWidget {
  final AuthProvider authProvider;
  final FirestoreProvider firestoreProvider;
  final FunctionProvider functionProvider;

  final PostModel post;

  const FullPost({
    Key key,
    this.authProvider,
    this.firestoreProvider,
    this.functionProvider,
    this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Hero(
        tag: post.id,
        child: FeedPost(
          authProvider: authProvider,
          firestoreProvider: firestoreProvider,
          functionProvider: functionProvider,
          post: post,
        ),
      ),
    );
  }
}
