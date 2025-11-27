import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';

// Conditional import for desktop support (not web)
// On web, we import a stub that doesn't export databaseFactoryFfi
import 'database_helper_ffi.dart' 
    if (dart.library.html) 'database_helper_ffi_stub.dart' as ffi_helper;

class DatabaseHelper {
  static bool _initialized = false;
  
  static Future<void> initialize() async {
    if (_initialized) return;
    
    // Initialize database factory for desktop platforms
    // Note: sqflite doesn't work on web - UnifiedStorage handles web storage
    if (!kIsWeb) {
      try {
        // For desktop platforms, initialize the FFI factory
        // This will only compile on non-web platforms where sqflite_common_ffi is available
        databaseFactory = ffi_helper.getDatabaseFactory();
      } catch (e) {
        // If FFI is not available, use default factory (mobile)
      }
    }
    // For mobile platforms, sqflite uses the default factory automatically
    // For web, we use UnifiedStorage with SharedPreferences
    
    _initialized = true;
  }
  
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static const String _databaseName = 'legacy_bookstore.db';
  static const int _databaseVersion = 1;

  Future<Database> get database async {
    // On web, throw an error - UnifiedStorage should be used instead
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite is not supported on web. Use UnifiedStorage instead.'
      );
    }
    
    // Ensure database factory is initialized
    await initialize();
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      throw UnsupportedError(
        'SQLite is not supported on web. Use UnifiedStorage instead.'
      );
    }
    
    // For mobile/desktop, use the standard databases path
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        phone_number TEXT,
        shipping_address TEXT,
        payment_method TEXT,
        is_admin INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Books table (custom books only, default books are in code)
    await db.execute('''
      CREATE TABLE books (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        genre TEXT NOT NULL,
        price REAL NOT NULL,
        rating REAL DEFAULT 0.0,
        review_count INTEGER DEFAULT 0,
        cover_image_url TEXT,
        description TEXT,
        is_bestseller INTEGER DEFAULT 0,
        is_new_arrival INTEGER DEFAULT 0,
        release_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Cart items table
    await db.execute('''
      CREATE TABLE cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        book_id INTEGER NOT NULL,
        quantity INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_email) REFERENCES users(email)
      )
    ''');

    // Wishlist table
    await db.execute('''
      CREATE TABLE wishlist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_email TEXT NOT NULL,
        book_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_email) REFERENCES users(email),
        UNIQUE(user_email, book_id)
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT UNIQUE NOT NULL,
        user_email TEXT NOT NULL,
        total_amount REAL NOT NULL,
        order_date TEXT NOT NULL,
        status TEXT NOT NULL,
        shipping_address TEXT NOT NULL,
        tracking_number TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_email) REFERENCES users(email)
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        book_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(order_id)
      )
    ''');

    // Reviews table
    await db.execute('''
      CREATE TABLE reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        user_email TEXT NOT NULL,
        user_name TEXT NOT NULL,
        rating REAL NOT NULL,
        comment TEXT NOT NULL,
        review_date TEXT NOT NULL,
        likes_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Review likes table
    await db.execute('''
      CREATE TABLE review_likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        review_id INTEGER NOT NULL,
        user_email TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (review_id) REFERENCES reviews(id),
        UNIQUE(review_id, user_email)
      )
    ''');

    // Current user session table
    await db.execute('''
      CREATE TABLE current_session (
        id INTEGER PRIMARY KEY,
        user_email TEXT,
        FOREIGN KEY (user_email) REFERENCES users(email)
      )
    ''');

    // Metadata table for IDs
    await db.execute('''
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value INTEGER NOT NULL
      )
    ''');

    // Initialize metadata
    await db.insert('metadata', {'key': 'next_order_id', 'value': 1});
    await db.insert('metadata', {'key': 'next_review_id', 'value': 1});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here if needed
    if (oldVersion < newVersion) {
      // Add migration logic here
    }
  }

  Future<void> close() async {
    if (kIsWeb) return;
    final db = await database;
    await db.close();
  }

  Future<void> clearAllData() async {
    if (kIsWeb) return;
    final db = await database;
    await db.delete('cart_items');
    await db.delete('wishlist');
    await db.delete('order_items');
    await db.delete('orders');
    await db.delete('reviews');
    await db.delete('review_likes');
    await db.delete('books');
    await db.delete('users');
    await db.delete('current_session');
    await db.delete('metadata');
    
    // Reinitialize metadata
    await db.insert('metadata', {'key': 'next_order_id', 'value': 1});
    await db.insert('metadata', {'key': 'next_review_id', 'value': 1});
  }
}
