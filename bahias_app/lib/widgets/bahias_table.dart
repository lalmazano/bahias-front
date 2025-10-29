import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class BahiasTable extends StatelessWidget {
  final _firestore = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.getBahias(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;

        return SingleChildScrollView(
          child: DataTable(
            columns: const [
              DataColumn(label: Text('No_Bahia')),
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Reserva')),
            ],
            rows: docs
                .map((doc) => DataRow(cells: [
                      DataCell(Text('${doc['No_Bahia']}')),
                      DataCell(Text('${doc['Nombre']}')),
                      DataCell(Text('${doc['Reserva'] ?? '-'}')),
                    ]))
                .toList(),
          ),
        );
      },
    );
  }
}
