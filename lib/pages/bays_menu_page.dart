import 'package:flutter/material.dart';
import '../models/bay.dart';
import 'bay_detail_page.dart';

class BaysMenuPage extends StatelessWidget {
  static const routeName = '/bays';
  const BaysMenuPage({super.key});

  Color _colorPorEstado(BayStatus s, BuildContext ctx) {
    final cs = Theme.of(ctx).colorScheme;
    switch (s) {
      case BayStatus.libre: return Colors.green.shade400;
      case BayStatus.ocupada: return cs.primary; // rosa del tema
      case BayStatus.mantenimiento: return Colors.orange.shade600;
    }
  }

  String _textoEstado(BayStatus s) {
    switch (s) {
      case BayStatus.libre: return 'Libre';
      case BayStatus.ocupada: return 'Ocupada';
      case BayStatus.mantenimiento: return 'Mantenimiento';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo; aquí luego conectas a tu API/BD
    final bays = <Bay>[
      Bay(id: 'B1', nombre: 'Bahía 1', estado: BayStatus.libre, puestos: 3),
      Bay(id: 'B2', nombre: 'Bahía 2', estado: BayStatus.ocupada, puestos: 2),
      Bay(id: 'B3', nombre: 'Bahía 3', estado: BayStatus.mantenimiento, puestos: 4),
      Bay(id: 'B4', nombre: 'Bahía 4', estado: BayStatus.libre, puestos: 1),
      Bay(id: 'B5', nombre: 'Bahía 5', estado: BayStatus.ocupada, puestos: 5),
      Bay(id: 'B6', nombre: 'Bahía 6', estado: BayStatus.libre, puestos: 2),
      Bay(id: 'B7', nombre: 'Bahía 7', estado: BayStatus.mantenimiento, puestos: 3),
      Bay(id: 'B8', nombre: 'Bahía 8', estado: BayStatus.ocupada, puestos: 4),
      Bay(id: 'B9', nombre: 'Bahía 9', estado: BayStatus.libre, puestos: 2),
      Bay(id: 'B10', nombre: 'Bahía 10', estado: BayStatus.ocupada, puestos: 1),
      Bay(id: 'B11', nombre: 'Bahía 11', estado: BayStatus.mantenimiento, puestos: 3),
      Bay(id: 'B12', nombre: 'Bahía 12', estado: BayStatus.libre, puestos: 4),
      Bay(id: 'B13', nombre: 'Bahía 13', estado: BayStatus.ocupada, puestos: 2),
      Bay(id: 'B14', nombre: 'Bahía 14', estado: BayStatus.libre, puestos: 5),
      Bay(id: 'B15', nombre: 'Bahía 15', estado: BayStatus.mantenimiento, puestos: 1),
      
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Bahías')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: bays.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 por fila; ajusta según pantalla
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemBuilder: (context, i) {
            final b = bays[i];
            final chipColor = _colorPorEstado(b.estado, context);
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BayDetailPage(bay: b)),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: chipColor.withOpacity(0.15),
                            child: Icon(Icons.directions_car, color: chipColor),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b.nombre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: chipColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: chipColor),
                            ),
                            child: Text(
                              _textoEstado(b.estado),
                              style: TextStyle(
                                color: chipColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('Puestos',
                                  style: TextStyle(color: Colors.black54, fontSize: 12)),
                              Text('${b.puestos}',
                                  style: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
