import 'package:flutter/material.dart';
import 'package:pdf_viewer/screens/username_Screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    //navigate to userscreen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UsernameScreen(),
        ),
      );
    });
  }

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
