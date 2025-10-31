import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key}); // 👈 agrega este constructor
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

    await _db.collection('Roles').doc(id).set({'nombre': nombre, 'permisos': permisos});
    _idCtrl.clear();
    _nameCtrl.clear();
    _permCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gestión de Roles')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(controller: _idCtrl, decoration: InputDecoration(labelText: 'ID del Rol')),
                TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Nombre')),
                TextField(controller: _permCtrl, decoration: InputDecoration(labelText: 'Permisos (coma separada)')),
                ElevatedButton(onPressed: _addRole, child: Text('Agregar Rol')),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _db.collection('Roles').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                return ListView(
                  children: docs
                      .map((doc) => ListTile(
                            title: Text(doc['nombre']),
                            subtitle: Text(doc['permisos'].join(', ')),
                            trailing: Text(doc.id),
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
