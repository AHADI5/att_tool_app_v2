import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../../../db_init.dart';
import '../Models/attendance.dart';
import '../Models/school_year.dart';
import '../Models/unite_enseignement.dart';

Future<void> generateAndSavePdf(ElementConst elementConst, SchoolYear schoolYear) async {
  final DatabaseConfig db  =  DatabaseConfig.instance ;
  final pdf = pw.Document();
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/attendance_list_${elementConst.name}_${schoolYear.startYear}-${schoolYear.endYear}.pdf';
  List<Attendance>  attendanceList = await db.getAttendancesByElemetConstName(schoolYear.yearID , elementConst.elementConstID) ;

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          children: [
            pw.Text(
              'Liste de Présence',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              data: [
                <String>['Student Mat'],
                ...attendanceList.map((mat) => [mat.studentMat]),
              ],
            ),
          ],
        );
      },
    ),
  );

  final file = File(filePath);
  await file.writeAsBytes(await pdf.save());
}
