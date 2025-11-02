import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/services.dart';

class UbicacionesScreen extends StatelessWidget {
  const UbicacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = UbicacionesService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicaciones'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
        onPressed: () => _mostrarDialogoUbicacion(context, service),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: service.streamUbicaciones(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar ubicaciones',
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
                'No hay ubicaciones registradas',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
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
                color: theme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(Icons.place, color: theme.colorScheme.primary),
                  title: Text(
                    nombre,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "ID: $id\nDescripción: $descripcion",
                    style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        tooltip: 'Editar',
                        icon: Icon(Icons.edit, color: theme.colorScheme.secondary),
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
                        icon: Icon(Icons.delete_outline,
                            color: theme.colorScheme.errorContainer),
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
    final theme = Theme.of(context);
    final nombreCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          "Nueva Ubicación",
          style: TextStyle(color: theme.colorScheme.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Nombre de la ubicación",
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
            TextField(
              controller: descCtrl,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Descripción de la ubicación",
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
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

              await service.create(nombre: nombre, descripcion: desc);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Guardar"),
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
    final theme = Theme.of(context);
    final nombreCtrl = TextEditingController(text: nombre);
    final descCtrl = TextEditingController(text: descripcion);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          "Editar $id",
          style: TextStyle(color: theme.colorScheme.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Nuevo nombre",
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
            TextField(
              controller: descCtrl,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: "Nueva descripción",
                labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
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
            child: const Text("Guardar cambios"),
          ),
        ],
      ),
    );
  }

  /// ⚠️ Confirmación antes de eliminar
  Future<bool?> _confirmDelete(BuildContext context, String id) async {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text('Eliminar ubicación',
            style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text(
          '¿Eliminar "$id"? Esta acción no se puede deshacer.',
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
