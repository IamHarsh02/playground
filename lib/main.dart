import 'package:flutter/material.dart';
import 'screens/portfolio_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Harsh Patare - Portfolio',
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF4F46E5),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        cardColor: const Color(0xFF374151),
      ),
      home: const PortfolioScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
