import 'package:flutter/material.dart';
import 'package:project2/db_init.dart';
import 'Features/Attendance/Services/synchronisation.dart';

class SyncErrorPage extends StatefulWidget {
  const SyncErrorPage({super.key});

  @override
  _SyncErrorPageState createState() => _SyncErrorPageState();
}

class _SyncErrorPageState extends State<SyncErrorPage> {
  bool _showUrlField = false; // To toggle the visibility of the URL input field
  final DatabaseConfig db = DatabaseConfig.instance;
  final TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadApiUrl(); // Load the API URL when the widget is initialized
  }

  Future<void> _loadApiUrl() async {
    String apiUrl = await db.getApiUrl();
    setState(() {
      _urlController.text = apiUrl; // Set the TextEditingController's text
    });
  }

  Future<void> _startSynchronization(BuildContext context) async {
    try {
      // Start the synchronization process with the provided URL
      await Synchronisation().syncUE(_urlController.text);

      // Only navigate if the widget is still mounted
      if (!context.mounted) return;

      // If successful, navigate to the home page
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      // Handle synchronization error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de la synchronisation. Réessayez.")),
      );
    }
  }

  void _onRegisterPressed() async {
    // Save or update the URL in the database
    await db.insertOrUpdateApi(_urlController.text);

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("URL enregistrée avec succès")),
    );

    // Hide the URL field after saving
    setState(() {
      _showUrlField = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Erreur de Synchronisation"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Vérifiez votre connexion Internet ou l'URL.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              if (_showUrlField) // Toggle URL input field
                Column(
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: "Nouvelle URL de synchronisation",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _onRegisterPressed, // Register button pressed
                      child: const Text("Enregistrer"),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 40),
                        onPressed: () {
                          _startSynchronization(context); // Call the sync function
                        },
                      ),
                      const Text(
                        "Réessayer",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(width: 40),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 40),
                        onPressed: () {
                          setState(() {
                            _showUrlField = !_showUrlField; // Toggle visibility of URL input and Register button
                          });
                        },
                      ),
                      const Text(
                        "Modifier l'URL",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
