import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bahias_app/presentation/state/parametros_provider.dart';

class ParametrosPage extends ConsumerStatefulWidget {
  const ParametrosPage({super.key});

  @override
  ConsumerState<ParametrosPage> createState() => _ParametrosPageState();
}

class _ParametrosPageState extends ConsumerState<ParametrosPage> {
  late final TextEditingController _apiBaseUrlCtrl;
  late final TextEditingController _timeoutCtrl;
  late final TextEditingController _retriesCtrl;

  @override
  void initState() {
    super.initState();
    _apiBaseUrlCtrl = TextEditingController();
    _timeoutCtrl = TextEditingController();
    _retriesCtrl = TextEditingController();

    // Carga inicial de parámetros guardados
    Future.microtask(() async {
      await ref.read(parametrosProvider.notifier).load();
      final params = ref.read(parametrosProvider);
      _apiBaseUrlCtrl.text = (params['api_base_url'] ?? '').toString();
      _timeoutCtrl.text = (params['timeout_seconds'] ?? '30').toString();
      _retriesCtrl.text = (params['max_retries'] ?? '3').toString();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _apiBaseUrlCtrl.dispose();
    _timeoutCtrl.dispose();
    _retriesCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveBasics() async {
    final notifier = ref.read(parametrosProvider.notifier);

    await notifier.setParam('api_base_url', _apiBaseUrlCtrl.text.trim());
    final timeout = int.tryParse(_timeoutCtrl.text.trim()) ?? 30;
    final retries = int.tryParse(_retriesCtrl.text.trim()) ?? 3;
    await notifier.setParam('timeout_seconds', timeout);
    await notifier.setParam('max_retries', retries);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parámetros básicos guardados')),
      );
    }
  }

  Future<void> _openAddCustomParamDialog() async {
    final keyCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    String type = 'Texto'; // Texto | Número | Lógico

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Agregar parámetro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyCtrl,
              decoration: const InputDecoration(
                labelText: 'Clave (ej: feature_x_enabled)',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: 'Texto', child: Text('Texto')),
                DropdownMenuItem(value: 'Número', child: Text('Número')),
                DropdownMenuItem(value: 'Lógico', child: Text('Lógico')),
              ],
              onChanged: (v) => type = v ?? 'Texto',
              decoration: const InputDecoration(labelText: 'Tipo'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valCtrl,
              decoration: const InputDecoration(
                labelText: 'Valor',
                helperText: 'Para Lógico usa true/false',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final key = keyCtrl.text.trim();
              final raw = valCtrl.text.trim();
              if (key.isEmpty) return;

              dynamic value = raw;
              if (type == 'Número') {
                value = int.tryParse(raw) ?? double.tryParse(raw) ?? raw;
              } else if (type == 'Lógico') {
                value = (raw.toLowerCase() == 'true');
              }

              await ref.read(parametrosProvider.notifier).setParam(key, value);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = ref.watch(parametrosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parámetros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Limpiar todos',
            onPressed: params.isEmpty
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('¿Limpiar todos los parámetros?'),
                        content: const Text(
                          'Esta acción eliminará todos los parámetros guardados.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sí, limpiar'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await ref.read(parametrosProvider.notifier).clear();
                    }
                  },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddCustomParamDialog,
        icon: const Icon(Icons.add),
        label: const Text('Agregar parámetro'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Básicos',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _apiBaseUrlCtrl,
            decoration: const InputDecoration(
              labelText: 'API Base URL',
              hintText: 'https://api.mi-dominio.com',
              prefixIcon: Icon(Icons.link),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _timeoutCtrl,
            decoration: const InputDecoration(
              labelText: 'Timeout (segundos)',
              prefixIcon: Icon(Icons.timer_outlined),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _retriesCtrl,
            decoration: const InputDecoration(
              labelText: 'Reintentos (intentos máximos)',
              prefixIcon: Icon(Icons.refresh),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saveBasics,
            icon: const Icon(Icons.save),
            label: const Text('Guardar básicos'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Avanzados (lista de parámetros guardados)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),

          if (params.isEmpty)
            const Text(
              'Aún no hay parámetros guardados. Usa "Agregar parámetro" para crear uno.',
            ),

          ...params.entries.map((e) => Card(
                child: ListTile(
                  dense: false,
                  title: Text(e.key),
                  subtitle: Text('${e.value}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref
                        .read(parametrosProvider.notifier)
                        .removeParam(e.key),
                    tooltip: 'Eliminar',
                  ),
                ),
              )),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
