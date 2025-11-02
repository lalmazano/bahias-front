import 'package:cloud_firestore/cloud_firestore.dart';

class AsignarRolesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ///  Obtiene todos los usuarios
  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final snapshot = await _firestore.collection('Usuarios').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'nombre': data['nombre'],
        'correo': data['correo'],
        'rolRef': data['rolRef'],
      };
    }).toList();
  }

  ///  Obtiene todos los roles disponibles
  Future<List<Map<String, dynamic>>> obtenerRoles() async {
    final snapshot = await _firestore.collection('Roles').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'nombre': data['nombre'],
        'permisos': data['permisos'],
        'ref': doc.reference,
      };
    }).toList();
  }

  /// Actualiza el rol asignado a un usuario
  Future<void> actualizarRol(String usuarioId, DocumentReference nuevoRol) async {
    await _firestore.collection('Usuarios').doc(usuarioId).update({
      'rolRef': nuevoRol,
    });
  }
}
