import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/bay.dart';
import './widgets/app_drawer.dart';
import 'package:flutter/services.dart';

class BaysMenuPage extends StatefulWidget {
  const BaysMenuPage({super.key});

  @override
  _BaysMenuPageState createState() => _BaysMenuPageState();
}

class _BaysMenuPageState extends State<BaysMenuPage> {
  final List<Bay> bays = [
    Bay(id: 'B1', nombre: 'Bahía 1', estado: BayStatus.libre, puestos: 3),
    Bay(id: 'B2', nombre: 'Bahía 2', estado: BayStatus.ocupada, puestos: 2),
    Bay(id: 'B3', nombre: 'Bahía 3', estado: BayStatus.mantenimiento, puestos: 4),
    Bay(id: 'B4', nombre: 'Bahía 4', estado: BayStatus.libre, puestos: 1),
  ];

  Color color(BayStatus s) {
    switch (s) {
      case BayStatus.libre:
        return Colors.green;
      case BayStatus.ocupada:
        return Colors.pink;
      case BayStatus.mantenimiento:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Mostrar el diálogo para agregar una nueva bahía
  void _showAddBayDialog() {
    final TextEditingController puestosController = TextEditingController();
    BayStatus selectedStatus = BayStatus.libre; // Valor inicial del estado

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar nueva bahía'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // El nombre se autogenerará, no necesitamos un campo de texto para el nombre
              Text('Nombre de la bahía: Bahía ${bays.length + 1}'), // Asigna el nombre dinámico
              TextField(
                controller: puestosController,
                decoration: const InputDecoration(
                  labelText: 'Número de puestos',
                ),
                keyboardType: TextInputType.number, // Solo aceptar números
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Solo permite dígitos
                ],
              ),
              // Aquí actualizamos el estado
              DropdownButton<BayStatus>(
                value: selectedStatus,
                onChanged: (BayStatus? newValue) {
                  setState(() {
                    selectedStatus = newValue!; // Actualizar el estado de la bahía
                  });
                },
                items: BayStatus.values.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status.name),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validar que el campo de puestos no esté vacío
                if (puestosController.text.isNotEmpty) {
                  // Generar el ID de la nueva bahía basado en el número de bahías existentes
                  String newBayId = 'B${bays.length + 1}'; // Esto generará 'B5' si hay 4 bahías

                  // Crear nueva bahía
                  setState(() {
                    bays.add(
                      Bay(
                        id: newBayId, // Asignamos el ID generado
                        nombre: 'Bahía ${bays.length + 1}', // Nombre dinámico
                        estado: selectedStatus,
                        puestos: int.parse(puestosController.text),
                      ),
                    );
                  });
                }
                Navigator.of(context).pop(); // Cerrar el diálogo después de agregar
              },
              child: const Text('Agregar bahía'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bahías')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Si la pantalla es más pequeña, usamos un ListView
              return ListView.builder(
                itemCount: bays.length,
                itemBuilder: (context, index) {
                  final bay = bays[index];
                  return Card(
                    color: color(bay.estado),
                    child: InkWell(
                      onTap: () {
                        // Navegar a la página de detalles de la bahía usando el ID de la bahía
                        context.go('/bays/${bay.id}');
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16), // Ajuste en el padding para más espacio
                        child: Stack(
                          children: [
                            // Colocamos el contenido de la bahía (texto y detalles)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: color(bay.estado).withOpacity(0.15),
                                      child: Icon(
                                        Icons.directions_car,
                                        color: Colors.white,
                                        size: 28, // Aumento del tamaño del ícono
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        bay.nombre,
                                        style: const TextStyle(
                                          fontSize: 22, // Aumento del tamaño de la fuente
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white, // Asegura que el texto sea blanco
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: color(bay.estado).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: color(bay.estado)),
                                      ),
                                      child: Text(
                                        bay.estado.name,
                                        style: const TextStyle(
                                          fontSize: 16, // Aumento del tamaño de la fuente para el estado
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white, // Asegura que el texto sea blanco
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Puestos: ${bay.puestos}',
                                      style: const TextStyle(
                                        fontSize: 16, // Aumento del tamaño de la fuente para "Puestos"
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white, // Asegura que el texto sea blanco
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Colocamos el ícono en la parte superior derecha
                            Positioned(
                              top: 8, // Distancia desde la parte superior
                              right: 8, // Distancia desde la parte derecha
                              child: CircleAvatar(
                                backgroundColor: color(bay.estado).withOpacity(0.7), // Fondo oscuro para el ícono
                                child: Icon(
                                  Icons.local_parking, // Cambié el ícono a uno de estacionamiento
                                  color: Colors.white,
                                  size: 28, // Tamaño del ícono
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              // Si la pantalla es más grande, usamos un GridView
              return GridView.builder(
                itemCount: bays.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 columnas para pantallas grandes
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemBuilder: (context, index) {
                  final bay = bays[index];
                  return Card(
                    color: color(bay.estado),
                    child: InkWell(
                      onTap: () {
                        // Navegar a la página de detalles de la bahía usando el ID de la bahía
                        context.go('/bays/${bay.id}');
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
                                      backgroundColor: color(bay.estado).withOpacity(0.15),
                                      child: Icon(
                                        Icons.directions_car,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        bay.nombre,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: color(bay.estado).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(color: color(bay.estado)),
                                      ),
                                      child: Text(
                                        bay.estado.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      'Puestos: ${bay.puestos}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: color(bay.estado).withOpacity(0.7),
                                child: Icon(
                                  Icons.local_parking,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddBayDialog,
        child: const Icon(Icons.add),
        tooltip: 'Agregar nueva bahía',
      ),
    );
  }
}
