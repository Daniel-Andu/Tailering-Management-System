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
        if (!authProvider.isAuthInitialized ||
            (authProvider.isLoading && authProvider.isShopProfileLoading)) {
          return const SplashScreen();
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        if (authProvider.shouldShowOnboarding) {
          return const OnboardingScreen();
        }

        return const ProductionShellScreen();
      },
    );
  }
}
