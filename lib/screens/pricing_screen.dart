import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';
import 'package:tailoring_system/utils/license_manager.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  String _deviceId = '';
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final id = await LicenseManager.getDeviceId();
    if (mounted) setState(() => _deviceId = id);
  }

  Future<void> _copyDeviceId() async {
    await Clipboard.setData(ClipboardData(text: _deviceId));
    if (!mounted) return;
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Device ID copied! Now send it to our Telegram.'),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) setState(() => _copied = false);
  }

  void _openTelegram(BuildContext context) {
    // On mobile this would open Telegram app
    // For now we show the Telegram link
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.send, color: Color(0xFF8B5CF6)),
            SizedBox(width: 8),
            Text('Contact on Telegram'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send us:'),
            const SizedBox(height: 8),
            _InfoTile(icon: Icons.phone_android, text: 'Your Device ID'),
            _InfoTile(icon: Icons.receipt_long, text: 'Payment screenshot'),
            _InfoTile(icon: Icons.business, text: 'Your shop name'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.telegram, color: Color(0xFF0088CC), size: 20),
                  SizedBox(width: 8),
                  Text(
                    't.me/TailorSystemET',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0088CC),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pricingTitle),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.storefront, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text(
                  'Tailoring System License',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'One-time yearly payment — no subscription tricks',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Plans ────────────────────────────────────────────────────────
          _PlanCard(
            name: l10n.pricingBasic,
            price: l10n.pricingBasicPrice,
            description: l10n.pricingBasicDesc,
            features: const [
              '✅ Customer management',
              '✅ Order tracking',
              '✅ Dashboard',
              '✅ Basic reports',
              '✅ Amharic + English',
              '❌ Staff management',
              '❌ Inventory',
              '❌ Financial reports',
            ],
            color: Colors.blue.shade600,
            isPopular: false,
            onBuy: () => _showPaymentInstructions(context, l10n.pricingBasic, l10n.pricingBasicPrice),
          ),

          const SizedBox(height: 12),

          _PlanCard(
            name: l10n.pricingPro,
            price: l10n.pricingProPrice,
            description: l10n.pricingProDesc,
            features: const [
              '✅ Everything in Basic',
              '✅ Staff management',
              '✅ Inventory tracking',
              '✅ Financial reports',
              '✅ Appointments',
              '✅ Payment recording',
              '✅ Billing & Invoices',
              '✅ Notifications',
            ],
            color: const Color(0xFF8B5CF6),
            isPopular: true,
            popularLabel: l10n.pricingPopular,
            onBuy: () => _showPaymentInstructions(context, l10n.pricingPro, l10n.pricingProPrice),
          ),

          const SizedBox(height: 12),

          _PlanCard(
            name: l10n.pricingEnterprise,
            price: l10n.pricingEnterprisePrice,
            description: l10n.pricingEnterpriseDesc,
            features: const [
              '✅ Everything in Pro',
              '✅ 2 device licenses',
              '✅ Priority support',
              '✅ 1 year free updates',
              '✅ Setup assistance',
              '✅ Training session',
            ],
            color: Colors.orange.shade700,
            isPopular: false,
            onBuy: () => _showPaymentInstructions(context, l10n.pricingEnterprise, l10n.pricingEnterprisePrice),
          ),

          const SizedBox(height: 24),

          // ── Device ID Section ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.phone_android, color: Color(0xFF8B5CF6)),
                    SizedBox(width: 8),
                    Text(
                      'Your Device ID',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'You need this to get your license key. Copy it and send to our Telegram after payment.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _deviceId.isEmpty ? 'Loading...' : _deviceId,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _copied ? Icons.check_circle : Icons.copy,
                          color: _copied ? Colors.green : const Color(0xFF8B5CF6),
                        ),
                        onPressed: _copyDeviceId,
                        tooltip: 'Copy Device ID',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.telegram),
                    label: Text(l10n.shareOnTelegram),
                    onPressed: () => _openTelegram(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0088CC),
                      side: const BorderSide(color: Color(0xFF0088CC)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Payment Instructions ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      l10n.paymentInstructionsTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _StepTile(text: l10n.paymentStep1),
                _StepTile(text: l10n.paymentStep2),
                _StepTile(text: l10n.paymentStep3),
                _StepTile(text: l10n.paymentStep4),
                _StepTile(text: l10n.paymentStep5),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Payment Methods ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Methods',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _PaymentMethodTile(
                  icon: '💳',
                  name: 'TeleBirr',
                  detail: '+251-912-345-678',
                  color: Colors.blue.shade50,
                ),
                const SizedBox(height: 8),
                _PaymentMethodTile(
                  icon: '🏦',
                  name: 'CBE Birr',
                  detail: '1000123456789',
                  color: Colors.green.shade50,
                ),
                const SizedBox(height: 8),
                _PaymentMethodTile(
                  icon: '💬',
                  name: 'Telegram',
                  detail: 't.me/TailorSystemET',
                  color: Colors.lightBlue.shade50,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showPaymentInstructions(BuildContext context, String plan, String price) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Buy $plan — $price',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'To complete your purchase:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _StepTile(text: '1. Send $price to TeleBirr: +251-912-345-678'),
            _StepTile(text: '2. Take a screenshot of the payment'),
            _StepTile(text: '3. Copy your Device ID (button below)'),
            _StepTile(text: '4. Send screenshot + Device ID + shop name to t.me/TailorSystemET'),
            _StepTile(text: '5. Get your license key within 24 hours'),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Device ID'),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: _deviceId));
                      if (!context.mounted) return;
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Device ID copied!'),
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.telegram),
                    label: const Text('Open Telegram'),
                    onPressed: () {
                      Navigator.pop(context);
                      _openTelegram(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0088CC),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.description,
    required this.features,
    required this.color,
    required this.isPopular,
    required this.onBuy,
    this.popularLabel,
  });

  final String name;
  final String price;
  final String description;
  final List<String> features;
  final Color color;
  final bool isPopular;
  final String? popularLabel;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPopular ? color : const Color(0xFFE2E8F0),
          width: isPopular ? 2.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(isPopular ? 0.15 : 0.05),
            blurRadius: isPopular ? 20 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPopular && popularLabel != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            popularLabel!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price.split('/').first.trim(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    if (price.contains('/'))
                      Text(
                        '/ ${price.split('/').last.trim()}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Features
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              children: features
                  .map((f) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Text(f.substring(0, 2), style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              f.substring(2),
                              style: TextStyle(
                                fontSize: 13,
                                color: f.startsWith('❌') ? Colors.grey : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Buy button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onBuy,
                style: FilledButton.styleFrom(backgroundColor: color),
                child: const Text(
                  'Buy This Plan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.name,
    required this.detail,
    required this.color,
  });
  final String icon;
  final String name;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                Text(detail,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: detail));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name number copied!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green.shade700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
