import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectorTipo extends StatefulWidget {
  final Function(String tipoSeleccionado) onSelected;

  const SelectorTipo({super.key, required this.onSelected});

  @override
  State<SelectorTipo> createState() => _SelectorTipoState();
}

class _SelectorTipoState extends State<SelectorTipo> {
  final _firestore = FirebaseFirestore.instance;
  List<String> _tipos = [];
  String? _tipoSel;

  @override
  void initState() {
    super.initState();
    _loadTipos();
  }

  Future<void> _loadTipos() async {
    final snap = await _firestore.collection('Tipo_Bahia').get();
    final tipos = snap.docs.map((e) => e.id).toList();
    setState(() {
      _tipos = tipos;
      _tipoSel = tipos.isNotEmpty ? tipos.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF111511),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        "Cambiar tipo de Bahía",
        style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
      content: _tipos.isEmpty
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent))
          : DropdownButton<String>(
              value: _tipoSel,
              dropdownColor: const Color(0xFF111511),
              isExpanded: true,
              iconEnabledColor: Colors.greenAccent,
              underline: Container(height: 1, color: Colors.greenAccent),
              items: _tipos
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _tipoSel = v!),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
        ),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
          onPressed: _tipoSel == null
              ? null
              : () {
                  widget.onSelected(_tipoSel!);
                  Navigator.pop(context);
                },
          child: const Text("Aplicar", style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
