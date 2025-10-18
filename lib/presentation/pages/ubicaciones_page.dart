import 'package:flutter/material.dart';
import '../../data/models/ubicacion.dart';
import '../../services/ubicacion_service.dart';
import './widgets/app_drawer.dart';

class UbicacionesPage extends StatefulWidget {
  const UbicacionesPage({super.key});

  @override
  State<UbicacionesPage> createState() => _UbicacionesPageState();
}

class _UbicacionesPageState extends State<UbicacionesPage> {
  final UbicacionService _ubicacionService = UbicacionService();
  List<Ubicacion> ubicaciones = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUbicaciones();
  }

  Future<void> _loadUbicaciones() async {
    try {
      final data = await _ubicacionService.getAll();
      setState(() {
        ubicaciones = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAddEditDialog({Ubicacion? ubicacion}) {
    final nombreController = TextEditingController(text: ubicacion?.nombre ?? '');
    final detalleController = TextEditingController(text: ubicacion?.detalle ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ubicacion == null ? 'Agregar Ubicación' : 'Editar Ubicación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: detalleController,
                decoration: const InputDecoration(labelText: 'Detalle'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nuevaUbicacion = Ubicacion(
                  idUbicacion: ubicacion?.idUbicacion ?? 0,
                  nombre: nombreController.text.trim(),
                  detalle: detalleController.text.trim(),
                );

                try {
                  if (ubicacion == null) {
                    await _ubicacionService.addUbicacion(nuevaUbicacion);
                  } else {
                    await _ubicacionService.updateUbicacion(
                        ubicacion.idUbicacion, nuevaUbicacion);
                  }
                  Navigator.pop(context);
                  _loadUbicaciones();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: Text(ubicacion == null ? 'Guardar' : 'Actualizar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUbicacion(int id) async {
    try {
      await _ubicacionService.deleteUbicacion(id);
      _loadUbicaciones();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ubicaciones')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ubicaciones')),
      drawer: const AppDrawer(),
      body: ubicaciones.isEmpty
          ? const Center(child: Text('No hay ubicaciones registradas.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: ubicaciones.length,
              itemBuilder: (context, index) {
                final u = ubicaciones[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    title: Text(
                      u.nombre,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(u.detalle),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () => _showAddEditDialog(ubicacion: u),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteUbicacion(u.idUbicacion),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Agregar Ubicación',
      ),
    );
  }
}
