import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class ReporteReservasPorUsuario extends StatelessWidget {
  final DateTimeRange? rango;

  const ReporteReservasPorUsuario({super.key, this.rango});

  Future<Map<String, int>> _getDatos() async {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('Reservas');

    // Filtrar por rango de fechas
    if (rango != null) {
      query = query
          .where('FechaInicio', isGreaterThanOrEqualTo: rango!.start)
          .where('FechaInicio', isLessThanOrEqualTo: rango!.end);
    }

    final snapshot = await query.get();
    final Map<String, int> porUsuario = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      dynamic usuario = data['UsuarioRef'];

      // 🔍 Si el usuario es una referencia, obtener su nombre
      if (usuario is DocumentReference) {
        final ref = await usuario.get();
        final refData = ref.data() as Map<String, dynamic>?;
        usuario = refData?['nombre'] ?? ref.id;
      } else if (usuario is String) {
        usuario = usuario.split('/').last;
      } else {
        usuario = 'Sin nombre';
      }

      porUsuario[usuario] = (porUsuario[usuario] ?? 0) + 1;
    }

    // 🔹 Ordenar de mayor a menor cantidad
    final ordenado = Map.fromEntries(
      porUsuario.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    return ordenado;
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
        final usuarios = data.keys.toList();
        final valores = data.values.toList();

        return Card(
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reservas por Usuario',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                //  Gráfico de barras
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      gridData: FlGridData(show: true, drawHorizontalLine: true),
                      alignment: BarChartAlignment.spaceAround,
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
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
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i >= 0 && i < usuarios.length) {
                                final nombre = usuarios[i].length > 10
                                    ? '${usuarios[i].substring(0, 10)}...'
                                    : usuarios[i];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    nombre,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(usuarios.length, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: valores[i].toDouble(),
                              width: 16,
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                //  Leyenda inferior
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: usuarios.asMap().entries.map((entry) {
                    final i = entry.key;
                    final nombre = entry.value;
                    final cantidad = valores[i];
                    return Text(
                      '$nombre: $cantidad',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
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

  //  Etiquetas eje Y
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
