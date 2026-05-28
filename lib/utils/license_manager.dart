import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LicenseManager {
  static const _storage = FlutterSecureStorage();
  static const _trialDays =
      14; // Reduced from 30 to 14 days to encourage purchase
  static const _licenseKeyFormat =
      r'^TAILOR-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$';

  // Device ID storage and generation
  static Future<String> getDeviceId() async {
    String? deviceId = await _storage.read(key: 'device_id');
    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    // Generate device ID
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? 'unknown-ios';
    } else if (Platform.isWindows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      deviceId = windowsInfo.deviceId;
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      deviceId = linuxInfo.machineId ?? 'unknown-linux';
    } else {
      deviceId = 'web-${DateTime.now().millisecondsSinceEpoch}';
    }

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

    // Validate license key format and device binding
    if (await _validateLicenseWithDevice(licenseKey)) {
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

    // Check if license is bound to this device
    final boundDeviceId = await _storage.read(key: 'bound_device_id');
    final currentDeviceId = await getDeviceId();

    // If license is already bound to a device, check if it matches
    if (boundDeviceId != null && boundDeviceId.isNotEmpty) {
      return boundDeviceId == currentDeviceId;
    }

    // For new activation, we'll validate in activateLicense
    return true;
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

  // Generate a license key for a specific device and company
  // You'll use this to generate keys for your customers
  static String generateLicenseKey(String deviceId, String companyName) {
    const base = 'TAILOR';

    // Create a hash from device ID and company name
    final deviceHash = deviceId.hashCode.abs();
    final companyHash = companyName.hashCode.abs();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final part1 = _toHex((deviceHash + timestamp) & 0xFFFF);
    final part2 = _toHex((companyHash + timestamp) & 0xFFFF);
    final part3 = _toHex(timestamp & 0xFFFF);

    return '$base-$part1-$part2-$part3';
  }

  static String _toHex(int value) {
    return value.toRadixString(16).toUpperCase().padLeft(4, '0');
  }
}
