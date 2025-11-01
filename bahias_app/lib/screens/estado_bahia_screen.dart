import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EstadoBahiaScreen extends StatefulWidget {
  const EstadoBahiaScreen({super.key});

  @override
  State<EstadoBahiaScreen> createState() => _EstadoBahiaScreenState();
}

class _EstadoBahiaScreenState extends State<EstadoBahiaScreen> {
  final _estadoRef = FirebaseFirestore.instance.collection('Tipo_Estado');

  void _mostrarDialogoEstado({String? id, String? descripcionActual}) {
    final controller = TextEditingController(text: descripcionActual ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111511),
        title: Text(
          id == null ? "Nuevo Estado" : "Editar Estado",
          style: const TextStyle(color: Colors.greenAccent),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Descripción del estado",
            labelStyle: TextStyle(color: Colors.white70),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.greenAccent),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: () async {
              final nuevaDesc = controller.text.trim();
              if (nuevaDesc.isEmpty) return;

              if (id == null) {
                await _estadoRef.add({'Descripcion': nuevaDesc});
              } else {
                await _estadoRef.doc(id).update({'Descripcion': nuevaDesc});
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
    await _estadoRef.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estado de Bahías"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF0B0F0B),
      body: StreamBuilder<QuerySnapshot>(
        stream: _estadoRef.snapshots(),
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
              final descripcion = data['Descripcion'] ?? 'Sin descripción';
              final docId = docs[i].id;

              return Card(
                color: const Color(0xFF111511),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(descripcion, style: const TextStyle(color: Colors.white)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                        onPressed: () => _mostrarDialogoEstado(id: docId, descripcionActual: descripcion),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _eliminarEstado(docId),
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
