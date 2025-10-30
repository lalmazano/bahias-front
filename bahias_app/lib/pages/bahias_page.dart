import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BahiasPage extends StatelessWidget {
  const BahiasPage({super.key});

  Color _estadoColor(String estado) {
    final e = estado.toLowerCase();
    if (e.contains('ocup')) return const Color(0xFFFFC107); // amarillo
    if (e.contains('manten')) return const Color(0xFF42A5F5); // azul
    return const Color(0xFF2ECC71); // verde (libre)
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseFirestore.instance
        .collection('Bahias')
        .orderBy('No_Bahia')
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: ref,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Error al cargar Bahías'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final cross = w >= 1400 ? 5 : w >= 1200 ? 4 : w >= 900 ? 3 : w >= 600 ? 2 : 1;

              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.25,
                ),
                itemCount: docs.length,
                itemBuilder: (_, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final no = data['No_Bahia'] ?? '-';
                  final nombre = data['Nombre'] ?? 'Sin nombre';
                  final reserva = (data['Reserva'] ?? 'Libre').toString();
                  final color = _estadoColor(reserva);

                  return Card(
                    color: const Color(0xFF111511),
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: InkWell(
                      onTap: () {
                        // aquí puedes abrir detalles / reservar / etc.
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Bahía $no',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightBlueAccent)),
                            const SizedBox(height: 8),
                            Text(
                              nombre,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: Colors.white70),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: color.withOpacity(0.45)),
                              ),
                              child: Text(
                                reserva,
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
