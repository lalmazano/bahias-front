import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class ReporteReservasPorDia extends StatelessWidget {
  final DateTimeRange? rango;
  final String? usuarioRef;

  const ReporteReservasPorDia({super.key, this.rango, this.usuarioRef});

  Future<Map<String, int>> _getDatos() async {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Reservas');

    //  Filtrar por rango de fechas
    if (rango != null) {
      query = query
          .where('FechaInicio', isGreaterThanOrEqualTo: rango!.start)
          .where('FechaInicio', isLessThanOrEqualTo: rango!.end);
    }

    //  Filtrar por usuario (si aplica)
    if (usuarioRef != null) {
      query = query.where('UsuarioRef', isEqualTo: usuarioRef);
    }

    final snapshot = await query.get();
    final Map<String, int> porDia = {};

    for (var doc in snapshot.docs) {
      final info = doc.data();
      final fecha = (info['FechaInicio'] ?? info['FechaFin']) as Timestamp?;
      if (fecha != null) {
        final dia = DateFormat('dd/MM').format(fecha.toDate());
        porDia[dia] = (porDia[dia] ?? 0) + 1;
      }
    }

    // Ordenar por fecha para visualización cronológica
    final ordenadas = Map.fromEntries(porDia.entries.toList()
      ..sort((a, b) {
        final da = DateFormat('dd/MM').parse(a.key);
        final db = DateFormat('dd/MM').parse(b.key);
        return da.compareTo(db);
      }));

    return ordenadas;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _getDatos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.tealAccent));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Card(
            color: Colors.black54,
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No hay datos para mostrar',
                  style: TextStyle(color: Colors.white70)),
            ),
          );
        }

        final data = snapshot.data!;
        final dias = data.keys.toList();
        final valores = data.values.toList();

        return Card(
          color: Colors.black45,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reservas por Día',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: true, drawHorizontalLine: true),
                      alignment: BarChartAlignment.spaceAround,
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: _leftTitleWidgets,
                          ),
                        ),
                        rightTitles:
                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles:
                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i >= 0 && i < dias.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    dias[i],
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 10),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(dias.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: valores[i].toDouble(),
                              width: 14,
                              color: Colors.tealAccent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔹 Etiquetas del eje Y (izquierda)
  static Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return Text(
      value.toInt().toString(),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 10,
      ),
    );
  }
}
