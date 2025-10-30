import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeSummaryPage extends StatelessWidget {
  const HomeSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final q = FirebaseFirestore.instance.collection('Bahias').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: q,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs.map((e) => e.data() as Map<String, dynamic>).toList();
        final total = docs.length;

        int libres = 0, ocupadas = 0, mantenimiento = 0;
        for (final d in docs) {
          final estado = (d['Reserva'] ?? 'Libre').toString().toLowerCase();
          if (estado.contains('manten')) {
            mantenimiento++;
          } else if (estado.contains('ocup')) {
            ocupadas++;
          } else {
            libres++;
          }
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final cross = w >= 1200 ? 4 : w >= 900 ? 3 : w >= 600 ? 2 : 1;

              return GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 2.5,
                ),
                children: [
                  _SummaryCard(
                    title: 'Bahías totales',
                    value: total.toString(),
                    color: const Color(0xFF1E88E5), // azul
                  ),
                  _SummaryCard(
                    title: 'Libres',
                    value: libres.toString(),
                    color: const Color(0xFF2ECC71), // verde
                  ),
                  _SummaryCard(
                    title: 'Ocupadas',
                    value: ocupadas.toString(),
                    color: const Color(0xFFFFC107), // amarillo
                  ),
                  _SummaryCard(
                    title: 'Mantenimiento',
                    value: mantenimiento.toString(),
                    color: const Color(0xFF26A69A), // teal/azulado
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  const _SummaryCard({required this.title, required this.value, required this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF111511),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.insights, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 6),
                  Text(value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
