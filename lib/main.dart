import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled17/login_screen.dart';
import 'package:untitled17/screens/home_page.dart';

import 'events.dart';
import 'modules/screens/splash_screen1.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  ThemeMode savedThemeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];

  Widget homeScreen = isLoggedIn ? HomePage() : LoginScreen();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(savedThemeMode),
      child: MyApp(homeScreen: homeScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget homeScreen;

  MyApp({required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: homeScreen,
        );
      },
    );
  }
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => FirebaseOptions(
    apiKey: "AIzaSyCdPXhfGyTxUHiPQDc3_ToZ5vcKF3miNtc",
    authDomain: "wwew-fa4b6.firebaseapp.com",
    projectId: "wwew-fa4b6",
    storageBucket: "wwew-fa4b6.appspot.com",
    messagingSenderId: "66751097136",
    appId: "1:66751097136:web:2d89b8a4cfb72e60be40f5",
  );
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode;

  ThemeProvider(this._themeMode);

  ThemeMode get themeMode => _themeMode;

  void updateThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', themeMode.index);
  }
}
