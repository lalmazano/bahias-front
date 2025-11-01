import 'package:cloud_firestore/cloud_firestore.dart';

class EstadisticasService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///  Obtiene las 10 reservas más recientes
  Stream<QuerySnapshot<Map<String, dynamic>>> getReservasRecientes() {
    return _firestore
        .collection('Reservas')
        .orderBy('FechaInicio', descending: true)
        .limit(10)
        .snapshots();
  }

  ///  Obtiene todas las reservas (para procesar por usuario o ubicación)
  Stream<QuerySnapshot<Map<String, dynamic>>> getTodasLasReservas() {
    return _firestore.collection('Reservas').snapshots();
  }

  ///  Obtiene todos los usuarios para mapear sus nombres
  Future<Map<String, String>> getNombresUsuarios() async {
    final snap = await _firestore.collection('Usuarios').get();
    return {
      for (var doc in snap.docs)
        doc.id: (doc.data()['nombre'] ?? 'Desconocido').toString(),
    };
  }

  ///  Obtiene todas las ubicaciones (ID → Nombre)
  Future<Map<String, String>> getNombresUbicaciones() async {
    final snap = await _firestore.collection('Ubicacion').get();
    return {
      for (var doc in snap.docs)
        doc.id: (doc.data()['Nombre'] ?? doc.id).toString(),
    };
  }

  ///  Calcula conteo de reservas por usuario
  Future<Map<String, int>> getConteoReservasPorUsuario() async {
    final reservas = await _firestore.collection('Reservas').get();
    final Map<String, int> conteo = {};

    for (var r in reservas.docs) {
      final data = r.data();
      final userRef = data['UsuarioRef'];
      if (userRef is DocumentReference) {
        final id = userRef.id;
        conteo[id] = (conteo[id] ?? 0) + 1;
      }
    }
    return conteo;
  }

  ///  Calcula conteo de reservas por ubicación
  Future<Map<String, int>> getConteoReservasPorUbicacion() async {
    final reservas = await _firestore.collection('Reservas').get();
    final Map<String, int> conteo = {};

    for (var r in reservas.docs) {
      final data = r.data();
      final bahias = (data['BahiasRefs'] ?? []) as List;

      for (final ref in bahias) {
        if (ref is DocumentReference) {
          final bahiaDoc = await ref.get();
          final bahiaData = bahiaDoc.data() as Map<String, dynamic>?;

          if (bahiaData != null && bahiaData.containsKey('UbicacionRef')) {
            final ubicRef = bahiaData['UbicacionRef'];
            if (ubicRef is DocumentReference) {
              final idUbic = ubicRef.id;
              conteo[idUbic] = (conteo[idUbic] ?? 0) + 1;
            }
          }
        }
      }
    }

    return conteo;
  }
}
