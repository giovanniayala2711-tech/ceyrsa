import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const CeyrsaApp());
}

class CeyrsaApp extends StatelessWidget {
  const CeyrsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CEYRSA',
      home: const LoginScreen(),
    );
  }
}