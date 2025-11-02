import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectorUbicacion extends StatefulWidget {
  final Function(String ubicacionIdSeleccionada) onSelected;

  const SelectorUbicacion({super.key, required this.onSelected});

  @override
  State<SelectorUbicacion> createState() => _SelectorUbicacionState();
}

class _SelectorUbicacionState extends State<SelectorUbicacion> {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, String>> _ubicaciones = [];
  String? _ubicacionSel;

  @override
  void initState() {
    super.initState();
    _loadUbicaciones();
  }

  Future<void> _loadUbicaciones() async {
    final snap = await _firestore.collection('Ubicacion').get();

    final ubicaciones = snap.docs.map((e) {
      final data = e.data();
      return {
        'id': e.id,
        'nombre': data['Nombre']?.toString() ?? 'Sin nombre',
      };
    }).toList();

    setState(() {
      _ubicaciones = ubicaciones;
      _ubicacionSel = ubicaciones.isNotEmpty ? ubicaciones.first['id'] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Cambiar ubicación de Bahía",
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: _ubicaciones.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : DropdownButton<String>(
              value: _ubicacionSel,
              dropdownColor: theme.dialogBackgroundColor,
              isExpanded: true,
              iconEnabledColor: theme.colorScheme.primary,
              underline: Container(
                height: 1,
                color: theme.colorScheme.primary,
              ),
              items: _ubicaciones.map((e) {
                return DropdownMenuItem(
                  value: e['id'],
                  child: Text(
                    e['nombre']!,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                );
              }).toList(),
              onChanged: (v) => setState(() => _ubicacionSel = v),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            "Cancelar",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          onPressed: _ubicacionSel == null
              ? null
              : () {
                  widget.onSelected(_ubicacionSel!); // devuelve el id real
                  Navigator.pop(context);
                },
          child: const Text("Aplicar"),
        ),
      ],
    );
  }
}
