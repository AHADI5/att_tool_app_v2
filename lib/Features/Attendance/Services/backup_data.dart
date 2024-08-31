import 'dart:convert';


import 'package:http/http.dart' as http;

import '../../../db_init.dart';
import '../../../temp_constant.dart';
import '../Dtos/backup_request.dart';
import '../Dtos/unite_ensei_dto.dart';
import '../Models/attendance.dart';
import '../Models/school_year.dart';

class BackupData {
  final dbConfig = DatabaseConfig.instance;

  Future<List<AttendanceBackUp>> backupData() async {
    List<Attendance> allAttendances = await dbConfig.getAllAttendances();

    // Use `Future.wait` to handle all async operations together
    List<AttendanceBackUp> attendancesBackUpList = await Future.wait(
      allAttendances.map((attendance) async {
        ElementConstDto? elementConstDto =
            await dbConfig.getElementConstByID(attendance.elementConstID);
        SchoolYear? schoolYear =
            await dbConfig.getSchoolYearByID(attendance.yearID);

        return AttendanceBackUp(
          ecName: elementConstDto!.name,
          matStudent: attendance.studentMat,
          startYear: schoolYear!.startYear,
          endYear: schoolYear.endYear,
          dateTime: attendance.dateTime.toIso8601String(),
        );
      }).toList(),
    );
    //printing data
    for (Attendance attendance in allAttendances) {
      print(attendance.toJson());
    }
    //Backing up data to the backend

    return attendancesBackUpList;
  }

  Future<void> sendData(List<AttendanceBackUp> attendanceBackUp) async {
    try {
      http.Response response = await http.post(Uri.parse('$baseApi/attendance'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(attendanceBackUp.map((attendance) {
            return attendance.toJson();
          }).toList()));
      // Check the response status
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        print("Data posted successfully: ${response.body}");
      } else {
        // Error
        print("Failed to post data: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      // Handle network errors
      print("Error posting data: $e");
    }
  }
}
