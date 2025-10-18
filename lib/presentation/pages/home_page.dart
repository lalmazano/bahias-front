import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Ejemplo de bahías con estados dinámicos (esto debería ser de tu base de datos)
    final List<Map<String, dynamic>> bahias = [
      {'nombre': 'Bahía 1', 'estado': 'libre'},
      {'nombre': 'Bahía 2', 'estado': 'ocupada'},
      {'nombre': 'Bahía 3', 'estado': 'mantenimiento'},
      {'nombre': 'Bahía 4', 'estado': 'libre'},
      {'nombre': 'Bahía 5', 'estado': 'ocupada'},
    ];

    // Cálculos dinámicos de las bahías
    int mantenimiento = 0;
    int libres = 0;
    int reserva = 0;
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
        title: const Text('Inicio'),
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
                        'Bienvenido a',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aplicación de Bahías',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Administra, monitorea y consulta información de tus bahías\n'
                        'de forma simple y rápida.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

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
                            label: 'En reserva',
                            value: '$reserva',
                          ),
                          _QuickItem(
                            icon: Icons.local_parking,
                            label: 'Ocupadas',
                            value: '$ocupadas',
                          ),
                        ],
                      ),

                      const SizedBox(height: 22),

                      // Acciones principales con GoRouter
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            icon: const Icon(Icons.dashboard_customize_rounded),
                            label: const Text('Ir al panel'),
                            onPressed: () {
                              context.go('/bays'); // acceso al menú de bahías
                            },
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.table_chart_outlined),
                            label: const Text('Ver reportes'),
                            onPressed: () {
                              context.go('/reportes'); // ruta de reportes
                            },
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.settings_outlined),
                            label: const Text('Configuración'),
                            onPressed: () {
                              context.go('/configuracion'); // ruta de configuración
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),
                      Opacity(
                        opacity: 0.6,
                        child: Text(
                          'v1.0.0 • ${DateTime.now().year}',
                          style: theme.textTheme.bodySmall,
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
        child: LayoutBuilder(
          builder: (context, c) {
            final isNarrow = c.maxWidth < 480; // móvil angosto

            final header = Row(
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
            );

            // Misma tarjeta de stat para todos los tamaños
            final stats = items
                .map((e) => _QuickStat(icon: e.icon, label: e.label, value: e.value))
                .toList();

            if (isNarrow) {
              // En móviles: 2 x fila (Wrap)
              final spacing = 12.0;
              final itemWidth = (c.maxWidth - spacing) / 2; // 2 columnas

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  header,
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: stats
                        .map((w) => SizedBox(width: itemWidth, child: w))
                        .toList(),
                  ),
                ],
              );
            } else {
              // En pantallas anchas: una sola fila
              return Column(
                children: [
                  header,
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: stats.map((w) => Expanded(child: w)).toList(),
                  ),
                ],
              );
            }
          },
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
  const _QuickStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.65),
      overflow: TextOverflow.ellipsis,
    );
    final valueStyle = theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        // Flexible evita overflow; FittedBox encoge si es necesario
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(value, style: valueStyle),
              ),
              Text(label, style: labelStyle, maxLines: 1, softWrap: false),
            ],
          ),
        ),
      ],
    );
  }
}

