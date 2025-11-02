import 'package:cloud_firestore/cloud_firestore.dart';

class EstadoBahiaService {
  final _estadoRef = FirebaseFirestore.instance.collection('Tipo_Estado');

  ///  Stream de estados de bahía
  Stream<QuerySnapshot> obtenerEstados() {
    return _estadoRef.snapshots();
  }

  ///  Agregar nuevo estado
  Future<void> agregarEstado(String nombre, String descripcion) async {
    if (nombre.trim().isEmpty || descripcion.trim().isEmpty) return;

    final id = nombre.trim().toLowerCase().replaceAll(' ', '_');

    await _estadoRef.doc(id).set({
      'nombre': nombre.trim(),
      'Descripcion': descripcion.trim(),
    });
  }

  ///  Editar estado existente
  Future<void> editarEstado(String id, String nombre, String descripcion) async {
    await _estadoRef.doc(id).update({
      'nombre': nombre.trim(),
      'Descripcion': descripcion.trim(),
    });
  }

  ///  Eliminar estado
  Future<void> eliminarEstado(String id) async {
    await _estadoRef.doc(id).delete();
  }
}
