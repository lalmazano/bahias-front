import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ReporteReprogramadas extends StatelessWidget {
  final DateTimeRange? rango;

  const ReporteReprogramadas({super.key, this.rango});

  Future<Map<String, int>> _getDatos() async {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Reservas');

    // 🔹 Filtrar por rango de fechas
    if (rango != null) {
      query = query
          .where('FechaInicio', isGreaterThanOrEqualTo: rango!.start)
          .where('FechaInicio', isLessThanOrEqualTo: rango!.end);
    }

    final snapshot = await query.get();
    int normales = 0;
    int reprogramadas = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();

      final bool esReprogramada = data['Reprogramada'] == true &&
          data['FechaReprogramacion'] != null;

      if (esReprogramada) {
        reprogramadas++;
      } else {
        normales++;
      }
    }

    return {
      'Reprogramadas': reprogramadas,
      'Normales': normales,
    };
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
                'No hay datos para mostrar',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final total = data.values.fold<int>(0, (a, b) => a + b);
        final items = data.entries.toList();

        return Card(
          color: const Color(0xFF1E1E1E),
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reservas Reprogramadas',
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
                          final color = e.key == 'Reprogramadas'
                              ? Colors.orangeAccent
                              : Colors.lightBlueAccent;

                          return PieChartSectionData(
                            value: e.value.toDouble(),
                            color: color,
                            radius: 80,
                            title: '${e.key}\n${e.value} ($porcentaje%)',
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            titlePositionPercentageOffset: 0.6,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: items.map((e) {
                    final color = e.key == 'Reprogramadas'
                        ? Colors.orangeAccent
                        : Colors.lightBlueAccent;
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
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Total: $total reservas\n'
                    '(${data['Reprogramadas']} reprogramadas, ${data['Normales']} normales)',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
