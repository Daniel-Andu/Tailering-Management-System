import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/settings/providers/app_settings_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(l10n.shopSettingsTitle)),
      body: Consumer<AppSettingsProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: provider.isLoading ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(l10n.shopSettingsSave),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              if (provider.errorMessage != null) ...[
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            provider.errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
  }
}
