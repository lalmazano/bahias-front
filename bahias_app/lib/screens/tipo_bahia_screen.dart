import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TipoBahiaScreen extends StatelessWidget {
  const TipoBahiaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tipoRef = FirebaseFirestore.instance.collection('Tipo_Bahia');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tipos de Bahía"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF0B0F0B),
      body: StreamBuilder<QuerySnapshot>(
        stream: tipoRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error al cargar tipos de bahía",
                  style: TextStyle(color: Colors.redAccent)),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("No hay tipos de bahía registrados",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final descripcion = data['Descripcion'] ?? 'Sin descripción';

              return Card(
                color: const Color(0xFF111511),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(descripcion,
                      style: const TextStyle(color: Colors.white)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () async {
                      await tipoRef.doc(docs[i].id).delete();
                    },
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
        onPressed: () {
          _mostrarDialogoAgregar(context, tipoRef);
        },
      ),
    );
  }

  void _mostrarDialogoAgregar(
      BuildContext context, CollectionReference ref) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111511),
        title: const Text("Nuevo Tipo de Bahía",
            style: TextStyle(color: Colors.greenAccent)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Descripción del tipo",
            labelStyle: TextStyle(color: Colors.white70),
            focusedBorder:
                UnderlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar",
                style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await ref.add({'Descripcion': controller.text.trim()});
                Navigator.pop(context);
              }
            },
            child: const Text("Guardar",
                style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
