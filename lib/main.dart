import 'package:flutter/material.dart';
import 'package:sistema_controle_dividas_frontend/pages/client_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mercadinho LEONE',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green[800],
          elevation: 4,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.italic,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18),
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      home: const ClientPage(),
    );
  }
}
