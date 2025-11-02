import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/services.dart';

class EstadoBahiaScreen extends StatefulWidget {
  const EstadoBahiaScreen({super.key});

  @override
  State<EstadoBahiaScreen> createState() => _EstadoBahiaScreenState();
}

class _EstadoBahiaScreenState extends State<EstadoBahiaScreen> {
  final EstadoBahiaService _service = EstadoBahiaService();

  void _mostrarDialogoEstado({String? id, String? nombreActual, String? descripcionActual}) {
    final nombreCtrl = TextEditingController(text: nombreActual ?? '');
    final descCtrl = TextEditingController(text: descripcionActual ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111511),
        title: Text(
          id == null ? "Nuevo Estado" : "Editar Estado",
          style: const TextStyle(color: Colors.greenAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nombre del estado",
                labelStyle: TextStyle(color: Colors.white70),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent),
                ),
              ),
            ),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Descripción del estado",
                labelStyle: TextStyle(color: Colors.white70),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.greenAccent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (nombre.isEmpty || desc.isEmpty) return;

              if (id == null) {
                await _service.agregarEstado(nombre, desc);
              } else {
                await _service.editarEstado(id, nombre, desc);
              }

              if (mounted) Navigator.pop(context);
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarEstado(String id) async {
    await _service.eliminarEstado(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estados de Bahías"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF0B0F0B),
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.obtenerEstados(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar estados", style: TextStyle(color: Colors.redAccent)),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No hay estados registrados", style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;
              final nombre = data['nombre'] ?? 'Sin nombre';
              final descripcion = data['Descripcion'] ?? 'Sin descripción';

              return Card(
                color: const Color(0xFF111511),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    nombre,
                    style: const TextStyle(
                        color: Colors.greenAccent, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "ID: $id\nDescripción: $descripcion",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                        onPressed: () => _mostrarDialogoEstado(
                          id: id,
                          nombreActual: nombre,
                          descripcionActual: descripcion,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _eliminarEstado(id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _mostrarDialogoEstado(),
      ),
    );
  }
}
