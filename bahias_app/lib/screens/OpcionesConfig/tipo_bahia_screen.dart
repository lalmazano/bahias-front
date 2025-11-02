import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/services.dart';

class TipoBahiaScreen extends StatefulWidget {
  const TipoBahiaScreen({super.key});

  @override
  State<TipoBahiaScreen> createState() => _TipoBahiaScreenState();
}

class _TipoBahiaScreenState extends State<TipoBahiaScreen> {
  final TipoBahiaService _service = TipoBahiaService();

  void _mostrarDialogoTipo({
    String? id,
    String? nombreActual,
    String? descripcionActual,
  }) {
    final theme = Theme.of(context);
    final nombreCtrl = TextEditingController(text: nombreActual ?? '');
    final descCtrl = TextEditingController(text: descripcionActual ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          id == null ? "Nuevo Tipo de Bahía" : "Editar Tipo de Bahía",
          style: TextStyle(color: theme.colorScheme.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Nombre del tipo",
                labelStyle:
                    TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
            TextField(
              controller: descCtrl,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Descripción del tipo",
                labelStyle:
                    TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar",
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (nombre.isEmpty || desc.isEmpty) return;

              if (id == null) {
                await _service.agregarTipo(nombre, desc);
              } else {
                await _service.editarTipo(id, nombre, desc);
              }

              if (mounted) Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarTipo(String id) async {
    await _service.eliminarTipo(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tipos de Bahía"),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: _service.obtenerTipos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error al cargar tipos de bahía",
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                "No hay tipos de bahía registrados",
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
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
                color: theme.cardColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(
                    nombre,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "ID: $id\nDescripción: $descripcion",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            Icon(Icons.edit, color: theme.colorScheme.secondary),
                        onPressed: () => _mostrarDialogoTipo(
                          id: id,
                          nombreActual: nombre,
                          descripcionActual: descripcion,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: theme.colorScheme.errorContainer),
                        onPressed: () => _eliminarTipo(id),
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
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        onPressed: () => _mostrarDialogoTipo(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
