import 'dart:convert';
import 'dart:developer';

import '../../../db_init.dart';
import '../Dtos/unite_ensei_dto.dart';
import '../Models/unite_enseignement.dart';
import 'package:http/http.dart' as http;

class Synchronisation {
  final dbConfig = DatabaseConfig.instance;

  Future<void> syncUE(String baseApi) async {
    try {
      final response = await http.get(Uri.parse('$baseApi/courses'));

      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));

        for (var jsonItem in jsonList) {
          try {
            UniteEnseignementDto uniteEnseignementDto =
            UniteEnseignementDto.fromJson(jsonItem);
            print('Inserting: $jsonItem');

            await DatabaseConfig.instance
                .insertUniteEnseign(uniteEnseignementDto);
          } catch (dbError) {
            log('Error inserting UniteEnseignement: $dbError');
          }
        }

        log("UniteEnseignements fetched and inserted successfully");
        List<UniteEnseignement> UE =
        await DatabaseConfig.instance.getAllUniteEnseignements();
        log("Fetched ${UE.length} UniteEnseignements from the database");
      } else {
        log("Failed to fetch UniteEnseignements: ${response.statusCode}");
        throw Exception("Failed to fetch UniteEnseignements");
      }
    } catch (e) {
      log("Error fetching or inserting UniteEnseignements: $e");
      throw Exception("Synchronization failed");
    }
  }
}
