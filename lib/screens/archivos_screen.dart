import 'package:flutter/material.dart';

class ArchivosScreen extends StatelessWidget {
  const ArchivosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'ARCHIVOS',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}