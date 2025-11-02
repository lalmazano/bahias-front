import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/services.dart';

class UbicacionesScreen extends StatelessWidget {
  const UbicacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = UbicacionesService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicaciones'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF0B0F0B),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.greenAccent,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Nueva', style: TextStyle(color: Colors.black)),
        onPressed: () => _mostrarDialogoUbicacion(context, service),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.streamUbicaciones(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error al cargar ubicaciones',
                  style: TextStyle(color: Colors.redAccent)),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text('No hay ubicaciones registradas',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data();
              final id = docs[i].id;
              final nombre = data['Nombre'] ?? 'Sin nombre';
              final descripcion = data['Descripcion'] ?? 'Sin descripción';

              return Card(
                color: const Color(0xFF111511),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.place, color: Colors.greenAccent),
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
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        icon: const Icon(Icons.edit, color: Colors.orangeAccent),
                        onPressed: () => _editarUbicacion(
                          context,
                          service,
                          id,
                          nombre,
                          descripcion,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Eliminar',
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent),
                        onPressed: () async {
                          final ok = await _confirmDelete(context, id);
                          if (ok == true) await service.delete(id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// 🆕 Crear ubicación (auto genera ID)
  Future<void> _mostrarDialogoUbicacion(
      BuildContext context, UbicacionesService service) async {
    final nombreCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111511),
        title: const Text("Nueva Ubicación",
            style: TextStyle(color: Colors.greenAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nombre de la ubicación",
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
                labelText: "Descripción de la ubicación",
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
            child: const Text("Cancelar",
                style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: () async {
              final nombre = nombreCtrl.text.trim();
              final desc = descCtrl.text.trim();
              if (nombre.isEmpty || desc.isEmpty) return;

              await service.create(nombre: nombre, descripcion: desc);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Guardar", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  /// ✏️ Editar nombre y descripción
  Future<void> _editarUbicacion(
    BuildContext context,
    UbicacionesService service,
    String id,
    String nombre,
    String descripcion,
  ) async {
    final nombreCtrl = TextEditingController(text: nombre);
    final descCtrl = TextEditingController(text: descripcion);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111511),
        title: Text("Editar $id",
            style: const TextStyle(color: Colors.greenAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Nuevo nombre",
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
                labelText: "Nueva descripción",
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
            child:
                const Text("Cancelar", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            onPressed: () async {
              final nuevoNombre = nombreCtrl.text.trim();
              final nuevaDesc = descCtrl.text.trim();
              if (nuevoNombre.isEmpty || nuevaDesc.isEmpty) return;

              await service.update(
                id: id,
                nombre: nuevoNombre,
                descripcion: nuevaDesc,
              );
              if (context.mounted) Navigator.pop(context);
            },
            child:
                const Text("Guardar cambios", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  /// ⚠️ Confirmación antes de eliminar
  Future<bool?> _confirmDelete(BuildContext context, String id) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111511),
        title: const Text('Eliminar ubicación',
            style: TextStyle(color: Colors.white)),
        content: Text('¿Eliminar "$id"? Esta acción no se puede deshacer.',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
