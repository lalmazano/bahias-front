import 'package:flutter/material.dart';

class ListSection extends StatelessWidget {
  final String title;
  final List<MapEntry<String, int>> entries;
  final Color iconColor;

  const ListSection({
    super.key,
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
