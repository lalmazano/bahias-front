import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/ubicacion.dart';

class UbicacionService {
  static const String baseUrl = 'http://35.239.236.87:8080/api/Ubicacion';

  Future<List<Ubicacion>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Ubicacion.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener ubicaciones (${response.statusCode})');
    }
  }

  Future<Ubicacion> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return Ubicacion.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ubicación no encontrada');
    }
  }

  Future<void> addUbicacion(Ubicacion ubicacion) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(ubicacion.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear ubicación');
    }
  }

  Future<void> updateUbicacion(int id, Ubicacion ubicacion) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(ubicacion.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar ubicación');
    }
  }

  Future<void> deleteUbicacion(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar ubicación');
    }
  }
}
