import 'package:flutter/material.dart';
import 'package:xapp/screens/Camera.dart';
import 'package:xapp/screens/Feed.dart';
import 'package:xapp/screens/PublicProfile.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController(
    initialPage: 1,
  );

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: [
        Camera(),
        Feed(),
        PublicProfile(
          onBack: () => _pageController.animateToPage(
            1,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          ),
        ),
      ],
    );
  }
}
