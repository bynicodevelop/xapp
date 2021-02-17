import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xapp/Config.dart';
import 'package:animator/animator.dart';

class Splashscreen extends StatefulWidget {
  final Function onEndAnimation;
  final bool isAnimate;

  const Splashscreen({
    Key key,
    this.onEndAnimation,
    this.isAnimate = false,
  }) : super(key: key);

  @override
  _SplashscreenState createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(Config.primaryColor),
      ),
      home: Scaffold(
        body: Container(
          child: Align(
            alignment: Alignment(0.0, -0.3),
            child: widget.isAnimate
                ? Animator(
                    endAnimationListener: (state) {
                      if (state.controller.status ==
                          AnimationStatus.completed) {
                        widget.onEndAnimation();
                      }
                    },
                    tween: Tween<double>(begin: 0, end: 200),
                    cycles: 1,
                    duration: Duration(milliseconds: 800),
                    builder: (context, animatorState, child) => Opacity(
                      opacity: animatorState.value / 200,
                      child: Image(
                        image: AssetImage('assets/s.png'),
                      ),
                    ),
                  )
                : Image(
                    image: AssetImage('assets/s.png'),
                  ),
          ),
        ),
      ),
    );
  }
}
