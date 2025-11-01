import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/services.dart';
import 'home_summary/widgets.dart';

class HomeSummaryPage extends StatefulWidget {
  const HomeSummaryPage({super.key});

  @override
  State<HomeSummaryPage> createState() => _HomeSummaryPageState();
}

class _HomeSummaryPageState extends State<HomeSummaryPage> {
  final _bahiaService = BahiaService();
  late Future<Map<String, String>> _estadoMapFuture;


  @override
  void initState() {
    super.initState();
    _estadoMapFuture = _bahiaService.loadEstados();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<Map<String, String>>(
      future: _estadoMapFuture,
      builder: (context, estadoSnap) {
        if (!estadoSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final estadoMap = estadoSnap.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: _bahiaService.getBahiasStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data!.docs;
            final total = docs.length;

            return FutureBuilder<Map<String, int>>(
              future: _bahiaService.calcularEstados(docs, estadoMap),
              builder: (context, resumenSnap) {
                if (!resumenSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final resumen = resumenSnap.data!;
                final libres = resumen['libres']!;
                final ocupadas = resumen['ocupadas']!;
                final reservadas = resumen['reservadas']!;
                final mantenimiento = resumen['mantenimiento']!;

                final usoTotal = ocupadas + reservadas;
                final usoPct = total > 0
                    ? ((usoTotal / total) * 100).toStringAsFixed(1)
                    : '0.0';

                return Scaffold(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  body: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      GlobalOccupancyBar(usoPct: usoPct),
                      const SizedBox(height: 25),

                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          StatusCard(
                            title: 'Libres',
                            value: libres.toString(),
                            subtitle:
                                '${_calcPct(libres, total)}% disponibles',
                            color: const Color(0xFF43A047),
                            icon: Icons.check_circle_outline,
                          ),
                          StatusCard(
                            title: 'Ocupadas',
                            value: ocupadas.toString(),
                            subtitle:
                                '${_calcPct(ocupadas, total)}% en uso',
                            color: const Color(0xFFFFC107),
                            icon: Icons.lock_outline,
                          ),
                          StatusCard(
                            title: 'Reservadas',
                            value: reservadas.toString(),
                            subtitle:
                                '${_calcPct(reservadas, total)}% pendientes',
                            color: const Color(0xFF00B0FF),
                            icon: Icons.timer_outlined,
                          ),
                          StatusCard(
                            title: 'Mantenimiento',
                            value: mantenimiento.toString(),
                            subtitle:
                                '${_calcPct(mantenimiento, total)}% fuera de servicio',
                            color: const Color(0xFF26A69A),
                            icon: Icons.build_circle_outlined,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      const ReservaIndicators(),
                      
                      const SizedBox(height: 10),
                         // FOOTER DE ACTUALIZACIÓN
                      Center(
                        child: Text(
                          'Actualizado: ${DateFormat("dd/MM/yyyy – HH:mm").format(DateTime.now())}',
                          style: TextStyle(
                            color: theme.colorScheme.onBackground.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  )
                );
              },
            );
          },
        );
      },
    );
  }

  String _calcPct(int parte, int total) =>
      total > 0 ? ((parte / total) * 100).toStringAsFixed(1) : '0.0';
}
