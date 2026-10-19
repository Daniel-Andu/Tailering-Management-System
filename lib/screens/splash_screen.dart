import 'package:flutter/material.dart';

/// Minimal splash screen that matches the native Android splash
/// This ensures seamless transition from native to Flutter
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000000), // Black background to match native splash
      body: Center(
        child: SizedBox.shrink(), // No content - native splash handles the UI
      ),
    );
  }
}
