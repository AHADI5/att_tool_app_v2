class AttendanceBackUp {
  final String ecName;
  final int matStudent;
  final int startYear;
  final int endYear;
  final String dateTime;

  AttendanceBackUp({
    required this.ecName,
    required this.matStudent,
    required this.startYear,
    required this.endYear,
    required this.dateTime,
  });

  // Factory constructor for creating an instance from a JSON map
  factory AttendanceBackUp.fromJson(Map<String, dynamic> json) {
    return AttendanceBackUp(
      ecName: json['ecName'] ?? '',
      matStudent: json['matStudent'] ?? 0,
      startYear: json['startYear'] ?? 0,
      endYear: json['endYear'] ?? 0,
      dateTime: json['dateTime'] ?? '',
    );
  }

  // Method for converting an instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'ecName': ecName,
      'matStudent': matStudent,
      'startYear': startYear,
      'endYear': endYear,
      'dateTime': dateTime,
    };
  }
}
