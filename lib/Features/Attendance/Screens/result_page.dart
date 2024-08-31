
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project2/Features/Attendance/Screens/scanner_handling.dart';

import '../../../db_init.dart';
import '../Dtos/AttendanceDto.dart';
import '../Models/school_year.dart';
import '../Models/unite_enseignement.dart';
import '../Services/backup_data.dart';
import '../Services/pdf_generator.dart';

class VerificationResultPage extends StatefulWidget {
  final ElementConst selectedElement;
  final SchoolYear selectedYear;
  final String scannedCode;

  const VerificationResultPage({
    super.key,
    required this.selectedElement,
    required this.selectedYear,
    required this.scannedCode,
  });

  @override
  _VerificationResultPageState createState() => _VerificationResultPageState();
}

class _VerificationResultPageState extends State<VerificationResultPage> {
  bool _isLoading = false;
  bool _isAttendanceRecorded = false;
  final BackupData _backupData = BackupData();

  void _handlePrint() async {

    await generateAndSavePdf(widget.selectedElement, widget.selectedYear);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF generated and saved locally')),
    );
  }


  Future<bool> registerAttendance(int studentMat, ElementConst elementConst, SchoolYear schoolYear) async {
    final dbConfigInstance = DatabaseConfig.instance;

    AttendanceDto attendanceDto = AttendanceDto(
      studentMat: studentMat,
      elementConstID: elementConst.elementConstID,
      yearID: schoolYear.yearID,
      dateTime: DateTime.now(),
    );

    bool result = await dbConfigInstance.registerNewAttendance(attendanceDto);
    return result;
  }

  void _handleRegisterAttendance() async {
    if (!mounted) return; // Ensure the widget is still mounted before proceeding

    setState(() {
      _isLoading = true;
    });

    try {
      int studentMat = int.parse(widget.scannedCode);
      bool isRecorded = await registerAttendance(studentMat, widget.selectedElement, widget.selectedYear);

      if (!mounted) return; // Ensure the widget is still mounted after async call
      if (isRecorded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance recorded successfully')),
        );
        setState(() {
          _isAttendanceRecorded = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Présence déjà enregistrée'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isAttendanceRecorded = false;
        });
      }
    } catch (e) {
      if (!mounted) return; // Ensure the widget is still mounted after async call
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error recording attendance: $e')),
      );
    } finally {
      if (!mounted) return; // Ensure the widget is still mounted before updating state
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _handleRegisterAttendance();
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final String currentDateTime = dateFormat.format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Recorded'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(), // Header
            const SizedBox(height: 20),
            _buildVerifiedIcon(), // Verified icon added here
            const SizedBox(height: 20),
            _buildDetailsSection(currentDateTime),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const Spacer(), // Push the copyright message to the bottom
            const Divider(),
            const Center(
              child: Text(
                '© 2024 ULPGL. All rights reserved.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  "${widget.selectedElement.name} | ${widget.selectedElement.cmiHours} hours",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const Icon(Icons.school, color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedIcon() {
    return const Center(
      child: Icon(
        Icons.verified_user,
        color: Colors.green,
        size: 200,
      ),
    );
  }

  Widget _buildDetailsSection(String currentDateTime) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentDateTime,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 10),
            Text(
              "Student : ${widget.scannedCode}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ValidateAndProceedButton(
          selectedPromotion: '',
          selectedElement: widget.selectedElement,
          selectedYear: widget.selectedYear,
          isFloatingActionButton: false, // Set to false for IconButton
        ),
        _buildIconButton(Icons.print, "Print", () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Print initiated')),
          );
        }),
        _buildIconButton(Icons.stop, "Stop", () async {
          _backupData.sendData(await _backupData.backupData());
          Navigator.popUntil(context, (route) => route.isFirst);
        }),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, String label, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.blueAccent),
          iconSize: 30,
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.blueAccent),
        ),
      ],
    );
  }
}
