import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:project2/Features/Attendance/Screens/result_page.dart';
import '../Models/school_year.dart';
import '../Models/unite_enseignement.dart';

class ValidateAndProceedButton extends StatelessWidget {
  final String? selectedPromotion;
  final ElementConst? selectedElement;
  final SchoolYear? selectedYear;
  final bool isFloatingActionButton; // Flag to determine the type of button

  const ValidateAndProceedButton({
    super.key,
    required this.selectedPromotion,
    required this.selectedElement,
    required this.selectedYear,
    this.isFloatingActionButton = false, // Default to false (use IconButton)
  });

  @override
  Widget build(BuildContext context) {
    if (isFloatingActionButton) {
      // Return FloatingActionButton for HomeScreen
      return FloatingActionButton(
        onPressed: () async {
          await _validateAndProceed(context);
        },
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        child: const Icon(Icons.qr_code_scanner),
      );
    } else {
      // Return IconButton for ResultPage
      return Column(
        children: [
          IconButton(
            icon: const Icon(Icons.refresh , color: Colors.blue,),
            onPressed: () async {
              await _validateAndProceed(context);
            },
          ),
          const Text("Rescan" , style: TextStyle(color: Colors.blue),)
        ],
      );
    }
  }

  Future<void> _validateAndProceed(BuildContext context) async {
    if (selectedPromotion == null || selectedElement == null || selectedYear == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select all fields (Promotion, Élément Constitutif, Year)"),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Launch the QR code scanner
      String scannedCode = await _scanQRCode();

      // If the scan was successful, navigate to the result page
      if (scannedCode != '-1') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationResultPage(
              selectedElement: selectedElement!,
              selectedYear: selectedYear!,
              scannedCode: scannedCode,
            ),
          ),
        );
      } else {
        // Handle case where scanning is cancelled
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Scanning was cancelled."),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<String> _scanQRCode() async {
    try {
      return await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Color of the scan line
        'Cancel', // Cancel button text
        true, // Show flash icon
        ScanMode.BARCODE, // Scan mode
      );
    } catch (e) {
      debugPrint('Error scanning QR code: $e');
      return '-1'; // Indicate failure
    }
  }
}
