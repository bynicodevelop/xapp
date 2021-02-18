import 'package:flutter/material.dart';
import 'package:xapp/models/PostModel.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/widget/FeedPost.dart';

class FullPost extends StatefulWidget {
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
  _FullPostState createState() => _FullPostState();
}

class _FullPostState extends State<FullPost> {
  PostModel _postModel;

  @override
  void initState() {
    super.initState();

    widget.firestoreProvider.profilPosts.listen((post) {
      setState(() => _postModel =
          post.firstWhere((p) => p.id == widget.post.id, orElse: () => null));
    });

    setState(() => _postModel = widget.post);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Hero(
        tag: widget.post.id,
        child: FeedPost(
          authProvider: widget.authProvider,
          firestoreProvider: widget.firestoreProvider,
          functionProvider: widget.functionProvider,
          post: _postModel,
        ),
      ),
    );
  }
}
