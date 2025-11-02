import 'package:cloud_firestore/cloud_firestore.dart';

class TipoBahiaService {
  final _tipoRef = FirebaseFirestore.instance.collection('Tipo_Bahia');

  /// Stream de tipos de bahía
  Stream<QuerySnapshot> obtenerTipos() {
    return _tipoRef.snapshots();
  }

  ///  Agregar nuevo tipo de bahía
  Future<void> agregarTipo(String nombre, String descripcion) async {
    if (nombre.trim().isEmpty || descripcion.trim().isEmpty) return;

    final id = nombre.trim().toLowerCase().replaceAll(' ', '_');

    await _tipoRef.doc(id).set({
      'nombre': nombre.trim(),
      'Descripcion': descripcion.trim(),
    });
  }

  ///  Editar tipo de bahía existente
  Future<void> editarTipo(String id, String nombre, String descripcion) async {
    await _tipoRef.doc(id).update({
      'nombre': nombre.trim(),
      'Descripcion': descripcion.trim(),
    });
  }

  ///  Eliminar tipo de bahía
  Future<void> eliminarTipo(String id) async {
    await _tipoRef.doc(id).delete();
  }
}
