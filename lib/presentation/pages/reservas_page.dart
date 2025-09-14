import 'package:flutter/material.dart';
import './widgets/app_drawer.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  _ReservasPageState createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  // Lista de reservas simuladas
  List<Map<String, String>> reservas = [
    {
      'bahia': 'Bahía 1',
      'fecha': '2025-09-20',
      'hora': '10:00 AM',
      'estado': 'Confirmada',
    },
    {
      'bahia': 'Bahía 2',
      'fecha': '2025-09-21',
      'hora': '02:00 PM',
      'estado': 'Pendiente',
    },
  ];

  // Controladores para los campos del formulario
  final TextEditingController bahiaController = TextEditingController();
  final TextEditingController fechaController = TextEditingController();
  final TextEditingController horaController = TextEditingController();

  // Mostrar el formulario para agregar una nueva reserva
  void _showAddReservationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar nueva reserva'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo para seleccionar la bahía
              TextField(
                controller: bahiaController,
                decoration: const InputDecoration(
                  labelText: 'Bahía',
                ),
              ),
              // Campo para ingresar la fecha
              TextField(
                controller: fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha (YYYY-MM-DD)',
                ),
              ),
              // Campo para ingresar la hora
              TextField(
                controller: horaController,
                decoration: const InputDecoration(
                  labelText: 'Hora (HH:MM AM/PM)',
                ),
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
                if (bahiaController.text.isNotEmpty &&
                    fechaController.text.isNotEmpty &&
                    horaController.text.isNotEmpty) {
                  // Agregar nueva reserva
                  setState(() {
                    reservas.add({
                      'bahia': bahiaController.text,
                      'fecha': fechaController.text,
                      'hora': horaController.text,
                      'estado': 'Pendiente',
                    });
                  });

                  // Limpiar los campos del formulario
                  bahiaController.clear();
                  fechaController.clear();
                  horaController.clear();
                }
                Navigator.of(context).pop(); // Cerrar el diálogo después de agregar
              },
              child: const Text('Agregar reserva'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reservas')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Título de la página
            const Text(
              'Listado/gestión de reservas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Botón para agregar nueva reserva
            ElevatedButton.icon(
              onPressed: _showAddReservationDialog,
              icon: const Icon(Icons.add),
              label: const Text('Agregar nueva reserva'),
            ),
            const SizedBox(height: 20),
            // Listado de reservas
            Expanded(
              child: ListView.builder(
                itemCount: reservas.length,
                itemBuilder: (context, index) {
                  final reserva = reservas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('Bahía: ${reserva['bahia']}'),
                      subtitle: Text('Fecha: ${reserva['fecha']} - Hora: ${reserva['hora']}'),
                      trailing: Text(reserva['estado']!),
                      onTap: () {
                        // Aquí puedes agregar la funcionalidad para editar o eliminar reservas
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
