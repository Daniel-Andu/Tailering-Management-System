import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/settings/providers/app_settings_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';
import 'package:tailoring_system/providers/language_provider.dart';
import 'package:tailoring_system/utils/license_manager.dart';

class ShopSettingsScreen extends StatefulWidget {
  const ShopSettingsScreen({super.key});

  @override
  State<ShopSettingsScreen> createState() => _ShopSettingsScreenState();
}

class _ShopSettingsScreenState extends State<ShopSettingsScreen> {
  final _shopNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _footerController = TextEditingController();
  String _licenseInfo = '';
  String _deviceId = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<AppSettingsProvider>();
      await provider.load();
      _shopNameController.text = provider.value('shop.name') ?? '';
      _phoneController.text = provider.value('shop.phone') ?? '';
      _addressController.text = provider.value('shop.address') ?? '';
      _footerController.text = provider.value('receipt.footer') ?? '';
      final info = await LicenseManager.getLicenseInfo();
      final deviceId = await LicenseManager.getDeviceId();
      if (mounted) {
        setState(() {
          _licenseInfo = info;
          _deviceId = deviceId;
        });
      }
    });
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = context.watch<LanguageProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopSettingsTitle)),
      body: Consumer<AppSettingsProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Shop Profile ─────────────────────────────────────────────
              _SectionCard(
                icon: Icons.store,
                title: l10n.shopSettingsTitle,
                child: Column(
                  children: [
                    TextField(
                      controller: _shopNameController,
                      decoration: InputDecoration(
                        labelText: l10n.shopSettingsShopName,
                        prefixIcon: const Icon(Icons.store),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: l10n.shopSettingsShopPhone,
                        prefixIcon: const Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: l10n.shopSettingsAddress,
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _footerController,
                      decoration: InputDecoration(
                        labelText: l10n.shopSettingsReceiptFooter,
                        prefixIcon: const Icon(Icons.receipt),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: provider.isLoading ? null : _save,
                        icon: const Icon(Icons.save),
                        label: Text(l10n.shopSettingsSave),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Language ──────────────────────────────────────────────────
              _SectionCard(
                icon: Icons.language,
                title: l10n.settingsLanguage,
                child: Column(
                  children: [
                    _LanguageTile(
                      flag: '🇬🇧',
                      label: l10n.settingsEnglish,
                      selected: !languageProvider.isAmharic,
                      onTap: () => languageProvider.setLanguage('en'),
                    ),
                    const SizedBox(height: 8),
                    _LanguageTile(
                      flag: '🇪🇹',
                      label: l10n.settingsAmharic,
                      selected: languageProvider.isAmharic,
                      onTap: () => languageProvider.setLanguage('am'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── License Info ──────────────────────────────────────────────
              _SectionCard(
                icon: Icons.verified_user,
                title: l10n.licenseTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _licenseInfo,
                        style: const TextStyle(
                            fontFamily: 'monospace', fontSize: 12),
                      ),
                    ),
                    if (_deviceId.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.phone_android,
                              size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: 6),
                          Text('Device ID: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary)),
                          Expanded(
                            child: SelectableText(
                              _deviceId,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Business Contact ──────────────────────────────────────────
              _SectionCard(
                icon: Icons.contact_support,
                title: l10n.businessContactTitle,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.businessContactBody,
                        style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 12),
                    _ContactRow(text: l10n.businessPhone),
                    const SizedBox(height: 6),
                    _ContactRow(text: l10n.businessEmail),
                    const SizedBox(height: 6),
                    _ContactRow(text: l10n.businessTelegram),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── About ─────────────────────────────────────────────────────
              _SectionCard(
                icon: Icons.info_outline,
                title: l10n.settingsAbout,
                child: Column(
                  children: [
                    _AboutRow(label: l10n.settingsVersion, value: '1.0.0'),
                    const SizedBox(height: 6),
                    const _AboutRow(label: 'Platform', value: 'Android'),
                    const SizedBox(height: 6),
                    const _AboutRow(
                        label: 'Database', value: 'SQLite (offline)'),
                  ],
                ),
              ),

              if (provider.errorMessage != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: theme.colorScheme.onErrorContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: TextStyle(
                                color: theme.colorScheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    await context.read<AppSettingsProvider>().saveShopProfile(
          shopName: _shopNameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          receiptFooter: _footerController.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.commonSuccess),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: theme.colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle,
                  color: theme.colorScheme.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SelectableText(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
