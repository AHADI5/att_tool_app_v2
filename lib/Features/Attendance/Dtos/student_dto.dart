class StudentDto {
  final int studentMat ;

  const StudentDto ({

    required this.studentMat
  }) ;

  //Factory constructor to create a student from a json map
  factory StudentDto .fromJson(Map<String , dynamic> json) {
    return StudentDto (
        studentMat: json['studentMat']) ;
  }

}