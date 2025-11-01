import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});
  @override
  _RolesScreenState createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  final _db = FirebaseFirestore.instance;
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _permCtrl = TextEditingController();

  Future<void> _addRole() async {
    final id = _idCtrl.text.trim();
    final nombre = _nameCtrl.text.trim();
    final permisos = _permCtrl.text.split(',').map((e) => e.trim()).toList();

    if (id.isEmpty || nombre.isEmpty) return;

    await _db.collection('Roles').doc(id).set({
      'nombre': nombre,
      'permisos': permisos,
    });

    _idCtrl.clear();
    _nameCtrl.clear();
    _permCtrl.clear();
  }

  Future<void> _editRole(String id, String nombre, List permisos) async {
    _nameCtrl.text = nombre;
    _permCtrl.text = permisos.join(', ');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Rol"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: _permCtrl, decoration: const InputDecoration(labelText: 'Permisos (coma separada)')),
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
              final nuevoNombre = _nameCtrl.text.trim();
              final nuevosPermisos = _permCtrl.text.split(',').map((e) => e.trim()).toList();
              await _db.collection('Roles').doc(id).update({
                'nombre': nuevoNombre,
                'permisos': nuevosPermisos,
              });
              _nameCtrl.clear();
              _permCtrl.clear();
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRole(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Eliminar Rol"),
        content: const Text("¿Estás seguro de que deseas eliminar este rol?"),
        actions: [
          TextButton(child: const Text("Cancelar"), onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(child: const Text("Eliminar"), onPressed: () => Navigator.pop(context, true)),
        ],
      ),
    );

    if (confirmar == true) {
      await _db.collection('Roles').doc(id).delete();
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
                TextField(controller: _idCtrl, decoration: const InputDecoration(labelText: 'ID del Rol')),
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
                TextField(controller: _permCtrl, decoration: const InputDecoration(labelText: 'Permisos (coma separada)')),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Rol'),
                  onPressed: _addRole,
                ),
              ],
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('Lista de Roles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('Roles').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text("No hay roles aún."));

                return ListView(
                  children: docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.security),
                      title: Text(data['nombre'] ?? ''),
                      subtitle: Text("Permisos: ${data['permisos']?.join(', ') ?? ''}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blueAccent),
                            onPressed: () => _editRole(doc.id, data['nombre'], List.from(data['permisos'] ?? [])),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () => _deleteRole(doc.id),
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
