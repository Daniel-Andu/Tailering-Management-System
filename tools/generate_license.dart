// License Key Generator Tool
// Use this to generate license keys for your customers
// Run with: dart tools/generate_license.dart

void main() {
  print('=== Tailoring System License Key Generator ===\n');
  
  print('Instructions:');
  print('1. Ask the customer to install the app and get their Device ID from the license screen');
  print('2. Enter their Device ID and Company Name below');
  print('3. Copy the generated license key and give it to them');
  print('4. They enter the license key in the app to activate\n');
  
  print('Example:');
  print('Device ID: android-1234567890abcdef');
  print('Company Name: ABC Tailoring Shop');
  print('Generated Key: TAILOR-A1B2-C3D4-E5F6\n');
  
  // Interactive input
  print('Enter Device ID:');
  // In a real scenario, you would read from stdin
  // For now, this is a template
  
  print('\nEnter Company Name:');
  // In a real scenario, you would read from stdin
  
  // Example generation
  final exampleDeviceId = 'android-1234567890abcdef';
  final exampleCompanyName = 'ABC Tailoring Shop';
  final licenseKey = _generateLicenseKey(exampleDeviceId, exampleCompanyName);
  
  print('\nExample Generated License Key:');
  print('$licenseKey');
  print('\nPrice: 2000 ETB (or your chosen price)');
}

String _generateLicenseKey(String deviceId, String companyName) {
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

String _toHex(int value) {
  return value.toRadixString(16).toUpperCase().padLeft(4, '0');
}
