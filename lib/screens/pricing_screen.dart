import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tailoring_system/features/subscriptions/data/subscription_service.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';
import 'package:tailoring_system/utils/license_manager.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final _service = SubscriptionService();
  String _deviceId = '';
  String? _checkoutIdempotencyKey;
  String? _pendingMerchantReference;
  Uri? _pendingCheckoutUrl;
  String? _error;
  SubscriptionStatus? _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
    _refreshStatus();
  }

  Future<void> _loadDeviceId() async {
    final id = await LicenseManager.getDeviceId();
    if (mounted) setState(() => _deviceId = id);
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('Failed to fetch') || text.contains('ClientException')) {
      return 'The billing backend is not reachable right now. Start your backend and make sure SUBSCRIPTION_API_URL points to the correct URL.';
    }
    if (text.contains('Chapa subscriptions are not configured')) {
      return 'Chapa checkout is not configured yet. Set SUBSCRIPTION_API_URL in the app build/run command.';
    }
    return text.replaceFirst('Exception: ', '').replaceFirst('Exception', '');
  }

  Future<void> _refreshStatus() async {
    if (!_service.isConfigured) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _status = await _service.loadStatus();
    } catch (error) {
      _error = _friendlyError(error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _startCheckout(String planId) async {
    if (!_service.isConfigured ||
        _isLoading ||
        _pendingMerchantReference != null) {
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final idempotencyKey =
          _checkoutIdempotencyKey ??= _service.createIdempotencyKey();
      final checkout = await _service.startCheckout(
        planId: planId,
        deviceId: _deviceId,
        idempotencyKey: idempotencyKey,
      );
      if (mounted) {
        setState(() {
          _pendingMerchantReference = checkout.merchantReference;
          _pendingCheckoutUrl = checkout.checkoutUrl;
        });
      }
      final opened = await _service.openCheckout(checkout.checkoutUrl);
      if (!opened) throw StateError('Could not open the Chapa checkout page.');
      _checkoutIdempotencyKey = null;
    } catch (error) {
      if (mounted) {
        setState(() => _error = _friendlyError(error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openPendingCheckout() async {
    final checkoutUrl = _pendingCheckoutUrl;
    if (checkoutUrl == null || _isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final opened = await _service.openCheckout(checkoutUrl);
      if (!opened) throw StateError('Could not open the Chapa checkout page.');
      _checkoutIdempotencyKey = null;
    } catch (error) {
      if (mounted) setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyPendingCheckout() async {
    final reference = _pendingMerchantReference;
    if (reference == null || _isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await _service.verifyCheckout(reference);
      if (!mounted) return;
      setState(() {
        _status = result.isActive ? result : _status;
        if (result.isActive ||
            const {'cancelled', 'failed', 'incomplete'}
                .contains(result.paymentStatus)) {
          _pendingMerchantReference = null;
          _pendingCheckoutUrl = null;
          _checkoutIdempotencyKey = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.isActive
                ? 'Payment verified. Your subscription is active.'
                : 'Payment is ${result.paymentStatus ?? 'not confirmed'}. '
                    'Your subscription has not been activated.',
          ),
        ),
      );
    } catch (error) {
      if (mounted) setState(() => _error = _friendlyError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pricingTitle),
        actions: [
          IconButton(
            tooltip: 'Refresh subscription status',
            onPressed: _isLoading ? null : _refreshStatus,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: colors.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.workspace_premium,
                      size: 40, color: colors.onPrimaryContainer),
                  const SizedBox(height: 8),
                  Text(
                    'Annual subscription',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose a plan and pay securely with Chapa. Renewal is annual; the app does not charge automatically.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _subscriptionCard(context),
          if (_pendingMerchantReference != null) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_pendingCheckoutUrl != null)
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _openPendingCheckout,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Reopen checkout'),
                  ),
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _verifyPendingCheckout,
                  icon: const Icon(Icons.verified_outlined),
                  label:
                      const Text('I returned from checkout — verify payment'),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _PlanCard(
            name: l10n.pricingBasic,
            price: l10n.pricingBasicPrice,
            description: l10n.pricingBasicDesc,
            icon: Icons.storefront_outlined,
            onChoose: _isLoading ||
                    _pendingMerchantReference != null ||
                    !_service.isConfigured
                ? null
                : () => _startCheckout('basic'),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            name: l10n.pricingPro,
            price: l10n.pricingProPrice,
            description: l10n.pricingProDesc,
            icon: Icons.workspace_premium_outlined,
            highlighted: true,
            onChoose: _isLoading ||
                    _pendingMerchantReference != null ||
                    !_service.isConfigured
                ? null
                : () => _startCheckout('pro'),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            name: l10n.pricingEnterprise,
            price: l10n.pricingEnterprisePrice,
            description: l10n.pricingEnterpriseDesc,
            icon: Icons.business_outlined,
            onChoose: _isLoading ||
                    _pendingMerchantReference != null ||
                    !_service.isConfigured
                ? null
                : () => _startCheckout('enterprise'),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Device ID'),
              subtitle: SelectableText(
                _deviceId.isEmpty ? 'Loading…' : _deviceId,
              ),
              trailing: IconButton(
                tooltip: 'Copy device ID',
                icon: const Icon(Icons.copy),
                onPressed:
                    _deviceId.isEmpty ? null : () => _copyDeviceId(context),
              ),
            ),
          ),
          if (!_service.isConfigured) ...[
            const SizedBox(height: 12),
            const _StatusMessage(
              icon: Icons.info_outline,
              text:
                  'Chapa checkout is not connected yet. Configure SUBSCRIPTION_API_URL with the secure billing backend before accepting payments.',
            ),
          ],
          if (_error != null && _service.isConfigured) ...[
            const SizedBox(height: 12),
            _StatusMessage(
              icon: Icons.error_outline,
              text: _error!,
              isError: true,
            ),
          ],
          if (_isLoading) ...[
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Widget _subscriptionCard(BuildContext context) {
    if (!_service.isConfigured) {
      return const Card(
        child: ListTile(
          leading: Icon(Icons.pending_outlined),
          title: Text('Subscription status unavailable'),
          subtitle: Text('Connect the billing backend to check your plan.'),
        ),
      );
    }
    final status = _status;
    if (status == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.hourglass_empty),
          title: Text(_isLoading ? 'Checking subscription…' : 'No active plan'),
          subtitle: const Text('Select a plan below to continue.'),
        ),
      );
    }

    return Card(
      child: ListTile(
        leading: Icon(
          status.isActive ? Icons.verified : Icons.info_outline,
          color: status.isActive
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(status.isActive
            ? 'Active ${status.planId ?? ''} subscription'
            : 'No active subscription'),
        subtitle: Text(status.expiresAt == null
            ? 'Choose a plan below to subscribe.'
            : 'Valid until ${MaterialLocalizations.of(context).formatMediumDate(status.expiresAt!)}'),
      ),
    );
  }

  Future<void> _copyDeviceId(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _deviceId));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Device ID copied.')),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.name,
    required this.price,
    required this.description,
    required this.icon,
    required this.onChoose,
    this.highlighted = false,
  });

  final String name;
  final String price;
  final String description;
  final IconData icon;
  final VoidCallback? onChoose;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: highlighted ? colors.primary : colors.outlineVariant,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  price,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onChoose,
                icon: const Icon(Icons.lock_outline),
                label: Text('Continue with $name'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: isError ? colors.errorContainer : colors.secondaryContainer,
      child: ListTile(
        leading: Icon(
          icon,
          color:
              isError ? colors.onErrorContainer : colors.onSecondaryContainer,
        ),
        title: Text(
          text,
          style: TextStyle(
            color:
                isError ? colors.onErrorContainer : colors.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
