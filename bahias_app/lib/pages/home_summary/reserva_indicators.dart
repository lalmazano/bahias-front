import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart';

class ReservaIndicators extends StatelessWidget {
  const ReservaIndicators({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Reservas').snapshots(),
      builder: (context, resSnap) {
        if (resSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!resSnap.hasData || resSnap.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'No hay reservas registradas.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final reservas = resSnap.data!.docs
            .map((e) => e.data() as Map<String, dynamic>)
            .toList();

        //  Tiempo promedio de ocupación
        final duraciones = reservas.map((r) {
          final inicio = (r['FechaInicio'] as Timestamp).toDate();
          final fin = (r['FechaFin'] as Timestamp).toDate();
          return fin.difference(inicio).inMinutes;
        }).toList();

        final promedio = duraciones.isEmpty
            ? 0
            : duraciones.reduce((a, b) => a + b) / duraciones.length;

        //  Próximas a liberarse (10 min)
        final proximas = reservas.where((r) {
          final fin = (r['FechaFin'] as Timestamp).toDate();
          return fin.isAfter(DateTime.now()) &&
              fin.isBefore(DateTime.now().add(const Duration(minutes: 10)));
        }).length;

        //  Activas hoy
        final hoy = DateTime.now();
        final activasHoy = reservas.where((r) {
          final inicio = (r['FechaInicio'] as Timestamp).toDate();
          final fin = (r['FechaFin'] as Timestamp).toDate();
          return hoy.isAfter(inicio) && hoy.isBefore(fin);
        }).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 12, left: 8),
              child: Text(
                'Indicadores de Reservas',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                StatusCard(
                  title: 'Tiempo promedio de ocupación',
                  value: '${promedio.toStringAsFixed(1)} min',
                  subtitle: 'Duración media por bahía',
                  color: Colors.tealAccent.shade700,
                  icon: Icons.schedule,
                ),
                StatusCard(
                  title: 'Bahías próximas a liberarse',
                  value: proximas.toString(),
                  subtitle: 'Finalizan en menos de 10 min',
                  color: Colors.deepOrangeAccent,
                  icon: Icons.access_time,
                ),
                StatusCard(
                  title: 'Reservas activas hoy',
                  value: activasHoy.toString(),
                  subtitle: 'Reservas vigentes durante el día',
                  color: Colors.indigoAccent,
                  icon: Icons.today_outlined,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
