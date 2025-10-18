import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/bay.dart';
import '../../data/models/estado_bahia.dart';
import '../../data/models/ubicacion.dart';
import '../../services/bahia_service.dart';
import '../../services/estado_bahia_service.dart';
import '../../services/ubicacion_service.dart';
import './widgets/app_drawer.dart';
import 'package:flutter/services.dart';

class BaysMenuPage extends StatefulWidget {
  const BaysMenuPage({super.key});

  @override
  _BaysMenuPageState createState() => _BaysMenuPageState();
}

class _BaysMenuPageState extends State<BaysMenuPage> {
  final BahiaService _bahiaService = BahiaService();
  final EstadoBahiaService _estadoService = EstadoBahiaService();
  final UbicacionService _ubicacionService = UbicacionService();

  List<Bay> bays = [];
  Map<int, EstadoBahia> estados = {};
  Map<int, Ubicacion> ubicaciones = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetchedBays = await _bahiaService.getAll();
      final fetchedEstados = await _estadoService.getAll();
      final fetchedUbicaciones = await _ubicacionService.getAll();

      setState(() {
        bays = fetchedBays;
        estados = {for (var e in fetchedEstados) e.idEstado: e};
        ubicaciones = {for (var u in fetchedUbicaciones) u.idUbicacion: u};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color colorPorEstado(int idEstado) {
    switch (idEstado) {
      case 1:
        return Colors.green; // Disponible
      case 2:
        return Colors.pink; // Ocupada
      case 3:
        return Colors.orange; // Mantenimiento
      case 4:
        return Colors.grey; // Inactiva
      default:
        return Colors.blueGrey;
    }
  }

  // Mostrar diálogo para agregar nueva bahía
  void _showAddBayDialog() {
    final TextEditingController ubicacionController = TextEditingController();
    int selectedEstado = estados.keys.isNotEmpty ? estados.keys.first : 1;
    int selectedUbicacion = ubicaciones.keys.isNotEmpty ? ubicaciones.keys.first : 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar nueva Bahía'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedUbicacion,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                ),
                onChanged: (int? value) {
                  setState(() {
                    selectedUbicacion = value!;
                  });
                },
                items: ubicaciones.entries
                    .map((e) => DropdownMenuItem<int>(
                          value: e.key,
                          child: Text(e.value.nombre),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: selectedEstado,
                decoration: const InputDecoration(
                  labelText: 'Estado de Bahía',
                ),
                onChanged: (int? value) {
                  setState(() {
                    selectedEstado = value!;
                  });
                },
                items: estados.entries
                    .map((e) => DropdownMenuItem<int>(
                          value: e.key,
                          child: Text(e.value.nombre),
                        ))
                    .toList(),
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
                try {
                  final nuevaBahia = Bay(
                    idBahia: 0,
                    idUbicacion: selectedUbicacion,
                    idEstado: selectedEstado,
                    idReserva: null,
                    fechaCreacion: DateTime.now().toIso8601String(),
                  );

                  await _bahiaService.addBay(nuevaBahia);
                  Navigator.pop(context);
                  _loadData(); // refresca lista
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al agregar bahía: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
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
        appBar: AppBar(title: const Text('Bahías')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bahías')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (bays.isEmpty) {
              return const Center(child: Text('No hay bahías registradas.'));
            }

            final isSmallScreen = constraints.maxWidth < 600;

            return isSmallScreen
                ? ListView.builder(
                    itemCount: bays.length,
                    itemBuilder: (context, index) =>
                        _buildBayCard(context, bays[index]),
                  )
                : GridView.builder(
                    itemCount: bays.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemBuilder: (context, index) =>
                        _buildBayCard(context, bays[index]),
                  );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBayDialog,
        tooltip: 'Agregar Bahía',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBayCard(BuildContext context, Bay bay) {
    final estado = estados[bay.idEstado]?.nombre ?? 'Sin estado';
    final descripcion = estados[bay.idEstado]?.descripcion ?? '';
    final ubicacion = ubicaciones[bay.idUbicacion]?.nombre ?? 'Sin ubicación';
    final detalleUbicacion = ubicaciones[bay.idUbicacion]?.detalle ?? '';
    final color = colorPorEstado(bay.idEstado);

    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: InkWell(
        onTap: () {
          context.go('/bays/${bay.idBahia}');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: color.withOpacity(0.2),
                        child: const Icon(Icons.directions_car,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bahía ${bay.idBahia}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    estado,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    descripcion,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ubicación: $ubicacion',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    detalleUbicacion,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: color.withOpacity(0.6),
                  child: const Icon(Icons.local_parking,
                      color: Colors.white, size: 26),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
