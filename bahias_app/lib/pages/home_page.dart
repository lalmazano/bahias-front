import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Bahias')
          .orderBy('No_Bahia')
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(child: Text('Error cargando Bahías'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('No hay Bahías registradas'));
        }

        // grid de tarjetitas
        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // ajusta a 2/4 según pantalla
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.3,
          ),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            final estado = (data['Reserva'] ?? 'Libre').toString();
            final color = estado.toLowerCase() == 'ocupada'
                ? Colors.redAccent
                : Colors.greenAccent;

            return Card(
              color: const Color(0xFF111511),
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Bahía ${data['No_Bahia'] ?? '-'}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightBlueAccent)),
                    const SizedBox(height: 8),
                    Text(
                      data['Nombre'] ?? 'Sin nombre',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Chip(
                      label: Text('Reserva: $estado',
                          style: const TextStyle(color: Colors.black)),
                      backgroundColor: color,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
