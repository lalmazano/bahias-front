import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DialogReprogramar extends StatefulWidget {
  final String reservaId;
  final DateTime inicioAnt;
  final DateTime finAnt;

  const DialogReprogramar({
    super.key,
    required this.reservaId,
    required this.inicioAnt,
    required this.finAnt,
  });

  @override
  State<DialogReprogramar> createState() => _DialogReprogramarState();
}

class _DialogReprogramarState extends State<DialogReprogramar> {
  final _firestore = FirebaseFirestore.instance;
  late DateTime nuevoInicio;
  late DateTime nuevoFin;

  @override
  void initState() {
    super.initState();
    nuevoInicio = widget.inicioAnt;
    nuevoFin = widget.finAnt;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Reprogramar Reserva", style: TextStyle(color: Colors.greenAccent)),
      backgroundColor: const Color(0xFF111511),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: widget.inicioAnt,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(widget.inicioAnt),
                );
                if (pickedTime != null) {
                  setState(() {
                    nuevoInicio = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              }
            },
            child: const Text("Cambiar Inicio",
                style: TextStyle(color: Colors.greenAccent)),
          ),
          TextButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: widget.finAnt,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(widget.finAnt),
                );
                if (pickedTime != null) {
                  final newFin = DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  );
                  if (newFin.isBefore(nuevoInicio)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("La fecha de fin no puede ser menor a la de inicio"),
                      backgroundColor: Colors.redAccent,
                    ));
                    return;
                  }
                  setState(() => nuevoFin = newFin);
                }
              }
            },
            child:
                const Text("Cambiar Fin", style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.white70))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
          onPressed: () async {
            await _firestore.collection('Reservas').doc(widget.reservaId).update({
              'FechaInicioAnterior': Timestamp.fromDate(widget.inicioAnt),
              'FechaFinAnterior': Timestamp.fromDate(widget.finAnt),
              'FechaInicio': Timestamp.fromDate(nuevoInicio),
              'FechaFin': Timestamp.fromDate(nuevoFin),
              'Reprogramada': true,
              'FechaReprogramacion': Timestamp.now(),
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Reserva reprogramada correctamente"),
              backgroundColor: Colors.orangeAccent,
            ));
          },
          child: const Text("Guardar", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
