class Student {
  final int studentID ;
  final int studentMat ;

  const Student({
    required this.studentID ,
    required this.studentMat
}) ;

  //Factory constructor to create a student from a json map
  factory Student.fromJson(Map<String , dynamic> json) {
    return Student(
        studentID: json['studentID'],
        studentMat: json['studentMat']) ;
  }

}