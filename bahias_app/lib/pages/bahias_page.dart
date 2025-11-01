import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/bahias_service.dart';
import 'bahias/widgets.dart';

class BahiasPage extends StatefulWidget {
  const BahiasPage({super.key});

  @override
  State<BahiasPage> createState() => _BahiasPageState();
}

class _BahiasPageState extends State<BahiasPage> {
  final BahiasService _service = BahiasService();
  final Set<String> _selected = {};
  bool _hasProtectedSelected = false;
  bool _allInMaintenance = false;

  String _filtroEstado = 'Todos';
  String _filtroTipo = 'Todos';

  @override
  void initState() {
    super.initState();
    _service.ensureDefaultData();
  }

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

  @override
  Widget build(BuildContext context) {
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
            onTap: _service.addNewBahia,
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
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.streamBahias(),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Error al cargar Bahías'));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

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

          final width = MediaQuery.of(context).size.width;
          final crossCount = width >= 1400
              ? 5
              : width >= 1200
                  ? 4
                  : width >= 900
                      ? 3
                      : width >= 600
                          ? 2
                          : 1;

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.25,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final data = filtered[i].data();
              final id = filtered[i].id;
              final selected = _selected.contains(id);
              final isProtected = (data['No_Bahia'] ?? 0) <= 35;

              return BahiaCard(
                data: data,
                selected: selected,
                service: _service,
                showLock: isProtected,
                onLongPress: () {
                  setState(() {
                    selected ? _selected.remove(id) : _selected.add(id);
                  });
                  _updateSelectionState(docs);
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _setToMaintenance() async {
    await _service.setEstado('Mantenimiento', _selected.toList());
    setState(() {
      _selected.clear();
      _allInMaintenance = false;
    });
  }

  Future<void> _setToFree() async {
    await _service.setEstado('Libre', _selected.toList());
    setState(() {
      _selected.clear();
      _allInMaintenance = false;
    });
  }

  Future<void> _confirmDeleteSelected() async {
    await _service.deleteBahias(_selected.toList());
    setState(() => _selected.clear());
  }

  Future<void> _mostrarModalFiltros() async {
    await showModalBottomSheet(
      backgroundColor: const Color(0xFF111511),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) => FiltrosModal(
        filtroEstado: _filtroEstado,
        filtroTipo: _filtroTipo,
        onApply: (estado, tipo) {
          setState(() {
            _filtroEstado = estado;
            _filtroTipo = tipo;
          });
        },
      ),
    );
  }

  Future<void> _mostrarSelectorTipo() async {
    await showDialog(
      context: context,
      builder: (context) => SelectorTipo(
        onSelected: (tipo) async {
          await _service.updateTipo(_selected.toList(), tipo);
          setState(() => _selected.clear());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Tipo de bahía cambiado a '$tipo'"),
              backgroundColor: Colors.orangeAccent,
            ),
          );
        },
      ),
    );
  }

  Future<void> _mostrarSelectorUbicacion() async {
    await showDialog(
      context: context,
      builder: (context) => SelectorUbicacion(
        onSelected: (ubicacion) async {
          await _service.updateUbicacion(_selected.toList(), ubicacion);
          setState(() => _selected.clear());
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Ubicación cambiada a '$ubicacion'"),
              backgroundColor: Colors.deepPurpleAccent,
            ),
          );
        },
      ),
    );
  }
}
