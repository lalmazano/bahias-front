import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/services.dart';
import './reservas/widgets.dart';
import './reservas/formulario_reserva.dart';

class ReservasPage extends StatefulWidget {
  const ReservasPage({super.key});

  @override
  State<ReservasPage> createState() => _ReservasPageState();
}

class _ReservasPageState extends State<ReservasPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
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
    final currentUser = _auth.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('Usuarios').doc(currentUser!.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B0F0B),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final rolRef = userData?['rolRef'] as DocumentReference?;

        if (rolRef == null) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B0F0B),
            body: Center(
              child: Text(
                'El usuario no tiene un rol asignado.',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          );
        }

        return FutureBuilder<DocumentSnapshot>(
          future: rolRef.get(),
          builder: (context, rolSnap) {
            if (!rolSnap.hasData) {
              return const Scaffold(
                backgroundColor: Color(0xFF0B0F0B),
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final rolData = rolSnap.data!.data() as Map<String, dynamic>?;
            final rolNombre = rolData?['nombre']?.toString().toLowerCase() ?? 'cliente';

            // 🔹 Si es admin u operador, puede ver todo
            final puedeVerTodo = rolNombre == 'administrador' || rolNombre == 'operador';

            // 🔍 Construir consulta
            Query reservasQuery = _firestore
                .collection('Reservas')
                .orderBy('No_Reserva', descending: true);

            if (!puedeVerTodo) {
              reservasQuery = reservasQuery.where(
                'UsuarioRef',
                isEqualTo: _firestore.collection('Usuarios').doc(currentUser.uid),
              );
            }

            final ref = reservasQuery.snapshots();

            return Scaffold(
              backgroundColor: const Color(0xFF0B0F0B),
              appBar: AppBar(
                backgroundColor: Colors.black,
                title: Text(
                  "Reservas (${rolNombre[0].toUpperCase()}${rolNombre.substring(1)})",
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.greenAccent),
                    tooltip: 'Nueva reserva',
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => FormularioReserva(
                        service: _service,
                        puedeAsignarUsuario: puedeVerTodo,
                      ),
                    ),
                  ),
                ],
              ),
              body: StreamBuilder<QuerySnapshot>(
                stream: ref,
                builder: (context, snap) {
                  if (snap.hasError) {
                    return const Center(
                      child: Text(
                        'Error al cargar Reservas',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No hay reservas registradas',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
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
          },
        );
      },
    );
  }
}
