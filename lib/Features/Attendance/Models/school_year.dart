class SchoolYear {
  final int yearID;
  final int startYear;
  final int endYear;

  const SchoolYear({
    required this.yearID,
    required this.startYear,
    required this.endYear,
  });

  // Factory constructor to create a SchoolYear from JSON
  factory SchoolYear.fromJson(Map<String, dynamic> json) {
    return SchoolYear(
      yearID: json['yearID'],
      startYear: json['startYear'],
      endYear: json['endYear'],
    );
  }

  // Method to convert a SchoolYear instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'yearID': yearID,
      'startYear': startYear,
      'endYear': endYear,
    };
  }
}
