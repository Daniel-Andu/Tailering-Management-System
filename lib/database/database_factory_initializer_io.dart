import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initializeDatabaseFactory() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // On Android and iOS, sqflite uses its native implementation by default —
  // no extra factory setup is needed. The default databaseFactory is already
  // the correct one for mobile platforms.
}
