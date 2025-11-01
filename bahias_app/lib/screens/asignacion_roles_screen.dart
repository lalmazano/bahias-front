import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AsignarRolesScreen extends StatefulWidget {
  const AsignarRolesScreen({super.key});

  @override
  State<AsignarRolesScreen> createState() => _AsignarRolesScreenState();
}

class _AsignarRolesScreenState extends State<AsignarRolesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _usuarios = [];
  List<Map<String, dynamic>> _roles = [];

  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  DocumentReference? _rolSeleccionado;
  String? _usuarioEditandoId;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final usuarios = await _obtenerUsuarios();
    final roles = await _obtenerRoles();
    setState(() {
      _usuarios = usuarios;
      _roles = roles;
    });
  }

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
        'ref': doc.reference,
      };
    }).toList();
  }

  Future<void> _guardarUsuario() async {
    final nombre = _nombreCtrl.text.trim();
    final correo = _correoCtrl.text.trim();
    if (nombre.isEmpty || correo.isEmpty || _rolSeleccionado == null) return;

    final data = {
      'nombre': nombre,
      'correo': correo,
      'rolRef': _rolSeleccionado,
    };

    if (_usuarioEditandoId == null) {
      // Nuevo
      await _firestore.collection('Usuarios').add(data);
    } else {
      // Edición
      await _firestore.collection('Usuarios').doc(_usuarioEditandoId).update(data);
    }

    _limpiarFormulario();
    await _cargarDatos();
  }

  void _limpiarFormulario() {
    _nombreCtrl.clear();
    _correoCtrl.clear();
    _rolSeleccionado = null;
    _usuarioEditandoId = null;
  }

  Future<void> _eliminarUsuario(String id) async {
    await _firestore.collection('Usuarios').doc(id).delete();
    await _cargarDatos();
  }

  void _editarUsuario(Map<String, dynamic> usuario) {
    setState(() {
      _nombreCtrl.text = usuario['nombre'] ?? '';
      _correoCtrl.text = usuario['correo'] ?? '';
      _rolSeleccionado = usuario['rolRef'];
      _usuarioEditandoId = usuario['id'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Asignación de Roles')),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _correoCtrl,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            DropdownButtonFormField<DocumentReference>(
              value: _rolSeleccionado,
              items: _roles.map((rolData) {
                return DropdownMenuItem<DocumentReference>(
                  value: rolData['ref'],
                  child: Text(rolData['nombre'] ?? 'Sin nombre'),
                );
              }).toList(),
              onChanged: (nuevoRol) => setState(() => _rolSeleccionado = nuevoRol),
              decoration: const InputDecoration(labelText: 'Rol'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _guardarUsuario,
              child: Text(_usuarioEditandoId == null ? 'Agregar Usuario' : 'Actualizar Usuario'),
            ),
            const Divider(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: _usuarios.length,
                itemBuilder: (context, index) {
                  final u = _usuarios[index];
                  final rol = _roles.firstWhere((r) => r['ref'].path == u['rolRef']?.path, orElse: () => {'nombre': 'Sin rol'});

                  return ListTile(
                    title: Text(u['nombre']),
                    subtitle: Text('${u['correo']} — Rol: ${rol['nombre']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _editarUsuario(u),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarUsuario(u['id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
