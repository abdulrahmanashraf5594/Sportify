import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:untitled17/modules/screens/splash_screen1.dart';

import '../../main.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen1(),
    );
  }
}

class SplashScreen1 extends StatefulWidget {
  SplashScreen1({Key? key}) : super(key: key);

  @override
  State<SplashScreen1> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen1> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SplashScreen()), // Assuming SplashScreen2 is the intended next screen
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                'images/splash.png',
                // Add any additional properties or styling for the image here
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Color.fromARGB(255, 4, 114, 111),
      nextScreen: SplashScreen1(),
      splashIconSize: 200,
      duration: 4000,
    );
  }
}
