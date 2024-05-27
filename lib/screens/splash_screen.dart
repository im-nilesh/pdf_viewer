import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3C3C3C),
      body: Center(
        child: Image.asset(
          'assets/images/app_logo.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
