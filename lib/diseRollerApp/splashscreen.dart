import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thinkcodes/screens/homescreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: controller,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1D5F5),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Center(
                  child: Text('🎲', style: TextStyle(fontSize: 90)),
                ),
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              'DICE BATTLE',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A4063),
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Roll the Dice, Win the Game!',
              style: TextStyle(fontSize: 16, color: Color(0xFF8E82A8)),
            ),

            const SizedBox(height: 50),

            const CircularProgressIndicator(color: Color(0xFFB39DDB)),
          ],
        ),
      ),
    );
  }
}
