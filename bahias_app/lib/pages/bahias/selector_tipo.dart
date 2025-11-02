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
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Cambiar tipo de Bahía",
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: _tipos.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
          : DropdownButton<String>(
              value: _tipoSel,
              dropdownColor: theme.dialogBackgroundColor,
              isExpanded: true,
              iconEnabledColor: theme.colorScheme.primary,
              underline:
                  Container(height: 1, color: theme.colorScheme.primary),
              items: _tipos
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _tipoSel = v!),
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
          onPressed: _tipoSel == null
              ? null
              : () {
                  widget.onSelected(_tipoSel!);
                  Navigator.pop(context);
                },
          child: const Text("Aplicar"),
        ),
      ],
    );
  }
}
