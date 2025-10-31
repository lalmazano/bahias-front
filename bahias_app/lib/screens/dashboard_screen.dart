import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeSummaryPage extends StatelessWidget {
  const HomeSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance.collection('Bahias').snapshots();
    final now = DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.now());

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Center(
            child: Text('Error al cargar los datos',
                style: TextStyle(color: Colors.redAccent)),
          );
        }

        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs =
            snap.data!.docs.map((e) => e.data() as Map<String, dynamic>).toList();
        final total = docs.length;

        int libres = 0, ocupadas = 0, mantenimiento = 0;
        for (final d in docs) {
          final estado = (d['Reserva'] ?? 'Libre').toString().toLowerCase();
          if (estado.contains('manten')) {
            mantenimiento++;
          } else if (estado.contains('ocup')) {
            ocupadas++;
          } else {
            libres++;
          }
        }

        final libresPct = total > 0 ? (libres / total * 100).toStringAsFixed(1) : '0';
        final ocupadasPct = total > 0 ? (ocupadas / total * 100).toStringAsFixed(1) : '0';
        final mantPct = total > 0 ? (mantenimiento / total * 100).toStringAsFixed(1) : '0';

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧭 Header con resumen global
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resumen General de Bahías',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Actualizado: $now',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 🥧 Gráfico circular con totales
              if (total > 0)
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 50,
                      sections: [
                        _pieSection(double.parse(libresPct), Colors.greenAccent, 'Libres'),
                        _pieSection(double.parse(ocupadasPct), Colors.amberAccent, 'Ocupadas'),
                        _pieSection(double.parse(mantPct), Colors.tealAccent, 'Mantenimiento'),
                      ],
                    ),
                  ),
                )
              else
                const Center(
                  child: Text('No hay bahías registradas',
                      style: TextStyle(color: Colors.white70)),
                ),
              const SizedBox(height: 30),

              // 🧱 Tarjetas
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final cross = width >= 1400
                        ? 4
                        : width >= 1000
                            ? 3
                            : width >= 650
                                ? 2
                                : 1;

                    return GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 2.5,
                      ),
                      children: [
                        _SummaryCard(
                          title: 'Bahías Totales',
                          value: total.toString(),
                          color: const Color(0xFF1E88E5),
                          icon: Icons.dashboard_customize_rounded,
                          subtitle: 'Total registradas',
                          percent: 100,
                        ),
                        _SummaryCard(
                          title: 'Libres',
                          value: libres.toString(),
                          color: Colors.greenAccent,
                          icon: Icons.check_circle_outline,
                          subtitle: '$libresPct% disponibles',
                          percent: double.tryParse(libresPct) ?? 0,
                        ),
                        _SummaryCard(
                          title: 'Ocupadas',
                          value: ocupadas.toString(),
                          color: Colors.amberAccent,
                          icon: Icons.lock_outline,
                          subtitle: '$ocupadasPct% en uso',
                          percent: double.tryParse(ocupadasPct) ?? 0,
                        ),
                        _SummaryCard(
                          title: 'Mantenimiento',
                          value: mantenimiento.toString(),
                          color: Colors.tealAccent,
                          icon: Icons.build_outlined,
                          subtitle: '$mantPct% fuera de servicio',
                          percent: double.tryParse(mantPct) ?? 0,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  PieChartSectionData _pieSection(double value, Color color, String title) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: '$title\n${value.toStringAsFixed(1)}%',
      radius: 65,
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}

/// 🌈 Tarjeta con gradiente dinámico + hover + animación
class _SummaryCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final double percent;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
    required this.subtitle,
    required this.percent,
//    super.key,
  });

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        transform: Matrix4.identity()..scale(_hover ? 1.03 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color.withOpacity(_hover ? 0.4 : 0.25),
              Colors.black.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_hover ? 0.6 : 0.3),
              blurRadius: _hover ? 20 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: widget.color,
                content: Text('${widget.title}: ${widget.value} (${widget.subtitle})'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 34),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(widget.value,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: widget.percent / 100,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        color: widget.color,
                        minHeight: 6,
                      ),
                      const SizedBox(height: 6),
                      Text(widget.subtitle,
                          style: TextStyle(
                              color: widget.color.withOpacity(0.9),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
