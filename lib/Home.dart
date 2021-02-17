import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: [
        Camera(),
        Feed(
          goToProfile: () => _pageController.animateToPage(
            2,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
          ),
        ),
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
