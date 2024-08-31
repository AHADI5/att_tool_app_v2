
import 'dart:developer';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'Features/Attendance/Dtos/AttendanceDto.dart';
import 'Features/Attendance/Dtos/unite_ensei_dto.dart';
import 'Features/Attendance/Models/attendance.dart';
import 'Features/Attendance/Models/school_year.dart';
import 'Features/Attendance/Models/unite_enseignement.dart';

class DatabaseConfig {
  // Singleton pattern
  static final DatabaseConfig _instance = DatabaseConfig._internal();

  DatabaseConfig._internal();

  static DatabaseConfig get instance => _instance;

  Database? _database;

  // Get the instance of the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'att_tool_db'),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      version: 2,
    );
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add any necessary schema changes for version 2
    }
  }

  void _onCreate(Database db, int version) async {
    // Create the Tapi table
    await db.execute(
      'CREATE TABLE tapi('
      'tapi INTEGER PRIMARY KEY AUTOINCREMENT, '
      'url TEXT '
      ')',
    );

    // Create the UniteEnseignement table
    await db.execute(
      'CREATE TABLE UniteEnseign('
      'uniteEnseignID INTEGER PRIMARY KEY AUTOINCREMENT, '
      'credits INTEGER, '
      'level INTEGER, '
      'name TEXT, '
      'filiare TEXT, '
      'titulaire TEXT ,'
      'description TEXT'
      ')',
    );

    // Create the ElementConst table
    await db.execute(
      'CREATE TABLE ElementConst('
      'elementConstID INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT, '
      'cmiHours INTEGER, '
      'tdHours INTEGER, '
      'tpHours INTEGER, '
      'uniteEnseignID INTEGER, '
      'FOREIGN KEY(uniteEnseignID) REFERENCES UniteEnseign(uniteEnseignID)'
      ')',
    );

    // Create the Attendance table
    await db.execute(
      'CREATE TABLE Attendance('
      'attendanceID INTEGER PRIMARY KEY AUTOINCREMENT, '
      'studentMat INTEGER, '
      'elementConstID INTEGER, '
      'yearID INTEGER, '
      'dateTime TEXT, '
      'FOREIGN KEY(elementConstID) REFERENCES ElementConst(elementConstID), '
      'FOREIGN KEY(yearID) REFERENCES SchoolYear(yearID)'
      ')',
    );

    // Create the SchoolYear table
    await db.execute(
      'CREATE TABLE SchoolYear('
      'yearID INTEGER PRIMARY KEY AUTOINCREMENT, '
      'startYear INTEGER, '
      'endYear INTEGER'
      ')',
    );

    log("TABLES CREATED SUCCESSFULLY");
  }

  Future<void> insertUniteEnseign(UniteEnseignementDto uniteEN) async {
    final db = await database;

    // Retrieve all existing UniteEnseignements
    List<UniteEnseignement> ueList = await getAllUniteEnseignements();
    List<UniteEnseignementDto> ueListDtos = [];

    for (UniteEnseignement uniteEnseignement in ueList) {
      // Convert each UniteEnseignement to UniteEnseignementDto
      UniteEnseignementDto uniteEnseignementItem = UniteEnseignementDto(
        credits: uniteEnseignement.credits,
        level: uniteEnseignement.level,
        name: uniteEnseignement.name,
        elementConstituf:
            uniteEnseignement.elementConstituf.map((elementConst) {
          return ElementConstDto(
            name: elementConst.name,
            cmiHours: elementConst.cmiHours,
            tdHours: elementConst.tdHours,
            tpHours: elementConst.tpHours,
          );
        }).toList(),
        filiare: uniteEnseignement.filiare,
        titulaire: uniteEnseignement.titulaire,
        description: uniteEnseignement.description,
      );
      ueListDtos.add(uniteEnseignementItem);
    }

    // Check if the UniteEnseignement already exists
    bool exists = ueListDtos
        .any((ue) => ue.name == uniteEN.name && ue.level == uniteEN.level);

    if (exists) {
      // If the UniteEnseignement exists, update it
      int existingUniteEnseignID = await getUniteEnseignementId(
        name: uniteEN.name,
        level: uniteEN.level,
      );

      // Update the UniteEnseign record
      await db.update(
        'UniteEnseign',
        {
          'credits': uniteEN.credits,
          'level': uniteEN.level,
          'name': uniteEN.name,
          'filiare': uniteEN.filiare,
          'titulaire': uniteEN.titulaire,
          'description': uniteEN.description,
        },
        where: 'uniteEnseignID = ?',
        whereArgs: [existingUniteEnseignID],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (ElementConstDto elementConstDto in uniteEN.elementConstituf) {
        // Make sure to match elements using their unique identifier (e.g., elementConstID)
        await db.update(
          'ElementConst',
          {
            'name': elementConstDto.name,
            'cmiHours': elementConstDto.cmiHours,
            'tdHours': elementConstDto.tdHours,
            'tpHours': elementConstDto.tpHours,
          },
          where: 'name = ? AND uniteEnseignID = ?',
          whereArgs: [elementConstDto.name, existingUniteEnseignID],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        log("Elements Updated");
      }

      log("Successfully updated");
    } else {
      // If the UniteEnseignement does not exist, insert it
      log("UniteEnseignement doesn't exist, creating a new one");

      // Insert the UniteEnseign record
      int uniteEnseignID = await db.insert(
        'UniteEnseign',
        {
          'credits': uniteEN.credits,
          'level': uniteEN.level,
          'name': uniteEN.name,
          'filiare': uniteEN.filiare,
          'titulaire': uniteEN.titulaire,
          'description': uniteEN.description,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert ElementConst records
      for (var element in uniteEN.elementConstituf) {
        await db.insert(
          'ElementConst',
          {
            'name': element.name,
            'cmiHours': element.cmiHours,
            'tdHours': element.tdHours,
            'tpHours': element.tpHours,
            'uniteEnseignID': uniteEnseignID,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      log("Successfully inserted new UniteEnseignement");
    }
  }

// Helper method to get the UniteEnseignement ID based on name and level
  Future<int> getUniteEnseignementId(
      {required String name, required int level}) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'UniteEnseign',
      columns: ['uniteEnseignID'],
      where: 'name = ? AND level = ?',
      whereArgs: [name, level],
    );
    if (result.isNotEmpty) {
      return result.first['uniteEnseignID'];
    } else {
      throw Exception('UniteEnseignement not found');
    }
  }

  Future<UniteEnseignement?> getUniteEnseignement(int uniteEnseignID) async {
    final db = await database;

    // Retrieve the UniteEnseignement from the database
    List<Map<String, dynamic>> uniteEnseignResult = await db.query(
      'UniteEnseign',
      where: 'uniteEnseignID = ?',
      whereArgs: [uniteEnseignID],
    );

    if (uniteEnseignResult.isNotEmpty) {
      var uniteEnseignementJson = uniteEnseignResult.first;

      // Retrieve related ElementConst records
      List<Map<String, dynamic>> elementsResult = await db.query(
        'ElementConst',
        where: 'uniteEnseignID = ?',
        whereArgs: [uniteEnseignID],
      );

      // Convert the ElementConst records to a list of ElementConst objects
      List<ElementConst> elementConstituf = elementsResult.map((elementJson) {
        return ElementConst(
          elementConstID: elementJson['elementConstID'],
          name: elementJson['name'],
          cmiHours: elementJson['cmiHours'],
          tdHours: elementJson['tdHours'],
          tpHours: elementJson['tpHours'],
          uniteEnseignID: elementJson['uniteEnseignID'],
          attendances: [],
        );
      }).toList();

      // Create and return the UniteEnseignement object
      return UniteEnseignement(
        uniteEnseignID: uniteEnseignementJson['uniteEnseignID'],
        credits: uniteEnseignementJson['credits'],
        level: uniteEnseignementJson['level'],
        name: uniteEnseignementJson['name'],
        filiare: uniteEnseignementJson['filiare'],
        titulaire: uniteEnseignementJson['titulaire'],
        elementConstituf: elementConstituf,
        description: uniteEnseignementJson['description'],
      );
    }

    return null; // Return null if no UniteEnseignement is found
  }

  //Retrieve all UE registred
  Future<List<UniteEnseignement>> getAllUniteEnseignements() async {
    final db = await database;

    // Retrieve all UniteEnseignement records
    List<Map<String, dynamic>> uniteEnseignResults =
        await db.query('UniteEnseign');

    // Initialize a list to hold all UniteEnseignement objects
    List<UniteEnseignement> uniteEnseignements = [];

    for (var uniteEnseignementJson in uniteEnseignResults) {
      int uniteEnseignID = uniteEnseignementJson['uniteEnseignID'];

      // Retrieve related ElementConst records for each UniteEnseignement
      List<Map<String, dynamic>> elementsResult = await db.query(
        'ElementConst',
        where: 'uniteEnseignID = ?',
        whereArgs: [uniteEnseignID],
      );

      // Convert the ElementConst records to a list of ElementConst objects
      List<ElementConst> elementConstituf = elementsResult.map((elementJson) {
        return ElementConst(
          elementConstID: elementJson['elementConstID'],
          name: elementJson['name'],
          cmiHours: elementJson['cmiHours'],
          tdHours: elementJson['tdHours'],
          tpHours: elementJson['tpHours'],
          uniteEnseignID: elementJson['uniteEnseignID'],
          attendances: [],
        );
      }).toList();

      // Create a UniteEnseignement object with the ElementConst list and add it to the final list
      UniteEnseignement uniteEnseignement = UniteEnseignement(
        uniteEnseignID: uniteEnseignementJson['uniteEnseignID'],
        credits: uniteEnseignementJson['credits'],
        level: uniteEnseignementJson['level'],
        name: uniteEnseignementJson['name'],
        filiare: uniteEnseignementJson['filiare'],
        titulaire: uniteEnseignementJson['titulaire'],
        elementConstituf: elementConstituf,
        description: uniteEnseignementJson['description'],
      );

      // Convert the UniteEnseignement object to JSON and print it
      uniteEnseignements.add(uniteEnseignement);
    }
    return uniteEnseignements;
  }

  //Register Attendance
  Future<bool> registerNewAttendance(AttendanceDto attendance) async {
    final db = await database;

    // Convert the dateTime to just the date part (YYYY-MM-DD)
    final String attendanceDate =
        attendance.dateTime.toIso8601String().split('T').first;

    // Check if the attendance record for that day already exists
    final List<Map<String, dynamic>> existingRecords = await db.query(
      'Attendance',
      where:
          'studentMat = ? AND elementConstID = ? AND yearID = ? AND date(dateTime) = ?',
      whereArgs: [
        attendance.studentMat,
        attendance.elementConstID,
        attendance.yearID,
        attendanceDate
      ],
    );

    // If the record exists, return false and do not save
    if (existingRecords.isNotEmpty) {
      print(
          "Attendance for ${attendance.studentMat} on $attendanceDate already exists");
      return false;
    }

    // If the record does not exist, insert the new attendance record
    await db.insert("Attendance", attendance.toJson());
    print("${attendance.studentMat} is present on $attendanceDate");
    return true;
  }

  Future<List<Attendance>> getAllAttendances() async {
    final db = await database;
    List<Map<String, dynamic>> attendances = await db.query('Attendance');
    List<Attendance> attendanceList = attendances.map((attendanceItem) {
      return Attendance(
          attendanceID: attendanceItem['attendanceID'],
          studentMat: attendanceItem['studentMat'],
          elementConstID: attendanceItem['elementConstID'],
          yearID: attendanceItem['yearID'],
          dateTime: DateTime.parse(attendanceItem['dateTime']));
    }).toList();

    return attendanceList;
  }

  Future<void> insertSchoolyear(int startYear, int endYear) async {
    final db = await database;
    await db.insert('SchoolYear', {'startYear': startYear, 'endYear': endYear});
  }

  Future<List<SchoolYear>> getAllSchoolYears() async {
    final db = await database;
    List<Map<String, dynamic>> schoolYearsRecord = await db.query('SchoolYear');
    List<SchoolYear> schoolYears = schoolYearsRecord.map((schoolYear) {
      return SchoolYear(
          yearID: schoolYear['yearID'],
          startYear: schoolYear['startYear'],
          endYear: schoolYear['endYear']);
    }).toList();
    return schoolYears;
  }

  Future<SchoolYear?> getSchoolYearByID(int schoolYearID) async {
    final db = await database;
    List<Map<String, dynamic>> schoolYearResult = await db.query(
      'SchoolYear',
      where: 'yearID = ?',
      whereArgs: [schoolYearID],
    );

    if (schoolYearResult.isNotEmpty) {
      var schoolYearJson = schoolYearResult.first;

      return SchoolYear(
          yearID: schoolYearJson['yearID'],
          startYear: schoolYearJson['startYear'],
          endYear: schoolYearJson['endYear']);
    }
    return null;
  }

  Future<ElementConstDto?> getElementConstByID(int elementConstID) async {
    final db = await database;
    List<Map<String, dynamic>> elementConstResult = await db.query(
        'ElementConst',
        where: 'elementConstID = ?',
        whereArgs: [elementConstID]);

    if (elementConstResult.isNotEmpty) {
      var elementJson = elementConstResult.first;

      return ElementConstDto(
          name: elementJson['name'],
          cmiHours: elementJson['cmiHours'],
          tdHours: elementJson['tdHours'],
          tpHours: elementJson['tpHours']);
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> queryUniteEnseignement() async {
    final db = await database;

    // Query the UniteEnseign table for all records
    List<Map<String, dynamic>> results = await db.query('UniteEnseign');

    return results;
  }

  Future<List<Attendance>> getAttendancesByElemetConstName(
      int yearID, int elementConstID) async {
    final db = await database;

    List<Map<String, dynamic>> attendances = await db.query('Attendance',
        where: 'yearID = ? AND elementConstID = ?',
        whereArgs: [yearID, elementConstID]);
    List<Attendance> attendanceList = attendances.map((attendanceItem) {
      return Attendance(
          attendanceID: attendanceItem['attendanceID'],
          studentMat: attendanceItem['studentMat'],
          elementConstID: attendanceItem['elementConstID'],
          yearID: attendanceItem['yearID'],
          dateTime: DateTime.parse(attendanceItem['dateTime']));
    }).toList();

    return attendanceList;
  }



  Future<void> insertOrUpdateApi(String api) async {
    final db = await database;

    // Query the database to check if there is an existing record
    final List<Map<String, dynamic>> existingRecords = await db.query('tapi');

    if (existingRecords.isNotEmpty) {
      // There is an existing record, update it with the new URL
      await db.update(
        'tapi',
        {'url': api},
        where: 'id = ?', // Assuming there's an 'id' column
        whereArgs: [existingRecords.first['id']], // Use the id of the existing record
      );
    } else {
      // No existing record, insert the new one
      await db.insert(
        'tapi',
        {'url': api},
      );
    }
  }

  Future<String> getApiUrl() async {
    final db = await database;

    // Query the database to check if there is an existing record
    final List<Map<String, dynamic>> existingRecords = await db.query('tapi');

    if (existingRecords.isNotEmpty) {
      // Return the URL from the first record
      return existingRecords.first['url'] as String;
    } else {
      // Return a default URL or an empty string if no record exists
      return "http://default-url.com"; // You can customize this default URL
    }
  }


}
