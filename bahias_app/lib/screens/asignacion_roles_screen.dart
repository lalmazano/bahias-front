import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AsignacionRolesScreen extends StatefulWidget {
  const AsignacionRolesScreen({super.key});

  @override
  State<AsignacionRolesScreen> createState() => _AsignacionRolesScreenState();
}

class _AsignacionRolesScreenState extends State<AsignacionRolesScreen> {
  final _db = FirebaseFirestore.instance;
  String? _selectedUserId;
  String? _selectedRolPath;

  Future<List<DocumentSnapshot>> _getUsuarios() async {
    final snapshot = await _db.collection('Usuarios').get();
    return snapshot.docs;
  }

  Future<List<DocumentSnapshot>> _getRoles() async {
    final snapshot = await _db.collection('Roles').get();
    return snapshot.docs;
  }

  Future<void> _asignarRol() async {
    if (_selectedUserId == null || _selectedRolPath == null) return;

    final userDoc = await _db.collection('Usuarios').doc(_selectedUserId).get();
    final currentRolRef = userDoc.data()?['rolRef'];

    // Evitar reasignar el mismo rol
    if (currentRolRef != null && currentRolRef.path == _selectedRolPath) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El usuario ya tiene este rol asignado')),
      );
      return;
    }

    await _db.collection('Usuarios').doc(_selectedUserId).update({
      'rolRef': _db.doc(_selectedRolPath!), // referencia al rol
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rol asignado correctamente')),
    );

    setState(() {
      _selectedUserId = null;
      _selectedRolPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: Future.wait([_getUsuarios(), _getRoles()]),
          builder: (context, AsyncSnapshot<List<List<DocumentSnapshot>>> snapshot) {
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Colors.greenAccent),
              );
            }

            final usuarios = snapshot.data![0];
            final roles = snapshot.data![1];

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selecciona un usuario:",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedUserId,
                    hint: const Text('Usuario'),
                    items: usuarios.map((doc) {
                      final data = doc.data() as Map<String, dynamic>? ?? {};
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              "${data['nombre'] ?? 'Sin nombre'} - ${data['correo'] ?? 'Sin correo'}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedUserId = value),
                    dropdownColor: const Color(0xFF111511),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Selecciona un rol:",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedRolPath,
                    hint: const Text('Rol'),
                    items: roles.map((doc) {
                      final data = doc.data() as Map<String, dynamic>? ?? {};
                      return DropdownMenuItem<String>(
                        value: doc.reference.path,
                        child: Row(
                          children: [
                            const Icon(Icons.security_outlined, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              data['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedRolPath = value),
                    dropdownColor: const Color(0xFF111511),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _asignarRol,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('Asignar Rol'),
                  ),
                ],
              ),
            );
          },
        ),
        const Divider(color: Colors.greenAccent),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _db.collection('Usuarios').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                    child: CircularProgressIndicator(color: Colors.greenAccent));
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  final docRef = data['rolRef'];
                  final DocumentReference? rolRef =
                      docRef is DocumentReference ? docRef : null;

                  return FutureBuilder<DocumentSnapshot>(
                    future: rolRef?.get(),
                    builder: (context, rolSnapshot) {
                      String rolNombre = 'Sin rol';

                      if (rolSnapshot.hasData) {
                        final rawData = rolSnapshot.data?.data();
                        if (rawData != null && rawData is Map<String, dynamic>) {
                          rolNombre = rawData['nombre'] ?? 'Sin rol';
                        }
                      }

                      return Card(
                        color: const Color(0xFF111511),
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.person, color: Colors.white70),
                          title: Text(
                            data['nombre'] ?? 'Sin nombre',
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            '${data['correo'] ?? 'Sin correo'}\nRol: $rolNombre',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () =>
                                _db.collection('Usuarios').doc(doc.id).delete(),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
