import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/providers/auth_provider.dart';
import 'package:tailoring_system/models/shop_profile.dart';
import 'package:tailoring_system/app/production_shell_screen.dart';

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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please fill in Address and City'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final currentProfile = authProvider.shopProfile;
    
    if (currentProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Error: Shop profile not found. Please register again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Setting up your shop...'),
              ],
            ),
          ),
        ),
      ),
    );

    final updatedProfile = currentProfile.copyWith(
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      country: 'Ethiopia',
      businessType: _selectedBusinessType,
      currency: _selectedCurrency,
      language: 'en',
      updatedAt: DateTime.now(),
    );

    try {
      print('🔄 Completing onboarding...');
      print('📝 Shop: ${updatedProfile.shopName}');
      print('📝 City: ${updatedProfile.city}');
      
      await authProvider.completeOnboarding(updatedProfile);
      print('✅ Onboarding completed successfully');
      
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Shop setup complete! Welcome!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navigate to main app
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ProductionShellScreen()),
        (route) => false,
      );
      
    } catch (e) {
      print('❌ Onboarding error: $e');
      
      if (!mounted) return;
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show detailed error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text('Setup Failed'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Failed to complete shop setup:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  e.toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please check:\n• Internet connection\n• Firebase configuration',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      
      debugPrint('❌ Onboarding error details: $e');
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
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
                      ),
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
                      hintText: 'Enter your shop address',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      hintText: 'Enter your city',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'City is required' : null,
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
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ETB', child: Text('Ethiopian Birr (ETB)')),
                    DropdownMenuItem(value: 'USD', child: Text('US Dollar (USD)')),
                    DropdownMenuItem(value: 'EUR', child: Text('Euro (EUR)')),
                  ],
                  onChanged: (v) => setState(() => _selectedCurrency = v!),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.green.withOpacity(0.15)
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.green.withOpacity(0.3)
                          : Colors.green.shade200,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You\'re all set! Click Continue to start managing your tailoring business.',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
