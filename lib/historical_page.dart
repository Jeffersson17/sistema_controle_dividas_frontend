// lib/historico_page.dart

import 'package:flutter/material.dart';

class HistoricalPage extends StatelessWidget {
  const HistoricalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Histórico',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.green[800],
      ),
      body: const Center(
        child: Text(
          'Página de Histórico',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
