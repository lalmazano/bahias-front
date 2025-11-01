import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/services.dart';
import './reservas/widgets.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final _firestore = FirebaseFirestore.instance;
  final _service = ReservaService();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _service.ensureBaseData();
    _iniciarActualizador();
  }

  void _iniciarActualizador() {
    _service.actualizarEstadosAutomaticos();
    Future.delayed(const Duration(minutes: 1), _iniciarActualizador);
  }

  @override
  Widget build(BuildContext context) {
    final ref = _firestore
        .collection('Reservas')
        .orderBy('No_Reserva', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0B),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Reservas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.greenAccent),
            tooltip: 'Nueva reserva',
            onPressed: () => showDialog(
                              context: context,
                              builder: (context) => FormularioReserva(service: _service),
                            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: ref,
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Error al cargar Reservas'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text('No hay reservas registradas',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return ReservaCard(
                reservaId: docs[i].id,
                data: data,
                service: _service,
              );
            },
          );
        },
      ),
    );
  }
}
