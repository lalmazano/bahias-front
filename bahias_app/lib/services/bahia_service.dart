import 'package:cloud_firestore/cloud_firestore.dart';

class BahiaService {
  final _firestore = FirebaseFirestore.instance;

  /// 🔹 Obtiene el mapa de estados
  Future<Map<String, String>> loadEstados() async {
    final snapshot = await _firestore.collection('Tipo_Estado').get();
    final map = <String, String>{};

    for (var doc in snapshot.docs) {
      map['Tipo_Estado/${doc.id}'] = doc.id.toLowerCase();
    }

    return map;
  }

  /// 🔹 Retorna stream de Bahías
  Stream<QuerySnapshot> getBahiasStream() {
    return _firestore.collection('Bahias').snapshots();
  }

  /// 🔹 Retorna stream de Reservas
  Stream<QuerySnapshot> getReservasStream() {
    return _firestore.collection('Reservas').snapshots();
  }

  /// 🔹 Calcula resumen de estados de bahías
  Future<Map<String, int>> calcularEstados(
      List<QueryDocumentSnapshot> docs, Map<String, String> estadoMap) async {
    int libres = 0, ocupadas = 0, reservadas = 0, mantenimiento = 0;

    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;
      dynamic ref = data['EstadoRef'];
      String estado = 'libre';

      if (ref is DocumentReference) {
        estado = estadoMap[ref.path] ?? 'libre';
      } else if (ref is String) {
        for (final key in estadoMap.keys) {
          if (ref.toLowerCase().contains(key.toLowerCase())) {
            estado = estadoMap[key]!;
            break;
          }
        }
      }

      switch (estado) {
        case 'mantenimiento':
          mantenimiento++;
          break;
        case 'ocupado':
          ocupadas++;
          break;
        case 'reservado':
          reservadas++;
          break;
        default:
          libres++;
      }
    }

    return {
      'libres': libres,
      'ocupadas': ocupadas,
      'reservadas': reservadas,
      'mantenimiento': mantenimiento,
    };
  }

  /// 🔹 Calcula indicadores de reservas
  Map<String, dynamic> calcularIndicadoresReservas(
      List<QueryDocumentSnapshot> docs) {
    final reservas =
        docs.map((e) => e.data() as Map<String, dynamic>).toList();

    final duraciones = reservas.map((r) {
      final inicio = (r['FechaInicio'] as Timestamp).toDate();
      final fin = (r['FechaFin'] as Timestamp).toDate();
      return fin.difference(inicio).inMinutes;
    }).toList();

    final promedio = duraciones.isEmpty
        ? 0
        : duraciones.reduce((a, b) => a + b) / duraciones.length;

    final proximas = reservas.where((r) {
      final fin = (r['FechaFin'] as Timestamp).toDate();
      return fin.isAfter(DateTime.now()) &&
          fin.isBefore(DateTime.now().add(const Duration(minutes: 10)));
    }).length;

    final hoy = DateTime.now();
    final activasHoy = reservas.where((r) {
      final inicio = (r['FechaInicio'] as Timestamp).toDate();
      final fin = (r['FechaFin'] as Timestamp).toDate();
      return hoy.isAfter(inicio) && hoy.isBefore(fin);
    }).length;

    return {
      'promedio': promedio,
      'proximas': proximas,
      'activasHoy': activasHoy,
    };
  }
}
