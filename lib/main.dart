import 'package:flutter/material.dart';
import 'package:pr_watch/my_home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade900,
          background: const Color(0xFF505050),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'PR Watch'),
    );
  }
}
