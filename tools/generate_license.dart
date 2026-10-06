import 'dart:io';

void main(List<String> args) {
  final deviceId = args.isNotEmpty ? args[0] : _prompt('Device ID');
  final companyName =
      args.length > 1 ? args.sublist(1).join(' ') : _prompt('Company name');

  final licenseKey = generateLicenseKey(deviceId, companyName);

  stdout.writeln('\nTailoring System License');
  stdout.writeln('Device ID: $deviceId');
  stdout.writeln('Company: $companyName');
  stdout.writeln('License Key: $licenseKey');
  stdout.writeln('\nGive this key to the tailor after payment.');
}

String _prompt(String label) {
  stdout.write('$label: ');
  final value = stdin.readLineSync()?.trim() ?? '';
  if (value.isEmpty) {
    stderr.writeln('$label is required.');
    exit(64);
  }
  return value;
}

String generateLicenseKey(String deviceId, String companyName) {
  const base = 'TAILOR';
  const salt = 'TAILORING_SYSTEM_OFFLINE_LICENSE_V1';
  final normalizedDevice = deviceId.trim().toUpperCase();
  final normalizedCompany = companyName.trim().toUpperCase();
  final hash = _stableHash('$salt|$normalizedDevice|$normalizedCompany');

  final part1 = _toHex(hash & 0xFFFF);
  final part2 = _toHex((hash >> 16) & 0xFFFF);
  final part3 =
      _toHex(_stableHash('$normalizedCompany|$normalizedDevice') & 0xFFFF);

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

String _toHex(int value) {
  return value.toRadixString(16).toUpperCase().padLeft(4, '0');
}
