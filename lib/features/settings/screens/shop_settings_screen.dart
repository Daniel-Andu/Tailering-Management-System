import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/settings/providers/app_settings_provider.dart';
import 'package:tailoring_system/features/settings/screens/sync_status_screen.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';
import 'package:tailoring_system/providers/language_provider.dart';
import 'package:tailoring_system/providers/auth_provider.dart';
import 'package:tailoring_system/providers/theme_provider.dart';
import 'package:tailoring_system/screens/auth/auth_router.dart';
import 'package:tailoring_system/screens/pricing_screen.dart';
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
  int _trialDaysRemaining = 0;
  bool _isLicensed = false;

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
      final trialDays = await LicenseManager.getTrialDaysRemaining();
      final isLicensed = await LicenseManager.isLicensed();
      if (mounted) {
        setState(() {
          _licenseInfo = info;
          _deviceId = deviceId;
          _trialDaysRemaining = trialDays;
          _isLicensed = isLicensed;
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

              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) => _SectionCard(
                  icon: Icons.dark_mode_outlined,
                  title: 'Appearance',
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Dark theme'),
                    subtitle: const Text('Use darker colors across the app'),
                    value: themeProvider.isDarkMode,
                    onChanged: (enabled) => themeProvider.setThemeMode(
                      enabled ? ThemeMode.dark : ThemeMode.light,
                    ),
                  ),
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
                        Center(
                          child: Tooltip(
                            message: 'Change profile photo',
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: authProvider.isLoading
                                  ? null
                                  : () => _changeProfilePhoto(context),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  CircleAvatar(
                                    radius: 38,
                                    backgroundImage:
                                        shopProfile?.profileImageUrl == null
                                            ? null
                                            : NetworkImage(
                                                shopProfile!.profileImageUrl!,
                                              ),
                                    child: shopProfile?.profileImageUrl == null
                                        ? const Icon(Icons.store, size: 36)
                                        : null,
                                  ),
                                  Positioned(
                                    right: -2,
                                    bottom: -2,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      child: authProvider.isLoading
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Icon(
                                              Icons.camera_alt_outlined,
                                              size: 15,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: OutlinedButton.icon(
                            onPressed: authProvider.isLoading
                                ? null
                                : () => _changeProfilePhoto(context),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Change photo'),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _isLicensed
                            ? Colors.green.shade50
                            : _trialDaysRemaining > 5
                                ? Colors.orange.shade50
                                : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isLicensed
                              ? Colors.green.shade300
                              : _trialDaysRemaining > 5
                                  ? Colors.orange.shade300
                                  : Colors.red.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isLicensed
                                ? Icons.verified_user
                                : (_trialDaysRemaining > 5
                                    ? Icons.timer_outlined
                                    : Icons.warning_amber_rounded),
                            color: _isLicensed
                                ? Colors.green.shade700
                                : (_trialDaysRemaining > 5
                                    ? Colors.orange.shade700
                                    : Colors.red.shade700),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isLicensed
                                      ? 'Full license active'
                                      : (_trialDaysRemaining > 0
                                          ? '30-day trial active'
                                          : 'Trial expired'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isLicensed
                                      ? 'Your app is fully activated.'
                                      : (_trialDaysRemaining > 0
                                          ? '$_trialDaysRemaining days remaining in your free trial.'
                                          : 'Your free trial has ended. Upgrade to continue.'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PricingScreen(),
                          ),
                        ),
                        icon: const Icon(Icons.workspace_premium_outlined),
                        label: const Text('Plans and subscription'),
                      ),
                    ),
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

  Future<void> _changeProfilePhoto(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    try {
      final image = await _pickProfileImage();
      if (image == null || !context.mounted) return;
      final bytes = image.bytes;
      if (bytes == null || bytes.isEmpty) {
        throw StateError('The selected image could not be read.');
      }

      final profile = authProvider.shopProfile;
      if (profile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The photo was selected, but cannot be saved until your shop profile is available.',
            ),
          ),
        );
        return;
      }

      await authProvider.updateShopProfile(
        profile,
        profileImage: bytes,
        imageContentType: _imageContentType(image),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated successfully')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update profile photo: $error')),
        );
      }
    }
  }

  Future<PlatformFile?> _pickProfileImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    return result?.files.single;
  }

  String _imageContentType(PlatformFile image) {
    return switch (image.extension?.toLowerCase()) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'bmp' => 'image/bmp',
      _ => 'image/jpeg',
    };
  }

  Future<void> _editProfile(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    final shopProfile = authProvider.shopProfile;

    if (shopProfile == null) return;

    final shopNameController =
        TextEditingController(text: shopProfile.shopName);
    final ownerNameController =
        TextEditingController(text: shopProfile.ownerName);
    final phoneController =
        TextEditingController(text: shopProfile.phoneNumber);
    final addressController = TextEditingController(text: shopProfile.address);
    final cityController = TextEditingController(text: shopProfile.city);
    String? selectedSpecialization = shopProfile.specialization; // Allow null
    PlatformFile? selectedImage;

    Uint8List? selectedImageBytes;

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedImageBytes != null ||
                    shopProfile.profileImageUrl != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    child: selectedImageBytes != null
                        ? ClipOval(
                            child: Image.memory(
                              selectedImageBytes!,
                              fit: BoxFit.cover,
                              width: 90,
                              height: 90,
                            ),
                          )
                        : ClipOval(
                            child: shopProfile.profileImageUrl != null
                                ? Image.network(
                                    shopProfile.profileImageUrl!,
                                    fit: BoxFit.cover,
                                    width: 90,
                                    height: 90,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      size: 40,
                                    ),
                                  )
                                : const Icon(Icons.person, size: 40),
                          ),
                  ),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final image = await _pickProfileImage();
                      if (image != null) {
                        final bytes = image.bytes;
                        if (bytes == null || bytes.isEmpty) {
                          throw StateError(
                              'The selected image could not be read.');
                        }
                        setDialogState(() {
                          selectedImage = image;
                          selectedImageBytes = bytes;
                        });
                      }
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Could not select profile photo: $error'),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(
                    selectedImage == null
                        ? 'Choose profile photo'
                        : 'Photo selected',
                  ),
                ),
                const SizedBox(height: 12),
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
      ),
    );

    if (updated == true && context.mounted) {
      try {
        final imageBytes = selectedImageBytes;
        final imageFile = selectedImage;
        await authProvider.updateShopProfile(
          shopProfile.copyWith(
            shopName: shopNameController.text.trim(),
            ownerName: ownerNameController.text.trim(),
            phone: phoneController.text.trim(),
            address: addressController.text.trim(),
            city: cityController.text.trim(),
            specialization: selectedSpecialization,
          ),
          profileImage: imageBytes,
          imageContentType:
              imageFile == null ? 'image/jpeg' : _imageContentType(imageFile),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully')),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save profile: $error')),
          );
        }
      }

      shopNameController.dispose();
      ownerNameController.dispose();
      phoneController.dispose();
      addressController.dispose();
      cityController.dispose();
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
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
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
