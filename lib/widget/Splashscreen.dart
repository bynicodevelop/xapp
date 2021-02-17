import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xapp/Config.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({Key key}) : super(key: key);

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
            child: Image(
              image: AssetImage('assets/s.png'),
            ),
          ),
        ),
      ),
    );
  }
}
