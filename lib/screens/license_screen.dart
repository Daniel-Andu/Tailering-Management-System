import 'package:flutter/material.dart';
import 'package:tailoring_system/utils/license_manager.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _licenseKeyController = TextEditingController();
  final _companyNameController = TextEditingController();
  bool _isLoading = false;
  String _licenseInfo = '';
  String _deviceId = '';

  @override
  void initState() {
    super.initState();
    _loadLicenseInfo();
    LicenseManager.initializeTrial();
    _loadDeviceId();
  }

  Future<void> _loadLicenseInfo() async {
    final info = await LicenseManager.getLicenseInfo();
    final companyName = await LicenseManager.getCompanyName();
    setState(() {
      _licenseInfo = info;
      _companyNameController.text = companyName ?? '';
    });
  }

  Future<void> _loadDeviceId() async {
    final deviceId = await LicenseManager.getDeviceId();
    setState(() {
      _deviceId = deviceId;
    });
  }

  Future<void> _activateLicense() async {
    final key = _licenseKeyController.text.trim();
    final companyName = _companyNameController.text.trim();

    if (key.isEmpty) {
      _showError('Please enter a license key');
      return;
    }

    if (companyName.isEmpty) {
      _showError('Please enter your company name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await LicenseManager.activateLicense(key, companyName);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      _showSuccess('License activated successfully!');
      await _loadLicenseInfo();
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      _showError('Invalid license key');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user,
                size: 80,
                color: Colors.blue[900],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.licenseActivate,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[900],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _licenseInfo,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your Device ID:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            // Copy device ID to clipboard
                          },
                          tooltip: 'Copy Device ID',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _deviceId,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share this Device ID with the app provider to get your license key',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'Enter your tailoring business name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _licenseKeyController,
                decoration: InputDecoration(
                  labelText: l10n.licenseEnterKey,
                  hintText: 'TAILOR-XXXX-XXXX-XXXX',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _activateLicense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          l10n.licenseActivateButton,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  final daysRemaining =
                      await LicenseManager.getTrialDaysRemaining();
                  if (daysRemaining > 0) {
                    Navigator.of(context).pushReplacementNamed('/home');
                  } else {
                    _showError(l10n.licenseTrialExpired);
                  }
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(
                  l10n.licenseContinueTrial,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue[900],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.licenseContact,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.licenseContactInfo,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _licenseKeyController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }
}
