// lib/data/services/reserva_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/reservation.dart';

class ReservaService {
  static const String baseUrl = 'http://35.239.236.87:8080/api/Reserva';

  Future<List<Reservation>> getAll() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((r) => Reservation.fromJson(r)).toList();
    } else {
      throw Exception('Error al obtener reservas (${response.statusCode})');
    }
  }

  Future<Reservation> getById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));

    if (response.statusCode == 200) {
      return Reservation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Reserva no encontrada');
    }
  }

  Future<void> addReserva(Reservation reserva) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reserva.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear reserva');
    }
  }

  Future<void> updateReserva(int id, Reservation reserva) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reserva.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar reserva');
    }
  }

  Future<void> deleteReserva(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar reserva');
    }
  }
}
