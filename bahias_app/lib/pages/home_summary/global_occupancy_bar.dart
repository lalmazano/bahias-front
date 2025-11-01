import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GlobalOccupancyBar extends StatelessWidget {
  final String usoPct;

  const GlobalOccupancyBar({super.key, required this.usoPct});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final uso = double.tryParse(usoPct) ?? 0;

    Color barraColor;
    if (uso < 40) {
      barraColor = Colors.greenAccent;
    } else if (uso < 70) {
      barraColor = Colors.amberAccent;
    } else {
      barraColor = Colors.redAccent;
    }

    return AnimatedContainer(
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
              Icon(Icons.analytics_outlined, color: barraColor, size: 28),
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
                DateFormat('dd/MM HH:mm').format(DateTime.now()),
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: uso / 100,
              color: barraColor,
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
