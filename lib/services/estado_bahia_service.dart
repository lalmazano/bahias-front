import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/estado_bahia.dart';

class EstadoBahiaService {
  static const String baseUrl = 'http://35.239.236.87:8080/api/EstadoBahias';

  Future<List<EstadoBahia>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => EstadoBahia.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener estados de bahías');
    }
  }

  Future<EstadoBahia> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return EstadoBahia.fromJson(json.decode(response.body));
    } else {
      throw Exception('Estado de bahía no encontrado');
    }
  }
}
