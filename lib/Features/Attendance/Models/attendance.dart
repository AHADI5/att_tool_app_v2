class Attendance {
  final int attendanceID ;
  final int studentMat ; // references the student
  final int elementConstID;
  final int yearID  ; // references the current schoolyear
  final DateTime dateTime;

  const Attendance({
    required this.attendanceID ,
    required this.studentMat ,
    required this.elementConstID,
    required this.yearID ,
    required this.dateTime
  }) ;

  // Convert a JSON map to an Attendance object
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceID: json['attendanceID'],
      studentMat: json['studentMat'],
      elementConstID: json['elementConstID'],
      yearID: json['yearID'],
      dateTime: DateTime.parse(json['dateTime']),
    );
  }

  // Convert an Attendance object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'attendanceID': attendanceID,
      'studentMat': studentMat,
      'elementConstID': elementConstID,
      'yearID': yearID,
      'dateTime': dateTime.toIso8601String(), // Convert DateTime to ISO8601 string
    };
  }



}