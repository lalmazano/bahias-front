import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomeSummaryPage extends StatefulWidget {
  const HomeSummaryPage({super.key});

  @override
  State<HomeSummaryPage> createState() => _HomeSummaryPageState();
}

class _HomeSummaryPageState extends State<HomeSummaryPage> {
  late Future<Map<String, String>> _estadoMapFuture;

  @override
  void initState() {
    super.initState();
    _estadoMapFuture = _loadEstados();
  }

  Future<Map<String, String>> _loadEstados() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('Tipo_Estado').get();
    final map = <String, String>{};
    for (var doc in snapshot.docs) {
      map['Tipo_Estado/${doc.id}'] = doc.id.toLowerCase();
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance.collection('Bahias').snapshots();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return FutureBuilder<Map<String, String>>(
      future: _estadoMapFuture,
      builder: (context, estadoSnap) {
        if (!estadoSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final estadoMap = estadoSnap.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error al cargar los datos',
                    style: TextStyle(color: Colors.redAccent)),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final total = docs.length;

            int libres = 0, ocupadas = 0, reservadas = 0, mantenimiento = 0;

            for (final d in docs) {
              final data = d.data() as Map<String, dynamic>;
              dynamic ref = data['EstadoRef'];
              String estado = 'libre';

              if (ref is DocumentReference) {
                estado = estadoMap[ref.path] ?? 'libre';
              } else if (ref is String) {
                for (final key in estadoMap.keys) {
                  if (ref.toLowerCase().contains(key.toLowerCase())) {
                    estado = estadoMap[key]!;
                    break;
                  }
                }
              }

              switch (estado) {
                case 'mantenimiento':
                  mantenimiento++;
                  break;
                case 'ocupado':
                  ocupadas++;
                  break;
                case 'reservado':
                  reservadas++;
                  break;
                default:
                  libres++;
              }
            }

            final usoTotal = ocupadas + reservadas;
            final usoPct =
                total > 0 ? ((usoTotal / total) * 100).toStringAsFixed(1) : '0.0';
            final now = DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.now());

            // 🔹 Color dinámico según ocupación
            Color barraColor;
            final uso = double.tryParse(usoPct) ?? 0;
            if (uso < 40) {
              barraColor = Colors.greenAccent;
            } else if (uso < 70) {
              barraColor = Colors.amberAccent;
            } else {
              barraColor = Colors.redAccent;
            }

            return Scaffold(
              backgroundColor: theme.scaffoldBackgroundColor,
              body: Scrollbar(
                thumbVisibility: true,
                radius: const Radius.circular(10),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // =============================
                    // 🔹 BARRA GLOBAL DE OCUPACIÓN
                    // =============================
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.blueGrey[900] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.analytics_outlined,
                                  color: barraColor, size: 28),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Ocupación general: $usoPct%',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM HH:mm')
                                    .format(DateTime.now()),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: double.tryParse(usoPct)! / 100,
                              color: barraColor,
                              backgroundColor: theme.colorScheme.onSurface
                                  .withOpacity(0.1),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // =============================
                    // 🔹 TARJETAS DE ESTADO DE BAHÍAS
                    // =============================
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double width = constraints.maxWidth;
                        int crossCount = width > 1200
                            ? 4
                            : width > 900
                                ? 3
                                : width > 600
                                    ? 2
                                    : 1;
                        double cardWidth = (width / crossCount) - 20;

                        return Wrap(
                          spacing: 20,
                          runSpacing: 20,
                          children: [
                            _StatusCard(
                              theme: theme,
                              width: cardWidth,
                              title: 'Libres',
                              value: libres.toString(),
                              color: const Color(0xFF43A047),
                              icon: Icons.check_circle_outline,
                              subtitle:
                                  '${_calcPct(libres, total)}% disponibles',
                            ),
                            _StatusCard(
                              theme: theme,
                              width: cardWidth,
                              title: 'Ocupadas',
                              value: ocupadas.toString(),
                              color: const Color(0xFFFFC107),
                              icon: Icons.lock_outline,
                              subtitle:
                                  '${_calcPct(ocupadas, total)}% en uso',
                            ),
                            _StatusCard(
                              theme: theme,
                              width: cardWidth,
                              title: 'Reservadas',
                              value: reservadas.toString(),
                              color: const Color(0xFF00B0FF),
                              icon: Icons.timer_outlined,
                              subtitle:
                                  '${_calcPct(reservadas, total)}% pendientes',
                            ),
                            _StatusCard(
                              theme: theme,
                              width: cardWidth,
                              title: 'Mantenimiento',
                              value: mantenimiento.toString(),
                              color: const Color(0xFF26A69A),
                              icon: Icons.build_circle_outlined,
                              subtitle:
                                  '${_calcPct(mantenimiento, total)}% fuera de servicio',
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // =============================
                    // 🔹 INDICADORES DE RESERVAS
                    // =============================
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Reservas')
                          .snapshots(),
                      builder: (context, resSnap) {
                        if (resSnap.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!resSnap.hasData ||
                            resSnap.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No hay reservas registradas.',
                              style: TextStyle(color: Colors.white70),
                            ),
                          );
                        }

                        final reservas = resSnap.data!.docs
                            .map((e) => e.data() as Map<String, dynamic>)
                            .toList();

                        // 🕒 Tiempo promedio de ocupación
                        final duraciones = reservas.map((r) {
                          final inicio =
                              (r['FechaInicio'] as Timestamp).toDate();
                          final fin =
                              (r['FechaFin'] as Timestamp).toDate();
                          return fin.difference(inicio).inMinutes;
                        }).toList();
                        final promedio = duraciones.isEmpty
                            ? 0
                            : duraciones.reduce((a, b) => a + b) /
                                duraciones.length;

                        // ⏳ Próximas a liberarse
                        final proximas = reservas.where((r) {
                          final fin =
                              (r['FechaFin'] as Timestamp).toDate();
                          return fin.isAfter(DateTime.now()) &&
                              fin.isBefore(DateTime.now()
                                  .add(const Duration(minutes: 10)));
                        }).length;

                        // 📅 Activas hoy
                        final hoy = DateTime.now();
                        final activasHoy = reservas.where((r) {
                          final inicio =
                              (r['FechaInicio'] as Timestamp).toDate();
                          final fin =
                              (r['FechaFin'] as Timestamp).toDate();
                          return hoy.isAfter(inicio) && hoy.isBefore(fin);
                        }).length;

                        double width = MediaQuery.of(context).size.width;
                        int crossCount = width > 1200
                            ? 3
                            : width > 800
                                ? 2
                                : 1;
                        double cardWidth = (width / crossCount) - 20;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12, left: 8),
                              child: Text(
                                'Indicadores de Reservas',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: [
                                _StatusCard(
                                  theme: theme,
                                  width: cardWidth,
                                  title: 'Tiempo promedio de ocupación',
                                  value:
                                      '${promedio.toStringAsFixed(1)} min',
                                  color: Colors.tealAccent.shade700,
                                  icon: Icons.schedule,
                                  subtitle: 'Duración media por bahía',
                                ),
                                _StatusCard(
                                  theme: theme,
                                  width: cardWidth,
                                  title: 'Bahías próximas a liberarse',
                                  value: proximas.toString(),
                                  color: Colors.deepOrangeAccent,
                                  icon: Icons.access_time,
                                  subtitle:
                                      'Finalizan en menos de 10 min',
                                ),
                                _StatusCard(
                                  theme: theme,
                                  width: cardWidth,
                                  title: 'Reservas activas hoy',
                                  value: activasHoy.toString(),
                                  color: Colors.indigoAccent,
                                  icon: Icons.today_outlined,
                                  subtitle:
                                      'Reservas vigentes durante el día',
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Footer
                    Center(
                      child: Text(
                        'Actualizado: $now',
                        style: TextStyle(
                          color:
                              theme.colorScheme.onBackground.withOpacity(0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _calcPct(int parte, int total) =>
      total > 0 ? ((parte / total) * 100).toStringAsFixed(1) : '0.0';
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final ThemeData theme;
  final double width;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.theme,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? color.withOpacity(0.2) : color.withOpacity(0.08);

    return Tooltip(
      message: '$title → $subtitle',
      waitDuration: const Duration(milliseconds: 500),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground
                              .withOpacity(0.7))),
                  const SizedBox(height: 6),
                  Text(value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground)),
                  const SizedBox(height: 6),
                  Text(subtitle,
                      style: TextStyle(
                          color: color.withOpacity(0.9), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),  
    );
  }
}
