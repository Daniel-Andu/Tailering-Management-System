import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tailoring_system/app/production_shell_screen.dart';
import 'package:tailoring_system/utils/license_manager.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';
import 'package:tailoring_system/screens/pricing_screen.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _licenseKeyController = TextEditingController();
  final _companyNameController = TextEditingController();
  bool _isLoading = false;
  int _trialDaysRemaining = 30;
  bool _isLicensed = false;
  String _deviceId = '';
  String _companyName = '';

  @override
  void initState() {
    super.initState();
    LicenseManager.initializeTrial();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final daysRemaining = await LicenseManager.getTrialDaysRemaining();
    final deviceId = await LicenseManager.getDeviceId();
    final companyName = await LicenseManager.getCompanyName();
    final licensed = await LicenseManager.isLicensed();
    if (mounted) {
      setState(() {
        _trialDaysRemaining = daysRemaining;
        _deviceId = deviceId;
        _companyName = companyName ?? '';
        _isLicensed = licensed;
        _companyNameController.text = companyName ?? '';
      });
    }
  }

  Future<void> _activateLicense() async {
    final l10n = AppLocalizations.of(context)!;
    final key = _licenseKeyController.text.trim();
    final companyName = _companyNameController.text.trim();

    if (key.isEmpty) {
      _showSnack(l10n.licenseEnterKey, isError: true);
      return;
    }
    if (companyName.isEmpty) {
      _showSnack(l10n.licenseCompanyNameHint, isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final success = await LicenseManager.activateLicense(key, companyName);
    setState(() => _isLoading = false);

    if (success) {
      _showSnack(l10n.licenseActivationSuccess);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ProductionShellScreen()),
      );
    } else {
      _showSnack(l10n.licenseInvalidKey, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
              theme.colorScheme.tertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 16),

                  // ── Logo ─────────────────────────────────────────────────
                  Center(
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.4), width: 2),
                      ),
                      child: const Icon(Icons.checkroom,
                          size: 48, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      l10n.appTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      l10n.appSubtitle,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Trial / License Status ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isLicensed
                              ? Icons.verified_user
                              : (_trialDaysRemaining > 5
                                  ? Icons.timer
                                  : Icons.warning_amber_rounded),
                          color: _isLicensed
                              ? Colors.greenAccent
                              : (_trialDaysRemaining > 5
                                  ? Colors.white
                                  : Colors.orangeAccent),
                          size: 36,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isLicensed
                                    ? l10n.licenseFullLicense
                                    : '${l10n.licenseTrialVersion} — $_trialDaysRemaining ${l10n.licenseDaysRemaining}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              if (_companyName.isNotEmpty)
                                Text(
                                  _companyName,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.75),
                                      fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── White Card ────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.licenseActivate,
                          style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.licenseShareDeviceId,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500),
                        ),

                        const SizedBox(height: 20),

                        // Device ID box
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: theme.colorScheme.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.phone_android,
                                  size: 16, color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SelectableText(
                                  _deviceId,
                                  style: const TextStyle(
                                      fontSize: 11, fontFamily: 'monospace'),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 16),
                                tooltip: l10n.licenseCopyDeviceId,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () async {
                                  await Clipboard.setData(
                                      ClipboardData(text: _deviceId));
                                  if (!mounted) return;
                                  _showSnack(l10n.licenseDeviceIdCopied);
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _companyNameController,
                          decoration: InputDecoration(
                            labelText: l10n.licenseCompanyName,
                            hintText: l10n.licenseCompanyNameHint,
                            prefixIcon: const Icon(Icons.business),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextField(
                          controller: _licenseKeyController,
                          decoration: InputDecoration(
                            labelText: l10n.licenseEnterKey,
                            hintText: 'TAILOR-XXXX-XXXX-XXXX',
                            prefixIcon: const Icon(Icons.vpn_key),
                          ),
                          textCapitalization: TextCapitalization.characters,
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: _isLoading ? null : _activateLicense,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.verified_user),
                            label: Text(l10n.licenseActivateButton,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              if (_trialDaysRemaining > 0) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ProductionShellScreen()),
                                );
                              } else {
                                _showSnack(
                                    AppLocalizations.of(context)!
                                        .licenseTrialExpired,
                                    isError: true);
                              }
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: Text(l10n.licenseContinueTrial),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── View Plans Button ─────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PricingScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.storefront),
                            label: Text(l10n.pricingTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.08),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Contact ───────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          l10n.businessContactTitle,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.businessPhone,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13)),
                        Text(l10n.businessEmail,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13)),
                        Text(l10n.businessTelegram,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13)),
                        Text(l10n.businessTelebirr,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13)),
                        Text(l10n.businessCbeBirr,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
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
