import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void initializeDatabaseFactory() {
  // Keep SQLite on the UI thread so web builds do not require sqflite_sw.js.
  databaseFactory = databaseFactoryFfiWebNoWebWorker;
}
