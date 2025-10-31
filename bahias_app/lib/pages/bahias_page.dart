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
  final Set<String> _selected = {};
  bool _hasProtectedSelected = false;
  bool _allInMaintenance = false;

  String _filtroEstado = 'Todos';
  String _filtroTipo = 'Todos';

  @override
  void initState() {
    super.initState();
    _ensureDefaultBahias();
  }

  /// 🔧 Crear colecciones base y bahías por defecto
  Future<void> _ensureDefaultBahias() async {
    await _ensureDefaultUbicaciones(); // 🆕 primero aseguramos ubicaciones

    final coll = _firestore.collection('Bahias');
    final tipoRefDefault = _firestore.collection('Tipo_Bahia').doc('General');
    final estadoRefDefault = _firestore.collection('Tipo_Estado').doc('Libre');
    final ubicacionRefDefault = _firestore.collection('Ubicacion').doc('Ubicacion 1');

    //final bahias = await coll.get();

    for (int i = 1; i <= 35; i++) {
      final docId = i.toString().padLeft(2, '0');
      final docRef = coll.doc(docId);
      final snap = await docRef.get();

      if (!snap.exists) {
        await docRef.set({
          'No_Bahia': i,
          'Nombre': 'Bahía $i',
          'TipoRef': tipoRefDefault,
          'EstadoRef': estadoRefDefault,
          'UbicacionRef': ubicacionRefDefault,
        });
      } else {
        await _ensureCamposBahia(docRef, snap);
      }
    }
  }

  /// 🧩 Crear ubicaciones base si no existen
  Future<void> _ensureDefaultUbicaciones() async {
    final coll = _firestore.collection('Ubicacion');
    for (int i = 1; i <= 3; i++) {
      final docId = 'Ubicacion $i';
      final docRef = coll.doc(docId);
      final snap = await docRef.get();
      if (!snap.exists) {
        await docRef.set({
          'Nombre': 'Ubicación $i',
          'Descripcion': 'Zona o área base número $i',
        });
      }
    }
  }

  /// 🔍 Verifica y crea campos faltantes
  Future<void> _ensureCamposBahia(
      DocumentReference<Map<String, dynamic>> docRef,
      DocumentSnapshot<Map<String, dynamic>> snap) async {
    final data = snap.data() ?? {};
    final updates = <String, dynamic>{};

    final tipoRefDefault = _firestore.collection('Tipo_Bahia').doc('General');
    final estadoRefDefault = _firestore.collection('Tipo_Estado').doc('Libre');
    final ubicacionRefDefault = _firestore.collection('Ubicacion').doc('Ubicacion 1');

    if (!data.containsKey('No_Bahia')) {
      final idNum = int.tryParse(docRef.id) ?? 0;
      updates['No_Bahia'] = idNum;
    }
    if (!data.containsKey('Nombre')) {
      updates['Nombre'] = 'Bahía ${data['No_Bahia'] ?? docRef.id}';
    }
    if (!data.containsKey('TipoRef') || data['TipoRef'] == null) {
      updates['TipoRef'] = tipoRefDefault;
    }
    if (!data.containsKey('EstadoRef') || data['EstadoRef'] == null) {
      updates['EstadoRef'] = estadoRefDefault;
    }
    if (!data.containsKey('UbicacionRef') || data['UbicacionRef'] == null) {
      updates['UbicacionRef'] = ubicacionRefDefault;
    }

    if (updates.isNotEmpty) await docRef.update(updates);
  }

  Color _estadoColor(String estado) {
    final e = estado.toLowerCase();
    if (e.contains('ocup')) return const Color(0xFFFFC107);
    if (e.contains('manten')) return const Color(0xFF42A5F5);
    if (e.contains('reserv')) return const Color(0xFF9C27B0);
    return const Color(0xFF2ECC71);
  }

  @override
  Widget build(BuildContext context) {
    final ref = _firestore.collection('Bahias').orderBy('No_Bahia').snapshots();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0B),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Bahías"),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt_outlined,
              color: (_filtroEstado != 'Todos' || _filtroTipo != 'Todos')
                  ? Colors.greenAccent
                  : Colors.white70,
            ),
            tooltip: "Filtrar",
            onPressed: _mostrarModalFiltros,
          ),
        ],
      ),

      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        direction: isDesktop ? SpeedDialDirection.left : SpeedDialDirection.up,
        overlayOpacity: 0.3,
        spacing: 10,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: "Agregar Bahía",
            backgroundColor: Colors.greenAccent,
            onTap: _addNewBahia,
          ),
          if (_selected.isNotEmpty)
            SpeedDialChild(
              child: const Icon(Icons.engineering),
              label: "Mantenimiento",
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              onTap: _setToMaintenance,
            ),
          if (_selected.isNotEmpty && _allInMaintenance)
            SpeedDialChild(
              child: const Icon(Icons.refresh),
              label: "Liberar Bahías",
              backgroundColor: Colors.lightGreenAccent,
              onTap: _setToFree,
            ),
          if (_selected.isNotEmpty)
            SpeedDialChild(
              child: const Icon(Icons.category_outlined),
              label: "Cambiar tipo",
              backgroundColor: Colors.orangeAccent,
              onTap: _mostrarSelectorTipo,
            ),
          if (_selected.isNotEmpty)
            SpeedDialChild(
              child: const Icon(Icons.location_on_outlined),
              label: "Cambiar ubicación",
              backgroundColor: Colors.deepPurpleAccent,
              onTap: _mostrarSelectorUbicacion,
            ),
          if (_selected.isNotEmpty && !_hasProtectedSelected)
            SpeedDialChild(
              child: const Icon(Icons.delete),
              label: "Eliminar",
              backgroundColor: Colors.redAccent,
              onTap: _confirmDeleteSelected,
            ),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: ref,
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Error al cargar Bahías'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snap.data!.docs;

          final filtered = docs.where((d) {
            final estado = (d['EstadoRef'] as DocumentReference?)?.id ?? '';
            final tipo = (d['TipoRef'] as DocumentReference?)?.id ?? '';
            final matchEstado = _filtroEstado == 'Todos' ||
                estado.toLowerCase() == _filtroEstado.toLowerCase();
            final matchTipo = _filtroTipo == 'Todos' ||
                tipo.toLowerCase() == _filtroTipo.toLowerCase();
            return matchEstado && matchTipo;
          }).toList();

          final w = MediaQuery.of(context).size.width;
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
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cross,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.25,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final data = filtered[i].data() as Map<String, dynamic>;
              final no = data['No_Bahia'] ?? 0;
              final tipoRef = data['TipoRef'] as DocumentReference?;
              final estadoRef = data['EstadoRef'] as DocumentReference?;
              final ubicacionRef = data['UbicacionRef'] as DocumentReference?;
              final docId = filtered[i].id;
              final selected = _selected.contains(docId);
              final isProtected = no <= 35;

              return FutureBuilder(
                future: _ensureReferences(tipoRef, estadoRef, ubicacionRef),
                builder: (context, snap2) {
                  if (!snap2.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(strokeWidth: 1.5));
                  }

                  final tipoNombre = snap2.data![0]?.id ?? 'Sin tipo';
                  final estadoNombre = snap2.data![1]?.id ?? 'Sin estado';
                  final ubicacionNombre = snap2.data![2]?.id ?? 'Sin ubicación';
                  final estadoColor = _estadoColor(estadoNombre);

                  return GestureDetector(
                    onLongPress: () {
                      setState(() {
                        selected ? _selected.remove(docId) : _selected.add(docId);
                      });
                      _updateSelectionState(docs);
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
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Bahía $no',
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlueAccent)),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: estadoColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: estadoColor.withOpacity(0.45)),
                            ),
                            child: Text(
                              estadoNombre,
                              style: TextStyle(
                                  color: estadoColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text("Tipo: $tipoNombre",
                              style: const TextStyle(
                                  color: Colors.greenAccent, fontSize: 13)),
                          Text("Ubicación: $ubicacionNombre",
                              style: const TextStyle(
                                  color: Colors.orangeAccent, fontSize: 13)),
                          if (isProtected)
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
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
  }

 /// 🧠 Actualizar estado de selección
  void _updateSelectionState(List<QueryDocumentSnapshot> docs) {
    bool hasProtected = false;
    bool allMaintenance = true;

    for (final id in _selected) {
      final doc = docs.firstWhere((d) => d.id == id);
      final no = doc['No_Bahia'] ?? 0;
      final estadoRef = doc['EstadoRef'] as DocumentReference?;
      if (no <= 35) hasProtected = true;
      if (estadoRef?.id != 'Mantenimiento') allMaintenance = false;
    }

    setState(() {
      _hasProtectedSelected = hasProtected;
      _allInMaintenance = allMaintenance && _selected.isNotEmpty;
    });
  }

  /// 🧰 Cambiar estado a mantenimiento
  Future<void> _setToMaintenance() async {
    final estado = _firestore.collection('Tipo_Estado').doc('Mantenimiento');
    for (final id in _selected) {
      await _firestore.collection('Bahias').doc(id).update({'EstadoRef': estado});
    }
    setState(() {
      _selected.clear();
      _allInMaintenance = false;
    });
  }

  /// 🔄 Cambiar estado a libre
  Future<void> _setToFree() async {
    final estado = _firestore.collection('Tipo_Estado').doc('Libre');
    for (final id in _selected) {
      await _firestore.collection('Bahias').doc(id).update({'EstadoRef': estado});
    }
    setState(() {
      _selected.clear();
      _allInMaintenance = false;
    });
  }

  /// 🗑️ Eliminar bahías seleccionadas
  Future<void> _confirmDeleteSelected() async {
    for (final id in _selected) {
      final doc = await _firestore.collection('Bahias').doc(id).get();
      final no = doc.data()?['No_Bahia'] ?? 0;
      if (no > 35) await doc.reference.delete();
    }
    setState(() => _selected.clear());
  }
  /// 🔍 Garantizar referencias válidas
  Future<List<DocumentSnapshot?>> _ensureReferences(
      DocumentReference? tipoRef,
      DocumentReference? estadoRef,
      DocumentReference? ubicacionRef) async {
    tipoRef ??= _firestore.collection('Tipo_Bahia').doc('General');
    estadoRef ??= _firestore.collection('Tipo_Estado').doc('Libre');
    ubicacionRef ??= _firestore.collection('Ubicacion').doc('Ubicacion 1');
    return [await tipoRef.get(), await estadoRef.get(), await ubicacionRef.get()];
  }
  /// 🔍 Modal filtros
  Future<void> _mostrarModalFiltros() async {
    String estadoTemp = _filtroEstado;
    String tipoTemp = _filtroTipo;

    await showModalBottomSheet(
      backgroundColor: const Color(0xFF111511),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Filtrar Bahías",
                  style: TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              _buildModalDropdown(
                title: "Estado",
                value: estadoTemp,
                options: const [
                  'Todos',
                  'Libre',
                  'Ocupado',
                  'Mantenimiento',
                  'Reservado'
                ],
                onChanged: (v) => setModalState(() => estadoTemp = v!),
              ),
              const SizedBox(height: 10),
              _buildModalDropdown(
                title: "Tipo",
                value: tipoTemp,
                options: const [
                  'Todos',
                  'General',
                  'Ligera',
                  'Pesada',
                  'Refrigerado'
                ],
                onChanged: (v) => setModalState(() => tipoTemp = v!),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                icon: const Icon(Icons.check, color: Colors.black),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  setState(() {
                    _filtroEstado = estadoTemp;
                    _filtroTipo = tipoTemp;
                  });
                  Navigator.pop(context);
                },
                label: const Text("Aplicar filtros",
                    style: TextStyle(color: Colors.black)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalDropdown({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            dropdownColor: const Color(0xFF111511),
            decoration: InputDecoration(
              labelText: title,
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(12)),
            ),
            items: options
                .map((e) => DropdownMenuItem(
                      value: e,
                      child:
                          Text(e, style: const TextStyle(color: Colors.white)),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// 🧩 Cambiar tipo
  Future<void> _mostrarSelectorTipo() async {
    final tiposSnap = await _firestore.collection('Tipo_Bahia').get();
    final tipos = tiposSnap.docs.map((e) => e.id).toList();
    String tipoSel = tipos.first;

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF111511),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Cambiar tipo de Bahía",
              style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          content: DropdownButton<String>(
            value: tipoSel,
            dropdownColor: const Color(0xFF111511),
            isExpanded: true,
            iconEnabledColor: Colors.greenAccent,
            underline: Container(height: 1, color: Colors.greenAccent),
            items: tipos
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: const TextStyle(color: Colors.white)),
                  ),
                )
                .toList(),
            onChanged: (v) => setDialogState(() => tipoSel = v!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Cancelar", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent),
              onPressed: () => Navigator.pop(context, tipoSel),
              child: const Text("Aplicar",
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );

    if (resultado != null) {
      final tipoRef = _firestore.collection('Tipo_Bahia').doc(resultado);

      for (final id in _selected) {
        await _firestore.collection('Bahias').doc(id).update({
          'TipoRef': tipoRef,
        });
      }

      setState(() => _selected.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tipo de bahía cambiado a '$resultado'"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    }
  }

  /// ➕ Agregar nueva
  Future<void> _addNewBahia() async {
    final coll = _firestore.collection('Bahias');
    final total = (await coll.get()).size;
    final tipoRef = _firestore.collection('Tipo_Bahia').doc('General');
    final estadoRef = _firestore.collection('Tipo_Estado').doc('Libre');
    await coll.doc((total + 1).toString().padLeft(2, '0')).set({
      'No_Bahia': total + 1,
      'Nombre': 'Bahía ${total + 1}',
      'TipoRef': tipoRef,
      'EstadoRef': estadoRef,
    });
  }

   /// 📍 Cambiar ubicación
  Future<void> _mostrarSelectorUbicacion() async {
    final ubicacionesSnap = await _firestore.collection('Ubicacion').get();
    final ubicaciones = ubicacionesSnap.docs.map((e) => e.id).toList();
    String ubicacionSel = ubicaciones.first;

    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF111511),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Cambiar ubicación de Bahía",
              style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          content: DropdownButton<String>(
            value: ubicacionSel,
            dropdownColor: const Color(0xFF111511),
            isExpanded: true,
            iconEnabledColor: Colors.greenAccent,
            underline: Container(height: 1, color: Colors.greenAccent),
            items: ubicaciones
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(color: Colors.white)),
                  ),
                )
                .toList(),
            onChanged: (v) => setDialogState(() => ubicacionSel = v!),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
              onPressed: () => Navigator.pop(context, ubicacionSel),
              child: const Text("Aplicar", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );

    if (resultado != null) {
      final ubicacionRef = _firestore.collection('Ubicacion').doc(resultado);
      for (final id in _selected) {
        await _firestore.collection('Bahias').doc(id).update({
          'UbicacionRef': ubicacionRef,
        });
      }

      setState(() => _selected.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ubicación cambiada a '$resultado'"),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      );
    }
  }
}
