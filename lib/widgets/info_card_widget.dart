import 'package:flutter/material.dart';

Widget buildInfoCard(String title, List<Widget> children) {
  return Card(
    elevation: 3,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    ),
  );
}
