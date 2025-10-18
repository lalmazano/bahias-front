import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/bay.dart';

class BahiaService {
  static const String baseUrl = 'http://35.239.236.87:8080/api/Bahias';

  Future<List<Bay>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((b) => Bay.fromJson(b)).toList();
    } else {
      throw Exception('Error al obtener bahías');
    }
  }

  Future<void> addBay(Bay bay) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bay.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al agregar bahía');
    }
  }

  Future<void> updateBay(int id, Bay bay) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(bay.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar bahía');
    }
  }

  Future<void> deleteBay(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar bahía');
    }
  }
}
