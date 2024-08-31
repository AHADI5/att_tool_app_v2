class UniteEnseignementDto {

  final int credits;
  final int level;
  final String name;
  final String filiare;
  final String titulaire;
  final String description ;
  final List<ElementConstDto> elementConstituf;

  const UniteEnseignementDto({

    required this.credits,
    required this.level,
    required this.name,
    required this.elementConstituf,
    required this.filiare,
    required this.titulaire,
    required this.description
  });

  // Factory constructor to create a UniteEnseignement from a JSON map
  factory UniteEnseignementDto.fromJson(Map<String, dynamic> json) {
    var elementsJson = json['elementConstitutifList'] as List;
    List<ElementConstDto> elementList = elementsJson.map((e) => ElementConstDto.fromJson(e)).toList();

    return UniteEnseignementDto(

      credits: json['credits'],
      level: json['level'],
      name: json['name'],
      filiare: json['filiare'],
      titulaire: json['titular'],
      elementConstituf: elementList,
      description: json['description'],
    );
  }

  // Method to convert a UniteEnseignement instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'credits': credits,
      'level': level,
      'name': name,
      'filiare': filiare,
      'titulaire': titulaire,
      'elementConstituf': elementConstituf.map((e) => e.toJson()).toList(),
    };
  }
}

class ElementConstDto {
  final String name;
  final int cmiHours;
  final int tdHours;
  final int tpHours;

  const ElementConstDto({
    required this.name,
    required this.cmiHours,
    required this.tdHours,
    required this.tpHours,
  });

  // Factory constructor to create an ElementConst from a JSON map
  factory ElementConstDto.fromJson(Map<String, dynamic> json) {
    return ElementConstDto(

      name: json['ecName'],
      cmiHours: json['cmiHours'],
      tdHours: json['tdHours'],
      tpHours: json['tpHours'],
    );
  }

  // Method to convert an ElementConst instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cmiHours': cmiHours,
      'tdHours': tdHours,
      'tpHours': tpHours,
    };
  }
}
