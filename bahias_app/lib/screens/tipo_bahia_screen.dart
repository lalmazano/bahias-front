import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TipoBahiaScreen extends StatefulWidget {
  const TipoBahiaScreen({super.key});

  @override
  State<TipoBahiaScreen> createState() => _TipoBahiaScreenState();
}

class _TipoBahiaScreenState extends State<TipoBahiaScreen> {
  final _tipoRef = FirebaseFirestore.instance.collection('Tipo_Bahia');

  void _mostrarDialogoTipo({String? id, String? descripcionActual}) {
    final controller = TextEditingController(text: descripcionActual ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111511),
        title: Text(
          id == null ? "Nuevo Tipo de Bahía" : "Editar Tipo de Bahía",
          style: const TextStyle(color: Colors.greenAccent),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Descripción del tipo",
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
                await _tipoRef.add({'Descripcion': nuevaDesc});
              } else {
                await _tipoRef.doc(id).update({'Descripcion': nuevaDesc});
              }

              if (mounted) Navigator.pop(context);
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarTipo(String id) async {
    await _tipoRef.doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tipos de Bahía"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF0B0F0B),
      body: StreamBuilder<QuerySnapshot>(
        stream: _tipoRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar tipos de bahía", style: TextStyle(color: Colors.redAccent)),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No hay tipos de bahía registrados", style: TextStyle(color: Colors.white70)),
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
                        onPressed: () => _mostrarDialogoTipo(id: docId, descripcionActual: descripcion),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _eliminarTipo(docId),
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
        onPressed: () => _mostrarDialogoTipo(),
      ),
    );
  }
}
