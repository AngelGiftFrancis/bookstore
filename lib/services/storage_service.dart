import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/book_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';

/// Unified storage service that uses SQLite for mobile/desktop
/// and SharedPreferences for web
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
    }
    _initialized = true;
  }

  bool get isWeb => kIsWeb;

  // ========== USERS ==========
  Future<List<UserAccount>> getUsers() async {
    if (!kIsWeb) return []; // SQLite handles this

    await initialize();
    final usersJson = _prefs!.getString('users') ?? '[]';
    final List<dynamic> usersList = json.decode(usersJson);
    return usersList.map((u) => UserAccount.fromJson(u)).toList();
  }

  Future<void> saveUsers(List<UserAccount> users) async {
    if (!kIsWeb) return; // SQLite handles this

    await initialize();
    final usersJson = json.encode(users.map((u) => u.toJson()).toList());
    await _prefs!.setString('users', usersJson);
  }

  Future<void> addUser(UserAccount user) async {
    if (!kIsWeb) return; // SQLite handles this

    final users = await getUsers();
    users.add(user);
    await saveUsers(users);
  }

  // ========== BOOKS ==========
  Future<List<Book>> getBooks() async {
    if (!kIsWeb) return []; // SQLite handles this

    await initialize();
    final booksJson = _prefs!.getString('books') ?? '[]';
    final List<dynamic> booksList = json.decode(booksJson);
    return booksList.map((b) => Book.fromJson(b)).toList();
  }

  Future<void> saveBooks(List<Book> books) async {
    if (!kIsWeb) return; // SQLite handles this

    await initialize();
    final booksJson = json.encode(books.map((b) => b.toJson()).toList());
    await _prefs!.setString('books', booksJson);
  }

  Future<void> addBook(Book book) async {
    if (!kIsWeb) return; // SQLite handles this

    final books = await getBooks();
    books.add(book);
    await saveBooks(books);
  }

  Future<void> removeBook(int bookId) async {
    if (!kIsWeb) return; // SQLite handles this

    final books = await getBooks();
    books.removeWhere((b) => b.id == bookId);
    await saveBooks(books);
  }

  Future<void> updateBook(Book book) async {
    if (!kIsWeb) return; // SQLite handles this

    final books = await getBooks();
    final index = books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      books[index] = book;
      await saveBooks(books);
    }
  }

  // ========== CART ==========
  Future<List<CartItem>> getCart(String userEmail) async {
    if (!kIsWeb) return []; // SQLite handles this

    await initialize();
    final cartJson = _prefs!.getString('cart_$userEmail') ?? '[]';
    final List<dynamic> cartList = json.decode(cartJson) as List<dynamic>;
    // Note: We'll need to reconstruct CartItem with Book objects
    return []; // Simplified for now
  }

  Future<void> saveCart(String userEmail, List<CartItem> cart) async {
    if (!kIsWeb) return; // SQLite handles this

    await initialize();
    final cartJson = json.encode(
      cart
          .map((item) => {'bookId': item.book.id, 'quantity': item.quantity})
          .toList(),
    );
    await _prefs!.setString('cart_$userEmail', cartJson);
  }

  // ========== WISHLIST ==========
  Future<List<int>> getWishlist(String userEmail) async {
    if (!kIsWeb) return []; // SQLite handles this

    await initialize();
    final wishlistJson = _prefs!.getString('wishlist_$userEmail') ?? '[]';
    return List<int>.from(json.decode(wishlistJson));
  }

  Future<void> saveWishlist(String userEmail, List<int> bookIds) async {
    if (!kIsWeb) return; // SQLite handles this

    await initialize();
    await _prefs!.setString('wishlist_$userEmail', json.encode(bookIds));
  }

  // ========== ORDERS ==========
  Future<List<Order>> getOrders(String? userEmail) async {
    if (!kIsWeb) return []; // SQLite handles this

    await initialize();
    final ordersJson = _prefs!.getString('orders') ?? '[]';
    final List<dynamic> ordersList = json.decode(ordersJson);
    final orders = ordersList.map((o) => Order.fromJson(o)).toList();
    if (userEmail != null) {
      return orders.where((o) => o.userId == userEmail).toList();
    }
    return orders;
  }

  Future<void> saveOrders(List<Order> orders) async {
    if (!kIsWeb) return; // SQLite handles this

    await initialize();
    final ordersJson = json.encode(orders.map((o) => o.toJson()).toList());
    await _prefs!.setString('orders', ordersJson);
  }

  Future<void> addOrder(Order order) async {
    if (!kIsWeb) return; // SQLite handles this

    final orders = await getOrders(null);
    orders.add(order);
    await saveOrders(orders);
  }

  // ========== REVIEWS ==========
  Future<List<BookReview>> getReviews() async {
    if (!kIsWeb) return []; // SQLite handles this

    await initialize();
    final reviewsJson = _prefs!.getString('reviews') ?? '[]';
    final List<dynamic> reviewsList = json.decode(reviewsJson);
    return reviewsList.map((r) => BookReview.fromJson(r)).toList();
  }

  Future<void> saveReviews(List<BookReview> reviews) async {
    if (!kIsWeb) return; // SQLite handles this

    await initialize();
    final reviewsJson = json.encode(reviews.map((r) => r.toJson()).toList());
    await _prefs!.setString('reviews', reviewsJson);
  }

  Future<void> addReview(BookReview review) async {
    if (!kIsWeb) return; // SQLite handles this

    final reviews = await getReviews();
    reviews.add(review);
    await saveReviews(reviews);
  }

  // ========== SESSION ==========
  Future<String?> getCurrentUserEmail() async {
    if (!kIsWeb) return null; // SQLite handles this

    await initialize();
    return _prefs!.getString('current_user_email');
  }

  Future<void> setCurrentUserEmail(String? email) async {
    if (!kIsWeb) return; // SQLite handles this

    await initialize();
    if (email != null) {
      await _prefs!.setString('current_user_email', email);
    } else {
      await _prefs!.remove('current_user_email');
    }
  }

  // ========== METADATA ==========
  Future<int> getNextOrderId() async {
    if (!kIsWeb) return 1; // SQLite handles this

    await initialize();
    return _prefs!.getInt('next_order_id') ?? 1;
  }

  Future<void> setNextOrderId(int id) async {
    if (!kIsWeb) return; // SQLite handles this

    await initialize();
    await _prefs!.setInt('next_order_id', id);
  }

  Future<int> getNextReviewId() async {
    if (!kIsWeb) return 1; // SQLite handles this

    await initialize();
    return _prefs!.getInt('next_review_id') ?? 1;
  }

  Future<void> setNextReviewId(int id) async {
    if (!kIsWeb) return; // SQLite handles this

    await initialize();
    await _prefs!.setInt('next_review_id', id);
  }
}
