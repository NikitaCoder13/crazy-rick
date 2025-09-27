import 'package:flutter/material.dart';

Widget buildInfoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
        ),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'Неизвестно',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
