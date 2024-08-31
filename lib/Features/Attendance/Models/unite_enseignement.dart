
import '../Dtos/AttendanceDto.dart';
import 'attendance.dart';

class UniteEnseignement {
  final int uniteEnseignID;
  final int credits;
  final int level;
  final String name;
  final String filiare;
  final String titulaire;
  final String description  ;
  final List<ElementConst> elementConstituf;

  const UniteEnseignement({
    required this.uniteEnseignID,
    required this.credits,
    required this.level,
    required this.name,
    required this.elementConstituf,
    required this.filiare,
    required this.titulaire,
    required this.description,
  });

  // Factory constructor to create a UniteEnseignement from a JSON map
  factory UniteEnseignement.fromJson(Map<String, dynamic> json) {
    var elementsJson = json['elementConstitufList'] as List;
    List<ElementConst> elementList = elementsJson.map((e) => ElementConst.fromJson(e)).toList();

    return UniteEnseignement(
      description:  json['description'],
      uniteEnseignID: json['uniteEnseignID'],
      credits: json['credits'],
      level: json['level'],
      name: json['name'],
      filiare: json['filiare'],
      titulaire: json['titular'],
      elementConstituf: elementList,
    );
  }

  // Method to convert a UniteEnseignement instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'uniteEnseignID': uniteEnseignID,
      'credits': credits,
      'level': level,
      'name': name,
      'filiare': filiare,
      'titulaire': titulaire,
      'elementConstituf': elementConstituf.map((e) => e.toJson()).toList(),
    };
  }
}


class ElementConst {
  final int elementConstID;
  final String name;
  final int cmiHours;
  final int tdHours;
  final int tpHours;
  final List<Attendance> attendances;

  const ElementConst({
    required this.attendances,
    required this.name,
    required this.elementConstID,
    required this.cmiHours,
    required this.tdHours,
    required this.tpHours, required uniteEnseignID,
  });

  // Factory constructor to create an ElementConst from a JSON map
  factory ElementConst.fromJson(Map<String, dynamic> json) {
    var attendancesJson = json['attendances'] as List;
    List<Attendance> attendanceList = attendancesJson.map((e) => Attendance.fromJson(e)).toList();

    return ElementConst(
      elementConstID: json['elementConstID'],
      name: json['ecName'],
      cmiHours: json['cmiHours'],
      tdHours: json['tdHours'],
      tpHours: json['tpHours'],
      attendances: attendanceList, uniteEnseignID: json['uniteEnseignID'],
    );
  }

  // Method to convert an ElementConst instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'elementConstID': elementConstID,
      'name': name,
      'cmiHours': cmiHours,
      'tdHours': tdHours,
      'tpHours': tpHours,
      'attendances': attendances.map((e) => e.toJson()).toList(),
    };
  }
}
