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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Filtrar Bahías",
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: theme.dividerColor.withOpacity(0.3)),
          const SizedBox(height: 10),

          _buildDropdown(
            context: context,
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
            context: context,
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
            icon: Icon(Icons.check, color: theme.colorScheme.onPrimary),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              widget.onApply(_estadoTemp, _tipoTemp);
              Navigator.pop(context);
            },
            label: const Text("Aplicar filtros"),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: value,
            dropdownColor: theme.dialogBackgroundColor,
            decoration: InputDecoration(
              labelText: title,
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: options
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
