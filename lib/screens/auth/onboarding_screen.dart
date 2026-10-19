import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/providers/auth_provider.dart';
import 'package:tailoring_system/models/shop_profile.dart';

/// Shop onboarding - collect additional business details
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  String _selectedBusinessType = 'tailor';
  String _selectedCurrency = 'ETB';

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final currentProfile = authProvider.shopProfile!;

    final updatedProfile = currentProfile.copyWith(
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      country: 'Ethiopia',
      businessType: _selectedBusinessType,
      currency: _selectedCurrency,
      language: 'en',
    );

    try {
      await authProvider.completeOnboarding(updatedProfile);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final shopProfile = authProvider.shopProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Your Shop'),
        actions: [
          TextButton(
            onPressed: () => authProvider.signOut(),
            child: const Text('Logout'),
          ),
        ],
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep++);
          } else {
            _completeOnboarding();
          }
        },
        onStepCancel: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
        steps: [
          // Step 1: Welcome
          Step(
            title: const Text('Welcome'),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${shopProfile?.ownerName ?? 'Tailor'}!',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'Shop: ${shopProfile?.shopName ?? ''}',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Let\'s complete your shop profile to get started.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Step 2: Business Details
          Step(
            title: const Text('Business Details'),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            content: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedBusinessType,
                    decoration: InputDecoration(
                      labelText: 'Business Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'tailor', child: Text('Tailor Shop')),
                      DropdownMenuItem(value: 'alteration', child: Text('Alteration Services')),
                      DropdownMenuItem(value: 'custom_design', child: Text('Custom Design')),
                    ],
                    onChanged: (v) => setState(() => _selectedBusinessType = v!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Shop Address',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Step 3: Preferences
          Step(
            title: const Text('Preferences'),
            isActive: _currentStep >= 2,
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  decoration: InputDecoration(
                    labelText: 'Currency',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ETB', child: Text('Ethiopian Birr (ETB)')),
                    DropdownMenuItem(value: 'USD', child: Text('US Dollar (USD)')),
                    DropdownMenuItem(value: 'EUR', child: Text('Euro (EUR)')),
                  ],
                  onChanged: (v) => setState(() => _selectedCurrency = v!),
                ),
                const SizedBox(height: 32),
                const Text(
                  'You\'re all set! Click Continue to start managing your tailoring business.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
