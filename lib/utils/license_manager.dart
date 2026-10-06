import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LicenseManager {
  static const _storage = FlutterSecureStorage();
  static const _trialDays = 30; // 30 day trial period
  static const _licenseKeyFormat =
      r'^TAILOR-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$';
  static const _licenseSalt = 'TAILORING_SYSTEM_OFFLINE_LICENSE_V1';

  // Device ID storage and generation
  static Future<String> getDeviceId() async {
    String? deviceId = await _storage.read(key: 'device_id');
    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    const prefix = kIsWeb ? 'WEB' : 'TAILOR';
    final now = DateTime.now().microsecondsSinceEpoch;
    deviceId =
        '$prefix-${_toHex(now & 0xFFFF)}-${_toHex((now >> 16) & 0xFFFF)}'
        '-${_toHex(_stableHash(now.toString()) & 0xFFFF)}';

    await _storage.write(key: 'device_id', value: deviceId);
    return deviceId;
  }

  // Company name storage
  static Future<String?> getCompanyName() async {
    return await _storage.read(key: 'company_name');
  }

  static Future<void> setCompanyName(String name) async {
    await _storage.write(key: 'company_name', value: name);
  }

  static Future<bool> isLicensed() async {
    final licenseKey = await _storage.read(key: 'license_key');

    if (licenseKey != null && licenseKey.isNotEmpty) {
      return await _validateLicenseWithDevice(licenseKey);
    }

    return await _isTrialValid();
  }

  static Future<int> getTrialDaysRemaining() async {
    final installDateStr = await _storage.read(key: 'install_date');

    if (installDateStr == null || installDateStr.isEmpty) {
      return _trialDays;
    }

    try {
      final installDate = DateTime.parse(installDateStr);
      final trialEndDate = installDate.add(const Duration(days: _trialDays));
      final remaining = trialEndDate.difference(DateTime.now()).inDays;

      return remaining > 0 ? remaining : 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<bool> _isTrialValid() async {
    final daysRemaining = await getTrialDaysRemaining();
    return daysRemaining > 0;
  }

  static Future<void> initializeTrial() async {
    final installDate = await _storage.read(key: 'install_date');

    if (installDate == null || installDate.isEmpty) {
      await _storage.write(
        key: 'install_date',
        value: DateTime.now().toIso8601String(),
      );
    }
    // Generate device ID on first install
    await getDeviceId();
  }

  static Future<bool> activateLicense(
      String licenseKey, String companyName) async {
    final deviceId = await getDeviceId();

    if (await _validateLicenseWithDeviceAndCompany(licenseKey, companyName)) {
      await _storage.write(key: 'license_key', value: licenseKey);
      await _storage.write(
        key: 'activation_date',
        value: DateTime.now().toIso8601String(),
      );
      await _storage.write(key: 'company_name', value: companyName);
      await _storage.write(key: 'bound_device_id', value: deviceId);
      return true;
    }
    return false;
  }

  static bool _validateLicenseKey(String licenseKey) {
    final regex = RegExp(_licenseKeyFormat);
    return regex.hasMatch(licenseKey);
  }

  static Future<bool> _validateLicenseWithDevice(String licenseKey) async {
    if (!_validateLicenseKey(licenseKey)) {
      return false;
    }

    final boundDeviceId = await _storage.read(key: 'bound_device_id');
    final currentDeviceId = await getDeviceId();

    if (boundDeviceId != null && boundDeviceId.isNotEmpty) {
      final companyName = await getCompanyName();
      if (companyName == null || companyName.isEmpty) return false;
      return boundDeviceId == currentDeviceId &&
          await _validateLicenseWithDeviceAndCompany(licenseKey, companyName);
    }

    return false;
  }

  static Future<bool> _validateLicenseWithDeviceAndCompany(
      String licenseKey, String companyName) async {
    if (!_validateLicenseKey(licenseKey)) return false;
    final deviceId = await getDeviceId();
    return licenseKey.toUpperCase() ==
        generateLicenseKey(deviceId, companyName).toUpperCase();
  }

  static Future<String> getLicenseInfo() async {
    final licenseKey = await _storage.read(key: 'license_key');
    final companyName = await getCompanyName();
    final deviceId = await getDeviceId();

    if (licenseKey != null && licenseKey.isNotEmpty) {
      final boundDeviceId = await _storage.read(key: 'bound_device_id');
      final isBound = boundDeviceId == deviceId;

      return 'License Type: Full License\nCompany: ${companyName ?? 'Not Set'}\nLicense Key: $licenseKey\nDevice ID: $deviceId\nStatus: ${isBound ? 'Active' : 'Device Mismatch'}';
    }

    final daysRemaining = await getTrialDaysRemaining();
    return 'License Type: Trial Version\nDays Remaining: $daysRemaining\nDevice ID: $deviceId\nStatus: ${daysRemaining > 0 ? 'Active' : 'Expired'}';
  }

  /// Generate a license key for a specific device and company.
  /// Use this tool to generate keys for customers.
  static String generateLicenseKey(String deviceId, String companyName) {
    const base = 'TAILOR';

    final normalizedDevice = deviceId.trim().toUpperCase();
    final normalizedCompany = companyName.trim().toUpperCase();
    final hash = _stableHash(
      '$_licenseSalt|$normalizedDevice|$normalizedCompany',
    );

    final part1 = _toHex(hash & 0xFFFF);
    final part2 = _toHex((hash >> 16) & 0xFFFF);
    final part3 =
        _toHex(_stableHash('$normalizedCompany|$normalizedDevice') & 0xFFFF);

    return '$base-$part1-$part2-$part3';
  }

  static int _stableHash(String input) {
    var hash = 0x811C9DC5;
    for (final codeUnit in input.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }

  static String _toHex(int value) {
    return value.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
