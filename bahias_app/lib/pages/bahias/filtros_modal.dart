import 'package:flutter/material.dart';

class FiltrosModal extends StatefulWidget {
  final String filtroEstado;
  final String filtroTipo;
  final Function(String estado, String tipo) onApply;

  const FiltrosModal({
    super.key,
    required this.filtroEstado,
    required this.filtroTipo,
    required this.onApply,
  });

  @override
  State<FiltrosModal> createState() => _FiltrosModalState();
}

class _FiltrosModalState extends State<FiltrosModal> {
  late String _estadoTemp;
  late String _tipoTemp;

  @override
  void initState() {
    super.initState();
    _estadoTemp = widget.filtroEstado;
    _tipoTemp = widget.filtroTipo;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Filtrar Bahías",
            style: TextStyle(
                color: Colors.greenAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          _buildDropdown(
            title: "Estado",
            value: _estadoTemp,
            options: const [
              'Todos',
              'Libre',
              'Ocupado',
              'Mantenimiento',
              'Reservado'
            ],
            onChanged: (v) => setState(() => _estadoTemp = v!),
          ),
          const SizedBox(height: 10),
          _buildDropdown(
            title: "Tipo",
            value: _tipoTemp,
            options: const [
              'Todos',
              'General',
              'Ligera',
              'Pesada',
              'Refrigerado'
            ],
            onChanged: (v) => setState(() => _tipoTemp = v!),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            icon: const Icon(Icons.check, color: Colors.black),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              widget.onApply(_estadoTemp, _tipoTemp);
              Navigator.pop(context);
            },
            label: const Text("Aplicar filtros",
                style: TextStyle(color: Colors.black)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDropdown({
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
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.greenAccent),
                borderRadius: BorderRadius.circular(12),
              ),
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
}
