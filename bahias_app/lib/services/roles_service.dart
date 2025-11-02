import 'package:cloud_firestore/cloud_firestore.dart';

class RolesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  ///  Obtener todos los roles en tiempo real
  Stream<QuerySnapshot> obtenerRolesStream() {
    return _db.collection('Roles').snapshots();
  }

  ///  Obtener snapshot único de roles
  Future<QuerySnapshot> obtenerRoles() async {
    return await _db.collection('Roles').get();
  }

  ///  Agregar rol nuevo (ID automático con nombre en minúsculas y guiones bajos)
  Future<void> agregarRol(String nombre, String permisosRaw) async {
    final permisos = permisosRaw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (nombre.isEmpty) return;

    final id = nombre.toLowerCase().replaceAll(' ', '_');

    await _db.collection('Roles').doc(id).set({
      'nombre': nombre,
      'permisos': permisos,
    });
  }

  ///  Editar rol existente
  Future<void> editarRol(String id, String nuevoNombre, String nuevosPermisosRaw) async {
    final nuevosPermisos = nuevosPermisosRaw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    await _db.collection('Roles').doc(id).update({
      'nombre': nuevoNombre,
      'permisos': nuevosPermisos,
    });
  }

  ///  Eliminar rol
  Future<void> eliminarRol(String id) async {
    await _db.collection('Roles').doc(id).delete();
  }
}
