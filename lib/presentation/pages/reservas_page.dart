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
  final TextEditingController duracionController = TextEditingController();

  // Para almacenar la hora seleccionada
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _duracionHoras = 1; // Duración por defecto (1 hora)

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
              // Campo para seleccionar la hora de inicio
              ListTile(
                title: const Text('Hora de inicio'),
                subtitle: Text('${_selectedTime.format(context)}'),
                onTap: () {
                  _selectTime(context);
                },
              ),
              // Campo para seleccionar la duración de la reserva
              TextField(
                controller: duracionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración en horas (máximo 4)',
                ),
                onChanged: (value) {
                  if (int.tryParse(value) != null) {
                    setState(() {
                      _duracionHoras = int.parse(value);
                    });
                  }
                },
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
                // Validar los campos
                if (bahiaController.text.isNotEmpty &&
                    fechaController.text.isNotEmpty &&
                    horaController.text.isNotEmpty &&
                    _duracionHoras <= 4) {
                  // Agregar nueva reserva
                  setState(() {
                    reservas.add({
                      'bahia': bahiaController.text,
                      'fecha': fechaController.text,
                      'hora': _selectedTime.format(context),
                      'estado': 'Pendiente',
                    });
                  });

                  // Limpiar los campos del formulario
                  bahiaController.clear();
                  fechaController.clear();
                  horaController.clear();
                  duracionController.clear();
                } else if (_duracionHoras > 4) {
                  // Mostrar mensaje de error si la duración es mayor a 4 horas
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('La duración máxima es 4 horas')),
                  );
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

  // Método para seleccionar la hora de inicio
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
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
