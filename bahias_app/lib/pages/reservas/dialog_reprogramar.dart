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
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        "Reprogramar Reserva",
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fecha y hora de inicio
          TextButton.icon(
            icon: Icon(Icons.access_time, color: theme.colorScheme.primary),
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
            label: Text(
              "Cambiar inicio (${nuevoInicio.toString().substring(0, 16)})",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),

          // Fecha y hora de fin
          TextButton.icon(
            icon: Icon(Icons.timelapse, color: theme.colorScheme.primary),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "La fecha de fin no puede ser menor a la de inicio",
                        ),
                        backgroundColor: theme.colorScheme.error,
                      ),
                    );
                    return;
                  }
                  setState(() => nuevoFin = newFin);
                }
              }
            },
            label: Text(
              "Cambiar fin (${nuevoFin.toString().substring(0, 16)})",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),

          const SizedBox(height: 10),
          Divider(color: theme.dividerColor.withOpacity(0.4)),
          const SizedBox(height: 6),

          Text(
            "Inicio anterior: ${widget.inicioAnt.toString().substring(0, 16)}",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          Text(
            "Fin anterior: ${widget.finAnt.toString().substring(0, 16)}",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancelar",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.save),
          label: const Text("Guardar"),
          onPressed: () async {
            await _firestore.collection('Reservas').doc(widget.reservaId).update({
              'FechaInicioAnterior': Timestamp.fromDate(widget.inicioAnt),
              'FechaFinAnterior': Timestamp.fromDate(widget.finAnt),
              'FechaInicio': Timestamp.fromDate(nuevoInicio),
              'FechaFin': Timestamp.fromDate(nuevoFin),
              'Reprogramada': true,
              'FechaReprogramacion': Timestamp.now(),
            });

            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Reserva reprogramada correctamente"),
                  backgroundColor: Colors.orangeAccent,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
