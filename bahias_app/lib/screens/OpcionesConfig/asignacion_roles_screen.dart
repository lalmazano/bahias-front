import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/services.dart';

class AsignarRolesScreen extends StatefulWidget {
  const AsignarRolesScreen({super.key});

  @override
  State<AsignarRolesScreen> createState() => _AsignarRolesScreenState();
}

class _AsignarRolesScreenState extends State<AsignarRolesScreen> {
  final AsignarRolesService _service = AsignarRolesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignar Roles')),
      body: FutureBuilder(
        future: Future.wait([
          _service.obtenerUsuarios(),
          _service.obtenerRoles(),
        ]),
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
                      await _service.actualizarRol(usuario['id'], nuevoRol);
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
