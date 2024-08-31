class AttendanceDto {

  final int studentMat; // references the student
  final int elementConstID;
  final int yearID; // references the current school year
  final DateTime dateTime;

  const AttendanceDto({

    required this.studentMat,
    required this.elementConstID,
    required this.yearID,
    required this.dateTime,
  });

  // Factory constructor to create an Attendance instance from a JSON map
  factory AttendanceDto.fromJson(Map<String, dynamic> json) {
    return AttendanceDto(
      studentMat: json['studentMat'],
      elementConstID: json['elementConstID'],
      yearID: json['yearID'],
      dateTime: DateTime.parse(json['dateTime']), // Parse the string into a DateTime
    );
  }

  // Method to convert an Attendance instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'studentMat': studentMat,
      'elementConstID': elementConstID,
      'yearID': yearID,
      'dateTime': dateTime.toIso8601String(), // Convert DateTime to a string format
    };
  }
}
