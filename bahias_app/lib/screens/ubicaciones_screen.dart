import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ubicaciones_service.dart';

class UbicacionesScreen extends StatefulWidget {
  const UbicacionesScreen({super.key});

  @override
  State<UbicacionesScreen> createState() => _UbicacionesScreenState();
}

class _UbicacionesScreenState extends State<UbicacionesScreen> {
  final _service = UbicacionesService();

  Future<void> _openCreate() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111511),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: _UbicacionForm(
          title: 'Nueva ubicación',
          onSubmit: (id, nombre, descripcion) async {
            await _service.create(id: id, nombre: nombre, descripcion: descripcion);
          },
        ),
      ),
    );
  }

  Future<void> _openEdit(String id, String? nombre, String? descripcion) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111511),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: _UbicacionForm(
          title: 'Editar ubicación',
          editing: true,
          initialId: id,
          initialNombre: nombre ?? '',
          initialDescripcion: descripcion ?? '',
          onSubmit: (idEdited, nombreEdited, descripcionEdited) async {
            await _service.update(
              id: id,
              nombre: nombreEdited,
              descripcion: descripcionEdited,
            );
          },
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(String id) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111511),
        title: const Text('Eliminar ubicación', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Eliminar "$id"? Esta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final divider = const Divider(color: Colors.white24, height: 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicaciones'),
        backgroundColor: const Color(0xFF0B0F0B),
      ),
      backgroundColor: const Color(0xFF0B0F0B),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        backgroundColor: Colors.green.shade700,
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.streamUbicaciones(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.redAccent)),
            );
          }
          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text('No hay ubicaciones.', style: TextStyle(color: Colors.white70)),
            );
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => divider,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemBuilder: (context, i) {
              final d = docs[i];
              final id = d.id;
              final data = d.data();
              final nombre = (data['Nombre'] ?? '') as String;
              final descripcion = (data['Descripcion'] ?? '') as String;

              return Dismissible(
                key: ValueKey('ubic-$id'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.redAccent.withOpacity(0.8),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) async {
                  final ok = await _confirmDelete(id) ?? false;
                  if (ok) await _service.delete(id);
                  return ok;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF111511),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.place_outlined, color: Colors.greenAccent),
                      title: Text(
                        nombre.isNotEmpty ? nombre : id,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (nombre.isNotEmpty && id != nombre)
                            Text('ID: $id', style: const TextStyle(color: Colors.white38)),
                          if (descripcion.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(descripcion, style: const TextStyle(color: Colors.white60)),
                            ),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 6,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            icon: const Icon(Icons.edit, color: Colors.white70),
                            onPressed: () => _openEdit(id, nombre, descripcion),
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () async {
                              final ok = await _confirmDelete(id) ?? false;
                              if (ok) await _service.delete(id);
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

/// -------- Formulario (crear/editar) --------
class _UbicacionForm extends StatefulWidget {
  final String title;
  final bool editing;
  final String? initialId;
  final String? initialNombre;
  final String? initialDescripcion;
  final Future<void> Function(String id, String nombre, String? descripcion) onSubmit;

  const _UbicacionForm({
    required this.title,
    required this.onSubmit,
    this.editing = false,
    this.initialId,
    this.initialNombre,
    this.initialDescripcion,
  });

  @override
  State<_UbicacionForm> createState() => _UbicacionFormState();
}

class _UbicacionFormState extends State<_UbicacionForm> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _idCtrl.text = widget.initialId ?? '';
    _nombreCtrl.text = widget.initialNombre ?? '';
    _descCtrl.text = widget.initialDescripcion ?? '';
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final id = _idCtrl.text.trim();
      final nombre = _nombreCtrl.text.trim();
      final desc = _descCtrl.text.trim();
      await widget.onSubmit(id, nombre, desc.isEmpty ? null : desc);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _deco(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF0B0F0B),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.greenAccent),
          borderRadius: BorderRadius.circular(10),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                if (!widget.editing) ...[
                  TextFormField(
                    controller: _idCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _deco('ID del documento', 'Ej. Ubicacion 1'),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'El ID es obligatorio';
                      if (RegExp(r'[.#$\[\]/]').hasMatch(s)) {
                        return 'El ID no puede contener . # \$ [ ] /';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  controller: _nombreCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _deco('Nombre', 'Ej. Parqueo Central'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _deco('Descripción (opcional)', 'Zona o área base'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _submit,
                    icon: _saving
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.save),
                    label: Text(_saving ? 'Guardando...' : 'Guardar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
