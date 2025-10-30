import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';


class BahiasPage extends StatefulWidget {
  const BahiasPage({super.key});

  @override
  State<BahiasPage> createState() => _BahiasPageState();
}

class _BahiasPageState extends State<BahiasPage> {
  final _firestore = FirebaseFirestore.instance;
  final Set<String> _selected = {}; // IDs seleccionados

  @override
  void initState() {
    super.initState();
    _ensureDefaultBahias();
  }

  /// 🔧 Crear las primeras 35 bahías si no existen
  Future<void> _ensureDefaultBahias() async {
    final bahias = await _firestore.collection('Bahias').get();
    if (bahias.size < 35) {
      final tipoRef = _firestore.collection('Tipo_Bahia').doc('General');
      final estadoRef = _firestore.collection('Tipo_Estado').doc('Libre');

      for (int i = 1; i <= 35; i++) {
        final docId = i.toString().padLeft(2, '0');
        final existing = await _firestore
            .collection('Bahias')
            .where('No_Bahia', isEqualTo: i)
            .limit(1)
            .get();

        if (existing.docs.isEmpty) {
          await _firestore.collection('Bahias').doc(docId).set({
            'No_Bahia': i,
            'Nombre': 'Bahía $i',
            'TipoRef': tipoRef,
            'EstadoRef': estadoRef,
          });
        }
      }
      debugPrint("✅ 35 bahías creadas/verificadas correctamente");
    }
  }

  Color _estadoColor(String estado) {
    final e = estado.toLowerCase();
    if (e.contains('ocup')) return const Color(0xFFFFC107); // amarillo
    if (e.contains('manten')) return const Color(0xFF42A5F5); // azul
    return const Color(0xFF2ECC71); // verde
  }

  @override
  Widget build(BuildContext context) {
    final ref = _firestore.collection('Bahias').orderBy('No_Bahia').snapshots();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0B),
      appBar: AppBar(
        title: const Text("Gestión de Bahías"),
        backgroundColor: Colors.black,
        actions: [
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  "${_selected.length} seleccionada(s)",
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                ),
              ),
            ),
        ],
      ),

 // ✅ FAB desplegable (SpeedDial)
floatingActionButton: SpeedDial(
  icon: Icons.menu,
  activeIcon: Icons.close,
  backgroundColor: Colors.greenAccent,
  foregroundColor: Colors.black,
  overlayOpacity: 0.3,
  direction: isDesktop ? SpeedDialDirection.left : SpeedDialDirection.up,
  spacing: 10,
  children: [
    SpeedDialChild(
      child: const Icon(Icons.add),
      label: "Agregar Bahía",
      labelStyle: const TextStyle(color: Colors.black),
      backgroundColor: Colors.greenAccent,
      foregroundColor: Colors.black,
      onTap: _addNewBahia,
    ),
    if (_selected.isNotEmpty)
      SpeedDialChild(
        child: const Icon(Icons.delete),
        label: "Eliminar seleccionadas",
        labelStyle: const TextStyle(color: Colors.white),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        onTap: _confirmDeleteSelected,
      ),
  ],
),


      body: StreamBuilder<QuerySnapshot>(
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
                final cross = w >= 1400
                    ? 5
                    : w >= 1200
                        ? 4
                        : w >= 900
                            ? 3
                            : w >= 600
                                ? 2
                                : 1;

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
                    final no = data['No_Bahia'] ?? 0;
                    final nombre = data['Nombre'] ?? 'Sin nombre';
                    final tipoRef = data['TipoRef'] as DocumentReference?;
                    final estadoRef = data['EstadoRef'] as DocumentReference?;
                    final docId = docs[i].id;
                    final selected = _selected.contains(docId);

                    return FutureBuilder(
                      future: _ensureReferences(tipoRef, estadoRef),
                      builder: (context, AsyncSnapshot<List<DocumentSnapshot?>> snap2) {
                        if (!snap2.hasData) {
                          return const Center(
                              child: CircularProgressIndicator(strokeWidth: 1.5));
                        }

                        final tipoDoc = snap2.data?[0];
                        final estadoDoc = snap2.data?[1];
                        final tipoNombre = tipoDoc?.id ?? 'Sin tipo';
                        final estadoNombre = estadoDoc?.id ?? 'Sin estado';
                        final estadoColor = _estadoColor(estadoNombre);
                        final isLocked = no <= 35;

                        return GestureDetector(
                          onLongPress: () {
                            if (!isLocked) {
                              setState(() {
                                selected
                                    ? _selected.remove(docId)
                                    : _selected.add(docId);
                              });
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.greenAccent.withOpacity(0.1)
                                  : const Color(0xFF111511),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selected
                                    ? Colors.greenAccent.withOpacity(0.8)
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Bahía $no',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.lightBlueAccent,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  nombre,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.white70),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: estadoColor.withOpacity(0.18),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: estadoColor.withOpacity(0.45)),
                                  ),
                                  child: Text(
                                    estadoNombre,
                                    style: TextStyle(
                                      color: estadoColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tipo: $tipoNombre",
                                  style: const TextStyle(
                                      color: Colors.greenAccent, fontSize: 13),
                                ),
                                if (isLocked)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 6),
                                    child: Icon(Icons.lock_outline,
                                        size: 18, color: Colors.white38),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// 🧩 Agregar una nueva bahía
  Future<void> _addNewBahia() async {
    final coll = _firestore.collection('Bahias');
    final total = (await coll.get()).size;
    final newNo = total + 1;
    final tipoRef = _firestore.collection('Tipo_Bahia').doc('General');
    final estadoRef = _firestore.collection('Tipo_Estado').doc('Libre');

    await coll.doc(newNo.toString().padLeft(2, '0')).set({
      'No_Bahia': newNo,
      'Nombre': 'Bahía $newNo',
      'TipoRef': tipoRef,
      'EstadoRef': estadoRef,
    });
  }

  /// 🗑️ Confirmar eliminación múltiple
  Future<void> _confirmDeleteSelected() async {
    if (_selected.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111511),
        title: const Text("Eliminar Bahías",
            style: TextStyle(color: Colors.greenAccent)),
        content: Text(
          "¿Seguro que deseas eliminar ${_selected.length} bahía(s)?\n\n(No se eliminarán las primeras 35)",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar",
                  style: TextStyle(color: Colors.white70))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      for (final id in _selected) {
        final doc = await _firestore.collection('Bahias').doc(id).get();
        final no = doc.data()?['No_Bahia'] ?? 0;
        if (no > 35) {
          await _firestore.collection('Bahias').doc(id).delete();
        }
      }

      setState(() => _selected.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bahías eliminadas correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  /// 🔧 Verifica referencias y crea las faltantes
  Future<List<DocumentSnapshot?>> _ensureReferences(
      DocumentReference? tipoRef, DocumentReference? estadoRef) async {
    final firestore = FirebaseFirestore.instance;
    tipoRef ??= firestore.collection('Tipo_Bahia').doc('General');
    estadoRef ??= firestore.collection('Tipo_Estado').doc('Libre');

    final tipoSnap = await tipoRef.get();
    if (!tipoSnap.exists) {
      await tipoRef.set({'Descripcion': 'Tipo creado automáticamente'});
    }

    final estadoSnap = await estadoRef.get();
    if (!estadoSnap.exists) {
      await estadoRef.set({'Descripcion': 'Estado creado automáticamente'});
    }

    final tipoFinal = await tipoRef.get();
    final estadoFinal = await estadoRef.get();

    return [tipoFinal, estadoFinal];
  }
}
