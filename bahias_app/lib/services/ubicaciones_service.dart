import 'package:cloud_firestore/cloud_firestore.dart';

class UbicacionesService {
  final _db = FirebaseFirestore.instance;
  final _collection = 'Ubicacion';

  Stream<QuerySnapshot<Map<String, dynamic>>> streamUbicaciones() {
    // Si tienes el campo Nombre, ordena por Nombre; si no, por id
    return _db.collection(_collection)
      .orderBy('Nombre', descending: false)
      .snapshots();
  }

  Future<void> create({
    required String id,
    required String nombre,
    String? descripcion,
  }) async {
    await _db.collection(_collection).doc(id).set({
      'Nombre': nombre,
      if (descripcion != null && descripcion.trim().isNotEmpty)
        'Descripcion': descripcion,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> update({
    required String id,
    String? nombre,
    String? descripcion,
  }) async {
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (nombre != null) data['Nombre'] = nombre;
    if (descripcion != null) data['Descripcion'] = descripcion;
    await _db.collection(_collection).doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }
}
