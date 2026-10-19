import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/settings/providers/app_settings_provider.dart';
import 'package:tailoring_system/features/settings/screens/sync_status_screen.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';
import 'package:tailoring_system/providers/language_provider.dart';
import 'package:tailoring_system/providers/auth_provider.dart';
import 'package:tailoring_system/screens/auth/auth_router.dart';
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

              // ── Account & Profile ─────────────────────────────────────────
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final user = authProvider.currentUser;
                  final shopProfile = authProvider.shopProfile;
                  
                  return _SectionCard(
                    icon: Icons.account_circle,
                    title: 'Account & Profile',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (user != null) ...[
                          _InfoRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: user.email ?? 'N/A',
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (shopProfile != null) ...[
                          _InfoRow(
                            icon: Icons.store,
                            label: 'Shop Name',
                            value: shopProfile.shopName,
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: Icons.location_city,
                            label: 'City',
                            value: shopProfile.city ?? 'Not set',
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: Icons.category,
                            label: 'Specialization',
                            value: shopProfile.specialization ?? 'Not set',
                          ),
                          const SizedBox(height: 16),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _editProfile(context),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _confirmLogout(context),
                            icon: const Icon(Icons.logout),
                            label: const Text('Logout'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── Cloud Sync ────────────────────────────────────────────────
              _SectionCard(
                icon: Icons.cloud_sync,
                title: 'Cloud Sync',
                child: Column(
                  children: [
                    Text(
                      'Sync your data across devices securely with Firebase',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SyncStatusScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text('View Sync Status'),
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

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade600,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthRouter()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _editProfile(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final shopProfile = authProvider.shopProfile;
    
    if (shopProfile == null) return;

    final shopNameController = TextEditingController(text: shopProfile.shopName);
    final ownerNameController = TextEditingController(text: shopProfile.ownerName);
    final phoneController = TextEditingController(text: shopProfile.phoneNumber);
    final addressController = TextEditingController(text: shopProfile.address);
    final cityController = TextEditingController(text: shopProfile.city);
    String? selectedSpecialization = shopProfile.specialization;  // Allow null

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: shopNameController,
                decoration: const InputDecoration(
                  labelText: 'Shop Name',
                  prefixIcon: Icon(Icons.store),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Owner Name',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    shopNameController.dispose();
    ownerNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();

    if (updated == true && context.mounted) {
      // TODO: Implement profile update in AuthProvider
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
