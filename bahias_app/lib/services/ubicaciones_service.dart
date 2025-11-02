import 'package:cloud_firestore/cloud_firestore.dart';

class UbicacionesService {
  final _ref = FirebaseFirestore.instance.collection('Ubicacion');

  /// 📡 Stream en tiempo real
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUbicaciones() {
    return _ref.orderBy(FieldPath.documentId).snapshots();
  }

  /// ➕ Crear nueva ubicación con ID incremental (Ubicacion 1, 2, 3...)
  Future<void> create({
    required String nombre,
    required String descripcion,
  }) async {
    if (nombre.trim().isEmpty || descripcion.trim().isEmpty) return;

    // Obtener documentos existentes
    final snapshot = await _ref.get();

    // Buscar el siguiente número disponible
    int nextNumber = 1;
    final existingIds = snapshot.docs.map((doc) => doc.id).toList();

    while (existingIds.contains('Ubicacion $nextNumber')) {
      nextNumber++;
    }

    final newId = 'Ubicacion $nextNumber';

    await _ref.doc(newId).set({
      'Nombre': nombre.trim(),
      'Descripcion': descripcion.trim(),
    });
  }

  /// ✏️ Editar campos (nombre, descripción) pero mantener ID fijo
  Future<void> update({
    required String id,
    required String nombre,
    required String descripcion,
  }) async {
    await _ref.doc(id).update({
      'Nombre': nombre.trim(),
      'Descripcion': descripcion.trim(),
    });
  }

  /// 🗑️ Eliminar ubicación
  Future<void> delete(String id) async {
    await _ref.doc(id).delete();
  }
}
