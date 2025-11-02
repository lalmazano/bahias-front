import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/services.dart';

class ParametrosScreen extends StatefulWidget {
  const ParametrosScreen({super.key});

  @override
  State<ParametrosScreen> createState() => _ParametrosScreenState();
}

class _ParametrosScreenState extends State<ParametrosScreen> {
  final _service = ParametrosService();

  Future<void> _openCreate() async {
    final theme = Theme.of(context);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.dialogBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: _ParametroForm(
          title: 'Nuevo parámetro',
          onSubmit: (id, minutos, descripcion) async {
            await _service.createParametro(
              id: id,
              minutos: minutos,
              descripcion:
                  descripcion?.trim().isEmpty == true ? null : descripcion,
            );
          },
        ),
      ),
    );
  }

  Future<void> _openEdit(String id, int? minutos, String? descripcion) async {
    final theme = Theme.of(context);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.dialogBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: _ParametroForm(
          title: 'Editar parámetro',
          initialId: id,
          initialMinutos: minutos?.toString() ?? '',
          initialDescripcion: descripcion ?? '',
          editing: true,
          onSubmit: (idEdited, minutosEdited, descripcionEdited) async {
            await _service.updateParametro(
              id: id,
              minutos: minutosEdited,
              descripcion: descripcionEdited,
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(String id) async {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text('Eliminar parámetro',
            style: TextStyle(color: theme.colorScheme.onSurface)),
        content: Text(
          '¿Eliminar "$id"? Esta acción no se puede deshacer.',
          style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style:
                    TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parámetros'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.streamParametros(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Error al cargar: ${snap.error}',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            );
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No hay parámetros.',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              ),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                Divider(color: theme.dividerColor, height: 1),
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (context, i) {
              final d = docs[i];
              final id = d.id;
              final data = d.data();
              final descripcion = (data['Descripcion'] ?? '') as String;
              final minutos = (data['Minutos'] is int)
                  ? data['Minutos'] as int
                  : int.tryParse('${data['Minutos']}');

              return Dismissible(
                key: ValueKey('param-$id'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: theme.colorScheme.error.withOpacity(0.8),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  final ok = await _confirmDelete(id) ?? false;
                  if (ok) await _service.deleteParametro(id);
                  return ok;
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.dividerColor.withOpacity(0.3)),
                    ),
                    child: ListTile(
                      leading:
                          Icon(Icons.tune, color: theme.colorScheme.primary),
                      title: Text(
                        id,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (descripcion.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 6.0, bottom: 2.0),
                              child: Text(
                                descripcion,
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7)),
                              ),
                            ),
                          Text(
                            'Minutos: ${minutos ?? '-'}',
                            style: TextStyle(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7)),
                          ),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: Icon(Icons.edit,
                                color: theme.colorScheme.secondary),
                            onPressed: () =>
                                _openEdit(id, minutos, descripcion),
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: Icon(Icons.delete_outline,
                                color: theme.colorScheme.errorContainer),
                            onPressed: () async {
                              final ok = await _confirmDelete(id) ?? false;
                              if (ok) await _service.deleteParametro(id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ---------- Formulario reutilizable (Crear/Editar) ----------
class _ParametroForm extends StatefulWidget {
  final String title;
  final bool editing;
  final String? initialId;
  final String? initialMinutos;
  final String? initialDescripcion;
  final Future<void> Function(String id, int minutos, String? descripcion)
      onSubmit;

  const _ParametroForm({
    required this.title,
    required this.onSubmit,
    this.editing = false,
    this.initialId,
    this.initialMinutos,
    this.initialDescripcion,
  });

  @override
  State<_ParametroForm> createState() => _ParametroFormState();
}

class _ParametroFormState extends State<_ParametroForm> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _idCtrl.text = widget.initialId ?? '';
    _minCtrl.text = widget.initialMinutos ?? '';
    _descCtrl.text = widget.initialDescripcion ?? '';
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _minCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final id = _idCtrl.text.trim();
      final minutos = int.parse(_minCtrl.text.trim());
      final desc = _descCtrl.text.trim();
      await widget.onSubmit(id, minutos, desc.isEmpty ? null : desc);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    InputDecoration deco(String label, String hint) => InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle:
              TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
          hintStyle:
              TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4)),
          filled: true,
          fillColor: theme.cardColor,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.4)),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.primary),
            borderRadius: BorderRadius.circular(10),
          ),
        );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            widget.title,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (!widget.editing) ...[
                  TextFormField(
                    controller: _idCtrl,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration:
                        deco('ID del documento', 'Ej. TiempoAntesReserva'),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'El ID es obligatorio';
                      final invalid =
                          RegExp(r'[.#$\[\]/]').hasMatch(s);
                      if (invalid) return 'El ID no puede contener . # \$ [ ] /';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _minCtrl,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  keyboardType: TextInputType.number,
                  decoration: deco('Minutos', 'Ej. 30'),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    final n = int.tryParse(s);
                    if (n == null) return 'Ingresa un número válido';
                    if (n < 0) return 'No puede ser negativo';
                    if (n > 1440) return 'Máximo 1440 minutos (24h)';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: deco('Descripción (opcional)', 'Texto explicativo'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_saving ? 'Guardando...' : 'Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
