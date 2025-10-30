import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AgregarSolicitudPage extends StatefulWidget {
  const AgregarSolicitudPage({super.key});

  @override
  State<AgregarSolicitudPage> createState() => _AgregarSolicitudPageState();
}

class _AgregarSolicitudPageState extends State<AgregarSolicitudPage> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionCtrl = TextEditingController();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _esAdmin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _verificarRol();
  }

  Future<void> _verificarRol() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _db.collection('Usuarios').doc(user.email).get();
        final rol = doc.data()?['rol'] ?? 'cliente';
        setState(() {
          _esAdmin = rol.toLowerCase() == 'admin';
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error verificando rol: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _crearSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    await _db.collection('Solicitudes').add({
      'descripcion': _descripcionCtrl.text.trim(),
      'usuario': _auth.currentUser?.email,
      'fecha': Timestamp.now(),
      'estado': 'Pendiente',
    });

    _descripcionCtrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solicitud enviada correctamente')),
    );
  }

  Future<void> _actualizarEstado(String id, String nuevoEstado) async {
    await _db.collection('Solicitudes').doc(id).update({'estado': nuevoEstado});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _esAdmin ? _vistaAdministrador() : _vistaCliente(),
      ),
    );
  }

  /// 🧑‍💼 Vista del administrador: lista y aprobación
  Widget _vistaAdministrador() {
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('Solicitudes').orderBy('fecha', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No hay solicitudes', style: TextStyle(color: Colors.white70)));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              color: const Color(0xFF111511),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text(
                  data['descripcion'] ?? 'Sin descripción',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Usuario: ${data['usuario'] ?? '---'}\nEstado: ${data['estado']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                      tooltip: 'Aprobar',
                      onPressed: () => _actualizarEstado(docs[index].id, 'Aprobada'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.redAccent),
                      tooltip: 'Rechazar',
                      onPressed: () => _actualizarEstado(docs[index].id, 'Rechazada'),
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

  /// 👤 Vista del cliente: formulario + historial propio
  Widget _vistaCliente() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nueva Solicitud',
              style: TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _descripcionCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Descripción de la solicitud',
                    labelStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF1A1F1A),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Campo obligatorio' : null,
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar Solicitud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _crearSolicitud,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.greenAccent),
          const SizedBox(height: 10),
          const Text('Mis Solicitudes',
              style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          StreamBuilder<QuerySnapshot>(
            stream: _db
                .collection('Solicitudes')
                .where('usuario', isEqualTo: _auth.currentUser?.email)
                .orderBy('fecha', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No has realizado solicitudes aún', style: TextStyle(color: Colors.white70));
              }

              final docs = snapshot.data!.docs;
              return Column(
                children: docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return Card(
                    color: const Color(0xFF111511),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(
                        data['descripcion'] ?? 'Sin descripción',
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Estado: ${data['estado']}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
