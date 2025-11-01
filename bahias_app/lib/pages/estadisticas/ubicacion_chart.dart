import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class UbicacionChart extends StatelessWidget {
  final List<MapEntry<String, int>> data;
  const UbicacionChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (sum, e) => sum + e.value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 60.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Distribución de reservas por ubicación',
              style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
            const SizedBox(height: 24),
            AspectRatio(
              aspectRatio: 1.2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  borderData: FlBorderData(show: false),
                  sections: data.map((e) {
                    final pct = total > 0 ? (e.value / total) * 100 : 0;
                    final color = Colors.primaries[
                        data.indexOf(e) % Colors.primaries.length];
                    return PieChartSectionData(
                      value: e.value.toDouble(),
                      color: color,
                      radius: 85,
                      title: '${e.key}\n${pct.toStringAsFixed(1)}%',
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
