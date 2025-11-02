import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/services.dart';
import './reservas/widgets.dart';

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
    final theme = Theme.of(context);
    final currentUser = _auth.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore.collection('Usuarios').doc(currentUser!.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        final rolRef = userData?['rolRef'] as DocumentReference?;

        if (rolRef == null) {
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: const Center(
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
              return Scaffold(
                backgroundColor: theme.colorScheme.surface,
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final rolData = rolSnap.data!.data() as Map<String, dynamic>?;
            final rolNombre =
                rolData?['nombre']?.toString().toLowerCase() ?? 'cliente';

            // 🔹 Permisos
            final puedeVerTodo =
                rolNombre == 'administrador' || rolNombre == 'operador';

            // 🔍 Construir consulta
            Query reservasQuery = _firestore
                .collection('Reservas')
                .orderBy('No_Reserva', descending: true);

            if (!puedeVerTodo) {
              reservasQuery = reservasQuery.where(
                'UsuarioRef',
                isEqualTo: _firestore
                    .collection('Usuarios')
                    .doc(currentUser.uid),
              );
            }

            final ref = reservasQuery.snapshots();

            return Scaffold(
              backgroundColor: theme.colorScheme.surface,
              appBar: AppBar(
                elevation: 3,
                backgroundColor:
                    theme.appBarTheme.backgroundColor ?? const Color(0xFF121712),
                title: Text(
                  "Reservas (${rolNombre[0].toUpperCase()}${rolNombre.substring(1)})",
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                actions: [
                  Tooltip(
                    message: 'Nueva reserva',
                    child: IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => FormularioReserva(
                          service: _service,
                          puedeAsignarUsuario: puedeVerTodo,
                        ),
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
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  if (!snap.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy,
                              color: theme.colorScheme.primary.withOpacity(0.6),
                              size: 50),
                          const SizedBox(height: 12),
                          Text(
                            'No hay reservas registradas',
                            style: TextStyle(
                              color:
                                  theme.colorScheme.onBackground.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (_, i) {
                      final data = docs[i].data() as Map<String, dynamic>;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: theme.shadowColor.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ReservaCard(
                          reservaId: docs[i].id,
                          data: data,
                          service: _service,
                        ),
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
