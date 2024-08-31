
import 'package:flutter/material.dart';
import 'package:project2/splash_screen.dart';
import 'home.dart';

void main() {
  runApp(const AttToolApp());
}

class AttToolApp extends StatelessWidget {
  const AttToolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home' : (context) => const HomeScreen()

      },
    );
  }
}


