import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/providers/auth_provider.dart';
import 'package:tailoring_system/screens/auth/login_screen.dart';
import 'package:tailoring_system/screens/auth/onboarding_screen.dart';
import 'package:tailoring_system/screens/splash_screen.dart';
import 'package:tailoring_system/app/production_shell_screen.dart';

/// Routes user based on authentication state
class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show splash while checking auth state
        if (authProvider.user == null && authProvider.shopProfile == null) {
          return FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 500)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return const LoginScreen();
              }
              return const SplashScreen();
            },
          );
        }

        // User is authenticated
        if (authProvider.isAuthenticated) {
          // Check if shop onboarding is complete
          if (!authProvider.isSetupComplete) {
            return const OnboardingScreen();
          }

          // Go to main app
          return const ProductionShellScreen();
        }

        // Not authenticated - show login
        return const LoginScreen();
      },
    );
  }
}
