import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AsignarRolesScreen extends StatefulWidget {
  const AsignarRolesScreen({super.key});

  @override
  State<AsignarRolesScreen> createState() => _AsignarRolesScreenState();
}

class _AsignarRolesScreenState extends State<AsignarRolesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _obtenerUsuarios() async {
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

  Future<List<Map<String, dynamic>>> _obtenerRoles() async {
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

  Future<void> _actualizarRol(String usuarioId, DocumentReference nuevoRol) async {
    await _firestore.collection('Usuarios').doc(usuarioId).update({
      'rolRef': nuevoRol,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Roles')),
      body: FutureBuilder(
        future: Future.wait([_obtenerUsuarios(), _obtenerRoles()]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final usuarios = snapshot.data![0] as List<Map<String, dynamic>>;
          final roles = snapshot.data![1] as List<Map<String, dynamic>>;

          return ListView.builder(
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];

              return ListTile(
                title: Text(usuario['nombre']),
                subtitle: Text(usuario['correo']),
                trailing: DropdownButton<DocumentReference>(
                  value: usuario['rolRef'],
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (nuevoRol) async {
                    if (nuevoRol != null) {
                      await _actualizarRol(usuario['id'], nuevoRol);
                      setState(() {
                        usuario['rolRef'] = nuevoRol;
                      });
                    }
                  },
                  items: roles.map((rol) {
                    return DropdownMenuItem<DocumentReference>(
                      value: rol['ref'],
                      child: Text(rol['nombre']),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
