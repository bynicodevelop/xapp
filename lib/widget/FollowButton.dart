import 'package:flutter/material.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/auth/Login.dart';
import 'package:xapp/services/Translate.dart';
import 'package:xapp/transitions/FadeRouteTransition.dart';
import 'package:xapp/widget/form/MainButton.dart';

class FollowButton extends StatefulWidget {
  final FunctionProvider functionProvider;
  final FirestoreProvider firestoreProvider;
  final String profileUserId;

  const FollowButton({
    Key key,
    this.functionProvider,
    this.firestoreProvider,
    this.profileUserId,
  }) : super(key: key);

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _isFollowed = false;

  @override
  void initState() {
    super.initState();

    widget.firestoreProvider
        .isFollowed(widget.profileUserId)
        .listen((isFollowed) {
      if (mounted) {
        setState(() => _isFollowed = isFollowed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 40.0,
        left: 50.0,
        right: 50.0,
      ),
      child: MainButton(
        label: (_isFollowed ? t(context).unfollow : t(context).follow)
            .toUpperCase(),
        color: _isFollowed ? Color(0xFFb11754) : null,
        // color: _isFollowed ? Colors.grey : null,
        onPressed: () async {
          try {
            if (_isFollowed) {
              await widget.functionProvider.unfollow(widget.profileUserId);

              return;
            }
            await widget.functionProvider.follow(widget.profileUserId);
          } catch (e) {
            Navigator.push(
              context,
              FadeRouteTransition(
                page: Login(),
              ),
            );
          }
        },
      ),
    );
  }
}
