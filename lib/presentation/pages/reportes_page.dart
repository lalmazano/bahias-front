import 'package:flutter/material.dart';
import './widgets/app_drawer.dart';

class ReportesPage extends StatelessWidget {
  const ReportesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Ejemplo de bahías con estados dinámicos (esto debería ser de tu base de datos)
    final List<Map<String, dynamic>> bahias = [
      {'nombre': 'Bahía 1', 'estado': 'libre', 'puestos': 3},
      {'nombre': 'Bahía 2', 'estado': 'ocupada', 'puestos': 2},
      {'nombre': 'Bahía 3', 'estado': 'mantenimiento', 'puestos': 4},
      {'nombre': 'Bahía 4', 'estado': 'libre', 'puestos': 1},
      {'nombre': 'Bahía 5', 'estado': 'ocupada', 'puestos': 5},
    ];

    // Cálculos dinámicos de las bahías
    int mantenimiento = 0;
    int libres = 0;
    int ocupadas = 0;

    for (var bahia in bahias) {
      switch (bahia['estado']) {
        case 'libre':
          libres++;
          break;
        case 'ocupada':
          ocupadas++;
          break;
        case 'mantenimiento':
          mantenimiento++;
          break;
        default:
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        centerTitle: true,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          const _BackgroundGradient(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Reportes y estadísticas',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // Resumen rápido
                      _QuickCard(
                        title: 'Resumen rápido',
                        items: [
                          _QuickItem(
                            icon: Icons.build_outlined,
                            label: 'En mantenimiento',
                            value: '$mantenimiento',
                          ),
                          _QuickItem(
                            icon: Icons.check_circle_outline,
                            label: 'Libres',
                            value: '$libres',
                          ),
                          _QuickItem(
                            icon: Icons.bookmark_border,
                            label: 'Ocupadas',
                            value: '$ocupadas',
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Lista de bahías con detalles
                      const Text(
                        'Detalles de las bahías:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tabla de bahías con información
                      Expanded(
                        child: ListView.builder(
                          itemCount: bahias.length,
                          itemBuilder: (context, index) {
                            final bahia = bahias[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                title: Text('Bahía: ${bahia['nombre']}'),
                                subtitle: Text(
                                  'Estado: ${bahia['estado']} - Puestos: ${bahia['puestos']}',
                                ),
                                trailing: Icon(
                                  bahia['estado'] == 'ocupada'
                                      ? Icons.directions_car
                                      : Icons.local_parking,
                                  color: bahia['estado'] == 'ocupada'
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withOpacity(0.35),
            scheme.surfaceVariant.withOpacity(0.25),
            scheme.surface,
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String title;
  final List<_QuickItem> items;
  const _QuickCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.insights_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: items
                  .map((e) => Expanded(
                        child: _QuickStat(
                          icon: e.icon,
                          label: e.label,
                          value: e.value,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final String value;
  const _QuickItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.65),
    );
    final valueStyle =
        theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: valueStyle),
              Text(label, style: labelStyle),
            ],
          ),
        ],
      ),
    );
  }
}
