/// ============================================================
/// LICENSE KEY GENERATOR — For Developer Use Only
/// ============================================================
///
/// Run this script to generate a license key for a customer:
///
///   dart tools/generate_license_key.dart
///
/// You will be prompted to enter:
///   1. The customer's Device ID (they copy it from the app)
///   2. Their company/shop name
///
/// The script outputs the license key to give to the customer.
/// ============================================================

import 'dart:io';

void main() {
  print('');
  print('╔════════════════════════════════════════════╗');
  print('║   TAILORING SYSTEM - License Key Generator ║');
  print('╚════════════════════════════════════════════╝');
  print('');

  // Get Device ID
  stdout.write('Enter customer Device ID: ');
  final deviceId = stdin.readLineSync()?.trim() ?? '';
  if (deviceId.isEmpty) {
    print('ERROR: Device ID cannot be empty.');
    exit(1);
  }

  // Get Company Name
  stdout.write('Enter customer shop/company name: ');
  final companyName = stdin.readLineSync()?.trim() ?? '';
  if (companyName.isEmpty) {
    print('ERROR: Company name cannot be empty.');
    exit(1);
  }

  // Generate key
  final key = _generateLicenseKey(deviceId, companyName);

  print('');
  print('══════════════════════════════════════════════');
  print('  Device ID   : $deviceId');
  print('  Company     : $companyName');
  print('  LICENSE KEY : $key');
  print('══════════════════════════════════════════════');
  print('');
  print('✅ Send this key to your customer.');
  print('   They enter it in the app → Activate License.');
  print('');

  // Save to log file
  final logFile = File('tools/license_keys_log.txt');
  final timestamp = DateTime.now().toIso8601String();
  final logEntry =
      '$timestamp | Device: $deviceId | Company: $companyName | Key: $key\n';
  logFile.writeAsStringSync(logEntry, mode: FileMode.append, flush: true);
  print('📁 Saved to tools/license_keys_log.txt');
  print('');
}

// ── Same algorithm as LicenseManager in the app ──────────────────────────────

const _licenseSalt = 'TAILORING_SYSTEM_OFFLINE_LICENSE_V1';

String _generateLicenseKey(String deviceId, String companyName) {
  const base = 'TAILOR';
  final normalizedDevice = deviceId.trim().toUpperCase();
  final normalizedCompany = companyName.trim().toUpperCase();

  final hash = _stableHash('$_licenseSalt|$normalizedDevice|$normalizedCompany');
  final part1 = _toHex(hash & 0xFFFF);
  final part2 = _toHex((hash >> 16) & 0xFFFF);
  final part3 = _toHex(
      _stableHash('$normalizedCompany|$normalizedDevice') & 0xFFFF);

  return '$base-$part1-$part2-$part3';
}

int _stableHash(String input) {
  var hash = 0x811C9DC5;
  for (final codeUnit in input.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

String _toHex(int value) =>
    value.toRadixString(16).toUpperCase().padLeft(4, '0');
