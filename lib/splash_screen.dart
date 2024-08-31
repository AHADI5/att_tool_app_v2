import 'package:flutter/material.dart';
import 'package:project2/temp_constant.dart';
import 'dart:async';
import 'Features/Attendance/Models/unite_enseignement.dart';
import 'Features/Attendance/Services/synchronisation.dart';
import 'db_init.dart';
import 'error_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  DatabaseConfig db = DatabaseConfig.instance;

  @override
  void initState() {
    super.initState();
    _checkTableAndProceed();
  }

  Future<void> _checkTableAndProceed() async {
    try {
      // Check if the UniteEnseign table has data
      List<UniteEnseignement> uniteEnseignements = await db.getAllUniteEnseignements();

      if (uniteEnseignements.isNotEmpty) {
        // If the table is not empty, go directly to the home page
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // If the table is empty, start synchronization
        await _startSynchronization();
      }
    } catch (error) {
      // Handle error, e.g., navigate to the error page
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SyncErrorPage(),
        ),
      );
    }
  }

  Future<void> _startSynchronization() async {
    try {
      String currentApi = await db.getApiUrl();

      // Start the synchronization process
      await Synchronisation().syncUE(currentApi);

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
