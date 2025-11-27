// Stub file for web - provides a dummy function
// This file is used when compiling for web
import 'package:sqflite/sqflite.dart';

DatabaseFactory getDatabaseFactory() {
  // This should never be called on web since we check kIsWeb first
  throw UnsupportedError('FFI is not available on web');
}
