import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/services.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});
  @override
  _RolesScreenState createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  final RolesService _service = RolesService();

  final _nameCtrl = TextEditingController();
  final _permCtrl = TextEditingController();

  ///  Crear nuevo rol
  Future<void> _agregarRol() async {
    await _service.agregarRol(_nameCtrl.text, _permCtrl.text);
    _nameCtrl.clear();
    _permCtrl.clear();
  }

  ///  Editar rol
  Future<void> _editarRol(String id, String nombre, List permisos) async {
    _nameCtrl.text = nombre;
    _permCtrl.text = permisos.join(', ');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Rol"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _permCtrl,
              decoration: const InputDecoration(labelText: 'Permisos (coma separada)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Guardar'),
            onPressed: () async {
              await _service.editarRol(id, _nameCtrl.text, _permCtrl.text);
              _nameCtrl.clear();
              _permCtrl.clear();
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  ///  Eliminar rol
  Future<void> _eliminarRol(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar Rol"),
        content: const Text("¿Estás seguro de que deseas eliminar este rol?"),
        actions: [
          TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(
              child: const Text("Eliminar"),
              onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (confirmar == true) {
      await _service.eliminarRol(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Roles')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre del Rol'),
                ),
                TextField(
                  controller: _permCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Permisos (coma separada)',
                    hintText: 'crear, editar, eliminar, ver',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Rol'),
                  onPressed: _agregarRol,
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Lista de Roles',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _service.obtenerRolesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text("No hay roles aún."));
                }

                return ListView(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.security),
                      title: Text(data['nombre'] ?? ''),
                      subtitle: Text(
                        "Permisos: ${data['permisos']?.join(', ') ?? ''}",
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () => _editarRol(
                              doc.id,
                              data['nombre'],
                              List.from(data['permisos'] ?? []),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _eliminarRol(doc.id),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
