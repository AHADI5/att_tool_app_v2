
import 'package:flutter/material.dart';
import 'package:project2/temp_constant.dart';
import 'dart:async';
import 'Features/Attendance/Services/synchronisation.dart';
import 'error_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSynchronization();
  }

  Future<void> _startSynchronization() async {
    try {
      // Start the synchronization process
      await Synchronisation().syncUE(baseApi);

      // Only navigate if the widget is still mounted
      if (!mounted) return;

      // If successful, navigate to the home page
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      // Only navigate if the widget is still mounted
      if (!mounted) return;

      // If synchronization fails, navigate to the error page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SyncErrorPage(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Synchronizing...',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            CircularProgressIndicator(
              strokeWidth: 6.0,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Please wait...',
              style: TextStyle(fontSize: 18.0),
            ),
          ],
        ),
      ),
    );
  }
}
