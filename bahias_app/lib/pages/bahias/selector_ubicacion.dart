import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectorUbicacion extends StatefulWidget {
  final Function(String ubicacionSeleccionada) onSelected;

  const SelectorUbicacion({super.key, required this.onSelected});

  @override
  State<SelectorUbicacion> createState() => _SelectorUbicacionState();
}

class _SelectorUbicacionState extends State<SelectorUbicacion> {
  final _firestore = FirebaseFirestore.instance;
  List<String> _ubicaciones = [];
  String? _ubicacionSel;

  @override
  void initState() {
    super.initState();
    _loadUbicaciones();
  }

  Future<void> _loadUbicaciones() async {
    final snap = await _firestore.collection('Ubicacion').get();
    final ubicaciones = snap.docs.map((e) => e.id).toList();
    setState(() {
      _ubicaciones = ubicaciones;
      _ubicacionSel = ubicaciones.isNotEmpty ? ubicaciones.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111511),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Cambiar ubicación de Bahía",
        style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
      content: _ubicaciones.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent))
          : DropdownButton<String>(
              value: _ubicacionSel,
              dropdownColor: const Color(0xFF111511),
              isExpanded: true,
              iconEnabledColor: Colors.greenAccent,
              underline: Container(height: 1, color: Colors.greenAccent),
              items: _ubicaciones
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _ubicacionSel = v!),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
          onPressed: _ubicacionSel == null
              ? null
              : () {
                  widget.onSelected(_ubicacionSel!);
                  Navigator.pop(context);
                },
          child: const Text("Aplicar", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
