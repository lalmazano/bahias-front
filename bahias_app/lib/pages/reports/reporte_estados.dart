import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ReporteEstados extends StatelessWidget {
  final DateTimeRange? rango;
  final String? usuarioRef;
  final Function(Map<String, int>)? onDataReady;

  const ReporteEstados({
    super.key,
    this.rango,
    this.usuarioRef,
    this.onDataReady,
  });

  ///  Detecta color según el texto del estado (palabras clave flexibles)
  Color _colorPorEstado(String estado) {
    final lower = estado.toLowerCase();

    if (lower.contains('crea')) return Colors.blueAccent;
    if (lower.contains('en uso') || lower.contains('uso')) return Colors.greenAccent;
    if (lower.contains('final')) return Colors.purpleAccent;
    if (lower.contains('cance')) return Colors.redAccent;
    if (lower.contains('reprog')) return Colors.orangeAccent;
    if (lower.contains('pend')) return Colors.amberAccent;

    return Colors.tealAccent; // Por defecto
  }

  Future<Map<String, int>> _getDatos() async {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Reservas');

    // 🔹 Filtros
    if (rango != null) {
      query = query
          .where('FechaInicio', isGreaterThanOrEqualTo: rango!.start)
          .where('FechaInicio', isLessThanOrEqualTo: rango!.end);
    }
    if (usuarioRef != null) {
      query = query.where('UsuarioRef', isEqualTo: usuarioRef);
    }

    final snapshot = await query.get();
    final Map<String, int> estados = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      dynamic estado = data['EstadoReservaRef'] ?? data['EstadoRef'];

      // Si es referencia, obtener su nombre o descripción
      if (estado is DocumentReference) {
        final refData = await estado.get();
        final refMap = refData.data() as Map<String, dynamic>?;
        estado = refMap?['Descripcion'] ??
            refMap?['nombre'] ??
            refData.id ??
            'Desconocido';
      } else if (estado is String) {
        estado = estado.split('/').last;
      } else {
        estado = 'Desconocido';
      }

      estados[estado] = (estados[estado] ?? 0) + 1;
    }

    onDataReady?.call(estados);
    return estados;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _getDatos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.tealAccent),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            color: Colors.black54,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No hay datos disponibles',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final items = data.entries.toList();
        final total = items.fold<int>(0, (sum, e) => sum + e.value);

        return Card(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reservas por Estado',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: SizedBox(
                    height: 250,
                    width: 250,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 60,
                        borderData: FlBorderData(show: false),
                        sections: items.map((e) {
                          final porcentaje = total > 0
                              ? (e.value / total * 100).toStringAsFixed(1)
                              : '0';
                          final color = _colorPorEstado(e.key);

                          return PieChartSectionData(
                            color: color,
                            value: e.value.toDouble(),
                            title: '${e.key}\n${e.value} (${porcentaje}%)',
                            radius: 85,
                            titleStyle: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            titlePositionPercentageOffset: 0.65,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔹 Leyenda con color + texto
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: items.map((e) {
                    final color = _colorPorEstado(e.key);
                    final porcentaje = total > 0
                        ? (e.value / total * 100).toStringAsFixed(1)
                        : '0';
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${e.key} - ${e.value} (${porcentaje}%)',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
