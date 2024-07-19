import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF274C77),
      body: Column(children: [
        const Expanded(
          child: Center(
            child: Text(
              "Cylinder",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 32),
            ),
          ),
        ),
        Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Text(
              "Powered by TrinityX",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ))
      ]),
    );
  }
}
