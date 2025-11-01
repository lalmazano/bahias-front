import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/services.dart';

class BahiaCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool selected;
  final bool showLock;
  final VoidCallback onLongPress;
  final BahiasService service;

  const BahiaCard({
    super.key,
    required this.data,
    required this.selected,
    required this.showLock,
    required this.onLongPress,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final no = data['No_Bahia'] ?? 0;
    final estadoRef = data['EstadoRef'] as DocumentReference?;
    final tipoRef = data['TipoRef'] as DocumentReference?;
    final ubicacionRef = data['UbicacionRef'] as DocumentReference?;
    final estado = estadoRef?.id ?? 'Desconocido';
    final tipo = tipoRef?.id ?? 'Sin tipo';
    final ubicacion = ubicacionRef?.id ?? 'Sin ubicación';
    final estadoColor = service.estadoColor(estado);

    return GestureDetector(
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: selected
              ? Colors.greenAccent.withOpacity(0.1)
              : const Color(0xFF111511),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.greenAccent.withOpacity(0.8)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bahía $no',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent),
            ),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: estadoColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: estadoColor.withOpacity(0.45)),
              ),
              child: Text(
                estado,
                style: TextStyle(
                    color: estadoColor, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            Text("Tipo: $tipo",
                style:
                    const TextStyle(color: Colors.greenAccent, fontSize: 13)),
            Text("Ubicación: $ubicacion",
                style:
                    const TextStyle(color: Colors.orangeAccent, fontSize: 13)),
            if (showLock)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Icon(Icons.lock_outline,
                    size: 18, color: Colors.white38),
              ),
          ],
        ),
      ),
    );
  }
}
