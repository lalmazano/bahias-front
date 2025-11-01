import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/services.dart';
import 'widgets.dart';

class ReservaCard extends StatelessWidget {
  final String reservaId;
  final Map<String, dynamic> data;
  final ReservaService service;

  const ReservaCard({
    super.key,
    required this.reservaId,
    required this.data,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    final no = data['No_Reserva'] ?? 0;
    final usuario = data['UsuarioRef'] as DocumentReference?;
    final inicio = (data['FechaInicio'] as Timestamp).toDate();
    final fin = (data['FechaFin'] as Timestamp).toDate();
    final estadoReservaRef = data['EstadoReservaRef'] as DocumentReference?;
    final bahiasRefs = (data['BahiasRefs'] as List?)?.cast<DocumentReference>() ?? [];
    final reprogramada = data['Reprogramada'] ?? false;

    return FutureBuilder(
      future: Future.wait([
        usuario?.get() ?? firestore.collection('Usuarios').doc('demoUser').get(),
        estadoReservaRef?.get() ?? firestore.collection('Estado_Reserva').doc('Creada').get(),
        Future.wait(bahiasRefs.map((b) => b.get())),
      ]),
      builder: (context, snap2) {
        if (!snap2.hasData) return const LinearProgressIndicator();

        final usuarioDoc = snap2.data![0] as DocumentSnapshot<Map<String, dynamic>>;
        final estadoReservaDoc = snap2.data![1] as DocumentSnapshot<Map<String, dynamic>>;
        final bahiasDocs =
            (snap2.data![2] as List).cast<DocumentSnapshot<Map<String, dynamic>>>();

        final usuarioNombre = usuarioDoc.data()?['nombre'] ?? 'Sin usuario';
        final estadoReserva = estadoReservaDoc.id;
        final color = service.estadoColor(estadoReserva);
        final bahiasNombres = bahiasDocs.map((b) => b.id).join(', ');

        // Validaciones de estado
        final isCancelada = estadoReserva.toLowerCase().contains('cancel');
        final isFinalizada = estadoReserva.toLowerCase().contains('finaliz');
        final isBloqueada = isCancelada || isFinalizada || reprogramada;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Card(
            color: const Color(0xFF111511),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.25),
                    child: Icon(Icons.event, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reserva $no',
                            style: const TextStyle(
                                color: Colors.lightBlueAccent,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Usuario: $usuarioNombre",
                            style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        Text("Bahías: $bahiasNombres",
                            style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        Text("Inicio: ${inicio.toString().substring(0, 16)}",
                            style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        Text("Fin: ${fin.toString().substring(0, 16)}",
                            style: const TextStyle(color: Colors.white60, fontSize: 12)),
                        Text("Estado: $estadoReserva",
                            style: TextStyle(color: color, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      // Botón de reprogramar
                      IconButton(
                        icon: Icon(
                          Icons.edit_calendar,
                          color: isBloqueada
                              ? Colors.grey
                              : Colors.orangeAccent,
                          size: 22,
                        ),
                        tooltip: isBloqueada
                            ? (isCancelada || isFinalizada
                                ? 'No se puede reprogramar una reserva cancelada o finalizada'
                                : 'Ya fue reprogramada')
                            : 'Reprogramar',
                        onPressed: isBloqueada
                            ? () {
                                // 🔒 Mostrar aviso si intenta reprogramar bloqueada
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    isCancelada || isFinalizada
                                        ? "No se puede reprogramar una reserva cancelada o finalizada"
                                        : "La reserva ya fue reprogramada una vez",
                                  ),
                                  backgroundColor: isCancelada || isFinalizada
                                      ? Colors.redAccent
                                      : Colors.orangeAccent,
                                ));
                              }
                            : () => showDialog(
                                  context: context,
                                  builder: (_) => DialogReprogramar(
                                    reservaId: reservaId,
                                    inicioAnt: inicio,
                                    finAnt: fin,
                                  ),
                                ),
                      ),

                      // Botón de cancelar
                      IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: isCancelada ? Colors.grey : Colors.redAccent,
                          size: 22,
                        ),
                        tooltip:
                            isCancelada ? 'Reserva ya cancelada' : 'Cancelar',
                        onPressed: isCancelada
                            ? null
                            : () => service.cancelarReserva(
                                  reservaId,
                                  bahiasRefs,
                                  context,
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
