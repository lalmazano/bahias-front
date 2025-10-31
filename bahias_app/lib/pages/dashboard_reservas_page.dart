import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HistorialReservas(),
              SizedBox(height: 25),
              _ReservasPorUsuario(),
              SizedBox(height: 25),
              _ReservasPorUbicacion(),
            ],
          ),
        ),
      ),
    );
  }
}

//
// 🕓 HISTORIAL DE RESERVAS RECIENTES
//
class _HistorialReservas extends StatelessWidget {
  const _HistorialReservas();

  @override
  Widget build(BuildContext context) {
    final reservas = FirebaseFirestore.instance
        .collection('Reservas')
        .orderBy('FechaInicio', descending: true)
        .limit(10)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: reservas,
      builder: (context, snap) {
        if (snap.hasError) {
          return const Text("Error al cargar reservas recientes.",
              style: TextStyle(color: Colors.redAccent));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Text("No hay reservas recientes.",
              style: TextStyle(color: Colors.white54));
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📜 Historial de reservas recientes",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 500),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final inicio = (data['FechaInicio'] as Timestamp?)?.toDate();
                    final fin = (data['FechaFin'] as Timestamp?)?.toDate();
                    final estado =
                        (data['EstadoReservaRef'] as DocumentReference?)?.id ??
                            '-';
                    final bahias = (data['BahiasRefs'] as List?)
                            ?.whereType<DocumentReference>()
                            .map((b) => b.id)
                            .join(', ') ??
                        '-';
                    final userRef = data['UsuarioRef'];

                    return FutureBuilder<DocumentSnapshot>(
                      future: (userRef is DocumentReference)
                          ? userRef.get()
                          : Future.value(null),
                      builder: (context, userSnap) {
                        String usuario = 'Desconocido';
                        if (userSnap.hasData && userSnap.data != null) {
                          final udata =
                              userSnap.data!.data() as Map<String, dynamic>?;
                          usuario = udata?['nombre'] ?? 'Desconocido';
                        }

                        return ListTile(
                          leading: const Icon(Icons.history_rounded,
                              color: Colors.cyanAccent, size: 30),
                          title: Text('Bahías: $bahias',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16)),
                          subtitle: Text(
                            [
                              if (inicio != null && fin != null)
                                'Inicio: ${DateFormat('dd/MM HH:mm').format(inicio)} → Fin: ${DateFormat('HH:mm').format(fin)}',
                              'Usuario: $usuario',
                              'Estado: $estado',
                            ].join('\n'),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                        );
                      },
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
}

//
// 👤 RESERVAS POR USUARIO / OPERADOR
//
class _ReservasPorUsuario extends StatelessWidget {
  const _ReservasPorUsuario();

  @override
  Widget build(BuildContext context) {
    final reservas =
        FirebaseFirestore.instance.collection('Reservas').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: reservas,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = <String, int>{};
        for (final doc in snap.data!.docs) {
          final d = doc.data() as Map<String, dynamic>;
          final userRef = d['UsuarioRef'];
          if (userRef is DocumentReference) {
            final id = userRef.id;
            data[id] = (data[id] ?? 0) + 1;
          }
        }

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('Usuarios').get(),
          builder: (context, usersSnap) {
            if (!usersSnap.hasData) {
              return const SizedBox.shrink();
            }

            final nombres = {
              for (var u in usersSnap.data!.docs)
                u.id: (u.data() as Map<String, dynamic>)['nombre'] ?? 'Desconocido',
            };

            final entries = data.entries
                .map((e) =>
                    MapEntry<String, int>(nombres[e.key] ?? e.key, e.value))
                .toList();

            return _ListSection(
              title: "👤 Reservas por usuario / operador",
              iconColor: Colors.orangeAccent,
              entries: entries,
            );
          },
        );
      },
    );
  }
}

//
// 🧭 RESERVAS POR UBICACIÓN / ZONA
//
class _ReservasPorUbicacion extends StatefulWidget {
  const _ReservasPorUbicacion({super.key});

  @override
  State<_ReservasPorUbicacion> createState() => _ReservasPorUbicacionState();
}

class _ReservasPorUbicacionState extends State<_ReservasPorUbicacion> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, int> ubicaciones = {};
  Map<String, String> nombresUbicaciones = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final reservas = await _firestore.collection('Reservas').get();
      final Map<String, int> conteo = {};

      for (var r in reservas.docs) {
        final data = r.data();
        final bahias = (data['BahiasRefs'] ?? []) as List;

        for (final ref in bahias) {
          if (ref is DocumentReference) {
            final bahiaDoc = await ref.get();
            final bahiaData = bahiaDoc.data() as Map<String, dynamic>?;

            if (bahiaData != null && bahiaData.containsKey('UbicacionRef')) {
              final ubicRef = bahiaData['UbicacionRef'];
              if (ubicRef is DocumentReference) {
                final idUbic = ubicRef.id;
                conteo[idUbic] = (conteo[idUbic] ?? 0) + 1;
              }
            }
          }
        }
      }

      final ubicDocs = await _firestore.collection('Ubicacion').get();
      final Map<String, String> nombres = {
        for (var doc in ubicDocs.docs)
          doc.id: (doc.data())['Nombre'] ?? doc.id,
      };

      setState(() {
        ubicaciones = conteo;
        nombresUbicaciones = nombres;
      });
    } catch (e) {
      debugPrint('Error cargando ubicaciones: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ubicaciones.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ListSection(
          title: "🌍 Reservas por ubicación / zona",
          iconColor: Colors.lightBlueAccent,
          entries: entries
              .map((e) => MapEntry(nombresUbicaciones[e.key] ?? e.key, e.value))
              .toList(),
        ),
        if (entries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: _UbicacionChart(
              data: entries
                  .map((e) => MapEntry(
                        nombresUbicaciones[e.key] ?? e.key,
                        e.value,
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

//
// 📋 LISTA REUTILIZABLE
//
class _ListSection extends StatelessWidget {
  final String title;
  final List<MapEntry<String, int>> entries;
  final Color iconColor;

  const _ListSection({
    required this.title,
    required this.entries,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Text("No hay datos en $title",
            style: const TextStyle(color: Colors.white54)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          const SizedBox(height: 10),
          ...entries.map((e) => ListTile(
                leading: Icon(Icons.label_important, color: iconColor),
                title: Text(e.key,
                    style:
                        const TextStyle(color: Colors.white, fontSize: 16)),
                trailing: Text('${e.value}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 15)),
              )),
        ],
      ),
    );
  }
}

//
// 🍩 GRÁFICO DE DISTRIBUCIÓN POR UBICACIÓN
//
class _UbicacionChart extends StatelessWidget {
  final List<MapEntry<String, int>> data;
  const _UbicacionChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.fold<int>(0, (sum, e) => sum + e.value);

    return Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Text(
                '📊 Distribución de reservas por ubicación',
                style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            AspectRatio(
              aspectRatio: 1.2,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  borderData: FlBorderData(show: false),
                  sections: data.map((e) {
                    final pct = total > 0 ? (e.value / total) * 100 : 0;
                    final color = Colors.primaries[
                        data.indexOf(e) % Colors.primaries.length];
                    return PieChartSectionData(
                      value: e.value.toDouble(),
                      color: color,
                      radius: 85,
                      title: '${e.key}\n${pct.toStringAsFixed(1)}%',
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
