import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/book_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';
import 'database_helper.dart';

/// Unified storage that uses SQLite for mobile/desktop and SharedPreferences for web
class UnifiedStorage {
  static final UnifiedStorage _instance = UnifiedStorage._internal();
  factory UnifiedStorage() => _instance;
  UnifiedStorage._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();
  SharedPreferences? _prefs;
  bool _prefsInitialized = false;

  Future<void> _ensurePrefs() async {
    if (!kIsWeb || _prefsInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _prefsInitialized = true;
  }

  // ========== USERS ==========
  Future<List<UserAccount>> getUsers() async {
    if (kIsWeb) {
      await _ensurePrefs();
      final usersJson = _prefs!.getString('users') ?? '[]';
      final List<dynamic> usersList = json.decode(usersJson);
      return usersList.map((u) => UserAccount.fromJson(u)).toList();
    } else {
      final db = await _dbHelper.database;
      final usersList = await db.query('users');
      return usersList
          .map(
            (u) => UserAccount(
              name: u['name'] as String,
              email: u['email'] as String,
              password: u['password'] as String,
              phoneNumber: u['phone_number'] as String? ?? '',
              shippingAddress: u['shipping_address'] as String? ?? '',
              paymentMethod: u['payment_method'] as String? ?? '',
              isAdmin: (u['is_admin'] as int? ?? 0) == 1,
            ),
          )
          .toList();
    }
  }

  Future<void> saveUsers(List<UserAccount> users) async {
    if (kIsWeb) {
      await _ensurePrefs();
      final usersJson = json.encode(users.map((u) => u.toJson()).toList());
      await _prefs!.setString('users', usersJson);
    } else {
      // SQLite handles this through individual inserts/updates
    }
  }

  Future<void> addUser(UserAccount user) async {
    if (kIsWeb) {
      final users = await getUsers();
      if (!users.any((u) => u.email == user.email)) {
        users.add(user);
        await saveUsers(users);
      }
    } else {
      final db = await _dbHelper.database;
      await db.insert('users', {
        'name': user.name,
        'email': user.email,
        'password': user.password,
        'phone_number': user.phoneNumber,
        'shipping_address': user.shippingAddress,
        'payment_method': user.paymentMethod,
        'is_admin': user.isAdmin ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<UserAccount?> getUserByEmail(String email) async {
    final users = await getUsers();
    try {
      return users.firstWhere((u) => u.email == email);
    } catch (e) {
      return null;
    }
  }

  // ========== BOOKS ==========
  Future<List<Book>> getBooks() async {
    if (kIsWeb) {
      await _ensurePrefs();
      final booksJson = _prefs!.getString('books') ?? '[]';
      final List<dynamic> booksList = json.decode(booksJson);
      return booksList.map((b) => Book.fromJson(b)).toList();
    } else {
      final db = await _dbHelper.database;
      final booksList = await db.query('books');
      return booksList
          .map(
            (b) => Book(
              id: b['id'] as int,
              title: b['title'] as String,
              author: b['author'] as String,
              genre: b['genre'] as String,
              price: (b['price'] as num).toDouble(),
              rating: (b['rating'] as num).toDouble(),
              reviewCount: b['review_count'] as int? ?? 0,
              coverImageUrl: b['cover_image_url'] as String? ?? '',
              description: b['description'] as String? ?? '',
              isBestseller: (b['is_bestseller'] as int? ?? 0) == 1,
              isNewArrival: (b['is_new_arrival'] as int? ?? 0) == 1,
              releaseDate: DateTime.parse(b['release_date'] as String),
            ),
          )
          .toList();
    }
  }

  Future<void> saveBooks(List<Book> books) async {
    if (kIsWeb) {
      await _ensurePrefs();
      final booksJson = json.encode(books.map((b) => b.toJson()).toList());
      await _prefs!.setString('books', booksJson);
    }
  }

  Future<void> addBook(Book book) async {
    if (kIsWeb) {
      final books = await getBooks();
      if (!books.any((b) => b.id == book.id)) {
        books.add(book);
        await saveBooks(books);
      }
    } else {
      final db = await _dbHelper.database;
      await db.insert('books', {
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'genre': book.genre,
        'price': book.price,
        'rating': book.rating,
        'review_count': book.reviewCount,
        'cover_image_url': book.coverImageUrl,
        'description': book.description,
        'is_bestseller': book.isBestseller ? 1 : 0,
        'is_new_arrival': book.isNewArrival ? 1 : 0,
        'release_date': book.releaseDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> removeBook(int bookId) async {
    if (kIsWeb) {
      final books = await getBooks();
      books.removeWhere((b) => b.id == bookId);
      await saveBooks(books);
    } else {
      final db = await _dbHelper.database;
      await db.delete('books', where: 'id = ?', whereArgs: [bookId]);
    }
  }

  Future<void> updateBook(Book book) async {
    if (kIsWeb) {
      final books = await getBooks();
      final index = books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        books[index] = book;
        await saveBooks(books);
      }
    } else {
      final db = await _dbHelper.database;
      await db.update(
        'books',
        {
          'title': book.title,
          'author': book.author,
          'genre': book.genre,
          'price': book.price,
          'rating': book.rating,
          'review_count': book.reviewCount,
          'cover_image_url': book.coverImageUrl,
          'description': book.description,
          'is_bestseller': book.isBestseller ? 1 : 0,
          'is_new_arrival': book.isNewArrival ? 1 : 0,
          'release_date': book.releaseDate.toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [book.id],
      );
    }
  }

  // ========== CART ==========
  Future<List<CartItem>> getCart(String userEmail, List<Book> allBooks) async {
    if (kIsWeb) {
      await _ensurePrefs();
      final cartJson = _prefs!.getString('cart_$userEmail') ?? '[]';
      final List<dynamic> cartList = json.decode(cartJson);
      final cartItems = <CartItem>[];
      for (var item in cartList) {
        final bookId = item['bookId'] as int;
        final book = allBooks.firstWhere(
          (b) => b.id == bookId,
          orElse: () => Book(
            id: -1,
            title: '',
            author: '',
            genre: '',
            price: 0,
            rating: 0,
            reviewCount: 0,
            coverImageUrl: '',
            description: '',
            releaseDate: DateTime.now(),
          ),
        );
        if (book.id != -1) {
          cartItems.add(
            CartItem(book: book, quantity: item['quantity'] as int? ?? 1),
          );
        }
      }
      return cartItems;
    } else {
      final db = await _dbHelper.database;
      final cartList = await db.query(
        'cart_items',
        where: 'user_email = ?',
        whereArgs: [userEmail],
      );
      final cartItems = <CartItem>[];
      for (var cartRow in cartList) {
        final bookId = cartRow['book_id'] as int;
        final book = allBooks.firstWhere(
          (b) => b.id == bookId,
          orElse: () => Book(
            id: -1,
            title: '',
            author: '',
            genre: '',
            price: 0,
            rating: 0,
            reviewCount: 0,
            coverImageUrl: '',
            description: '',
            releaseDate: DateTime.now(),
          ),
        );
        if (book.id != -1) {
          cartItems.add(
            CartItem(book: book, quantity: cartRow['quantity'] as int? ?? 1),
          );
        }
      }
      return cartItems;
    }
  }

  Future<void> saveCart(String userEmail, List<CartItem> cart) async {
    if (kIsWeb) {
      await _ensurePrefs();
      final cartJson = json.encode(
        cart
            .map(
              (item) => ({'bookId': item.book.id, 'quantity': item.quantity}),
            )
            .toList(),
      );
      await _prefs!.setString('cart_$userEmail', cartJson);
    } else {
      final db = await _dbHelper.database;
      await db.delete(
        'cart_items',
        where: 'user_email = ?',
        whereArgs: [userEmail],
      );
      for (var item in cart) {
        await db.insert('cart_items', {
          'user_email': userEmail,
          'book_id': item.book.id,
          'quantity': item.quantity,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  Future<void> addToCart(String userEmail, Book book) async {
    if (kIsWeb) {
      final cart = await getCart(userEmail, [book]);
      final existing = cart.firstWhere(
        (item) => item.book.id == book.id,
        orElse: () => CartItem(
          book: Book(
            id: -1,
            title: '',
            author: '',
            genre: '',
            price: 0,
            rating: 0,
            reviewCount: 0,
            coverImageUrl: '',
            description: '',
            releaseDate: DateTime.now(),
          ),
        ),
      );
      if (existing.book.id == book.id) {
        existing.quantity++;
      } else {
        cart.add(CartItem(book: book));
      }
      await saveCart(userEmail, cart);
    } else {
      final db = await _dbHelper.database;
      final existing = await db.query(
        'cart_items',
        where: 'user_email = ? AND book_id = ?',
        whereArgs: [userEmail, book.id],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        await db.update(
          'cart_items',
          {'quantity': (existing.first['quantity'] as int) + 1},
          where: 'user_email = ? AND book_id = ?',
          whereArgs: [userEmail, book.id],
        );
      } else {
        await db.insert('cart_items', {
          'user_email': userEmail,
          'book_id': book.id,
          'quantity': 1,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  Future<void> removeFromCart(String userEmail, int bookId) async {
    if (kIsWeb) {
      final cart = await getCart(userEmail, []);
      cart.removeWhere((item) => item.book.id == bookId);
      await saveCart(userEmail, cart);
    } else {
      final db = await _dbHelper.database;
      await db.delete(
        'cart_items',
        where: 'user_email = ? AND book_id = ?',
        whereArgs: [userEmail, bookId],
      );
    }
  }

  Future<void> updateCartQuantity(
    String userEmail,
    int bookId,
    int quantity,
  ) async {
    if (kIsWeb) {
      final cart = await getCart(userEmail, []);
      final item = cart.firstWhere(
        (item) => item.book.id == bookId,
        orElse: () => CartItem(
          book: Book(
            id: -1,
            title: '',
            author: '',
            genre: '',
            price: 0,
            rating: 0,
            reviewCount: 0,
            coverImageUrl: '',
            description: '',
            releaseDate: DateTime.now(),
          ),
        ),
      );
      if (item.book.id == bookId) {
        if (quantity <= 0) {
          cart.removeWhere((i) => i.book.id == bookId);
        } else {
          item.quantity = quantity;
        }
        await saveCart(userEmail, cart);
      }
    } else {
      final db = await _dbHelper.database;
      if (quantity <= 0) {
        await removeFromCart(userEmail, bookId);
      } else {
        await db.update(
          'cart_items',
          {'quantity': quantity},
          where: 'user_email = ? AND book_id = ?',
          whereArgs: [userEmail, bookId],
        );
      }
    }
  }

  // ========== WISHLIST ==========
  Future<List<int>> getWishlist(String userEmail) async {
    if (kIsWeb) {
      await _ensurePrefs();
      final wishlistJson = _prefs!.getString('wishlist_$userEmail') ?? '[]';
      return List<int>.from(json.decode(wishlistJson));
    } else {
      final db = await _dbHelper.database;
      final wishlistList = await db.query(
        'wishlist',
        where: 'user_email = ?',
        whereArgs: [userEmail],
      );
      return wishlistList.map((w) => w['book_id'] as int).toList();
    }
  }

  Future<void> saveWishlist(String userEmail, List<int> bookIds) async {
    if (kIsWeb) {
      await _ensurePrefs();
      await _prefs!.setString('wishlist_$userEmail', json.encode(bookIds));
    } else {
      final db = await _dbHelper.database;
      await db.delete(
        'wishlist',
        where: 'user_email = ?',
        whereArgs: [userEmail],
      );
      for (var bookId in bookIds) {
        await db.insert('wishlist', {
          'user_email': userEmail,
          'book_id': bookId,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  Future<void> toggleWishlist(String userEmail, int bookId) async {
    final wishlist = await getWishlist(userEmail);
    if (wishlist.contains(bookId)) {
      wishlist.remove(bookId);
    } else {
      wishlist.add(bookId);
    }
    await saveWishlist(userEmail, wishlist);
  }

  // ========== ORDERS ==========
  Future<List<Order>> getOrders(String? userEmail, List<Book> allBooks) async {
    if (kIsWeb) {
      await _ensurePrefs();
      final ordersJson = _prefs!.getString('orders') ?? '[]';
      final List<dynamic> ordersList = json.decode(ordersJson);
      final orders = ordersList.map((o) {
        // Use Order.fromJson which properly handles CartItem deserialization
        // But we need to ensure books exist in allBooks
        final order = Order.fromJson(o);

        // Validate that all books in order items exist
        final validItems = <CartItem>[];
        for (var item in order.items) {
          // Check if book exists in allBooks
          final book = allBooks.firstWhere(
            (b) => b.id == item.book.id,
            orElse: () => Book(
              id: -1,
              title: '',
              author: '',
              genre: '',
              price: 0,
              rating: 0,
              reviewCount: 0,
              coverImageUrl: '',
              description: '',
              releaseDate: DateTime.now(),
            ),
          );
          // Only add item if book is valid (id > 0)
          if (book.id > 0) {
            validItems.add(CartItem(book: book, quantity: item.quantity));
          }
        }

        // Return order with validated items
        return Order(
          orderId: order.orderId,
          userId: order.userId,
          items: validItems,
          totalAmount: order.totalAmount,
          orderDate: order.orderDate,
          status: order.status,
          shippingAddress: order.shippingAddress,
          trackingNumber: order.trackingNumber,
        );
      }).toList();

      if (userEmail != null) {
        return orders.where((o) => o.userId == userEmail).toList();
      }
      return orders;
    } else {
      final db = await _dbHelper.database;
      final ordersList = await db.query(
        'orders',
        where: userEmail != null ? 'user_email = ?' : null,
        whereArgs: userEmail != null ? [userEmail] : null,
        orderBy: 'order_date DESC',
      );

      final orders = <Order>[];
      for (var orderRow in ordersList) {
        final orderId = orderRow['order_id'] as String;
        final itemsList = await db.query(
          'order_items',
          where: 'order_id = ?',
          whereArgs: [orderId],
        );

        final items = <CartItem>[];
        for (var itemRow in itemsList) {
          final bookId = itemRow['book_id'] as int;
          final book = allBooks.firstWhere(
            (b) => b.id == bookId,
            orElse: () => Book(
              id: -1,
              title: '',
              author: '',
              genre: '',
              price: 0,
              rating: 0,
              reviewCount: 0,
              coverImageUrl: '',
              description: '',
              releaseDate: DateTime.now(),
            ),
          );
          if (book.id != -1) {
            items.add(
              CartItem(book: book, quantity: itemRow['quantity'] as int? ?? 1),
            );
          }
        }

        orders.add(
          Order(
            orderId: orderId,
            userId: orderRow['user_email'] as String,
            items: items,
            totalAmount: (orderRow['total_amount'] as num).toDouble(),
            orderDate: DateTime.parse(orderRow['order_date'] as String),
            status: OrderStatus.values.firstWhere(
              (e) => e.name == orderRow['status'] as String,
              orElse: () => OrderStatus.pending,
            ),
            shippingAddress: orderRow['shipping_address'] as String,
            trackingNumber: orderRow['tracking_number'] as String? ?? '',
          ),
        );
      }
      return orders;
    }
  }

  Future<void> addOrder(Order order) async {
    if (kIsWeb) {
      await _ensurePrefs();
      final ordersJson = _prefs!.getString('orders') ?? '[]';
      final List<dynamic> ordersList = json.decode(ordersJson);
      // Add the new order as JSON directly
      ordersList.add(order.toJson());
      await _prefs!.setString('orders', json.encode(ordersList));
    } else {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      await db.insert('orders', {
        'order_id': order.orderId,
        'user_email': order.userId,
        'total_amount': order.totalAmount,
        'order_date': order.orderDate.toIso8601String(),
        'status': order.status.name,
        'shipping_address': order.shippingAddress,
        'tracking_number': order.trackingNumber,
        'created_at': now.toIso8601String(),
      });

      for (var item in order.items) {
        await db.insert('order_items', {
          'order_id': order.orderId,
          'book_id': item.book.id,
          'quantity': item.quantity,
          'price': item.book.price,
          'created_at': now.toIso8601String(),
        });
      }
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    if (kIsWeb) {
      final orders = await getOrders(null, []);
      final orderIndex = orders.indexWhere((o) => o.orderId == orderId);
      if (orderIndex != -1) {
        orders[orderIndex].status = newStatus;
        await _ensurePrefs();
        final ordersJson = json.encode(orders.map((o) => o.toJson()).toList());
        await _prefs!.setString('orders', ordersJson);
      }
    } else {
      final db = await _dbHelper.database;
      await db.update(
        'orders',
        {'status': newStatus.name},
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
    }
  }

  // ========== REVIEWS ==========
  Future<List<BookReview>> getReviews() async {
    if (kIsWeb) {
      await _ensurePrefs();
      final reviewsJson = _prefs!.getString('reviews') ?? '[]';
      final List<dynamic> reviewsList = json.decode(reviewsJson);
      return reviewsList.map((r) => BookReview.fromJson(r)).toList();
    } else {
      final db = await _dbHelper.database;
      final reviewsList = await db.query('reviews');
      return reviewsList
          .map(
            (r) => BookReview(
              id: r['id'] as int,
              bookId: r['book_id'] as int,
              userId: r['user_email'] as String,
              userName: r['user_name'] as String,
              rating: (r['rating'] as num).toDouble(),
              comment: r['comment'] as String,
              reviewDate: DateTime.parse(r['review_date'] as String),
              likesCount: r['likes_count'] as int? ?? 0,
              likedByUsers: [],
            ),
          )
          .toList();
    }
  }

  Future<void> addReview(BookReview review) async {
    if (kIsWeb) {
      final reviews = await getReviews();
      reviews.add(review);
      await _ensurePrefs();
      final reviewsJson = json.encode(reviews.map((r) => r.toJson()).toList());
      await _prefs!.setString('reviews', reviewsJson);
    } else {
      final db = await _dbHelper.database;
      await db.insert('reviews', {
        'id': review.id,
        'book_id': review.bookId,
        'user_email': review.userId,
        'user_name': review.userName,
        'rating': review.rating,
        'comment': review.comment,
        'review_date': review.reviewDate.toIso8601String(),
        'likes_count': review.likesCount,
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // ========== SESSION ==========
  Future<String?> getCurrentUserEmail() async {
    if (kIsWeb) {
      await _ensurePrefs();
      return _prefs!.getString('current_user_email');
    } else {
      final db = await _dbHelper.database;
      final sessionList = await db.query('current_session', limit: 1);
      if (sessionList.isNotEmpty) {
        return sessionList.first['user_email'] as String?;
      }
      return null;
    }
  }

  Future<void> setCurrentUserEmail(String? email) async {
    if (kIsWeb) {
      await _ensurePrefs();
      if (email != null) {
        await _prefs!.setString('current_user_email', email);
      } else {
        await _prefs!.remove('current_user_email');
      }
    } else {
      final db = await _dbHelper.database;
      await db.delete('current_session');
      if (email != null) {
        await db.insert('current_session', {'id': 1, 'user_email': email});
      }
    }
  }

  // ========== METADATA ==========
  Future<int> getNextOrderId() async {
    if (kIsWeb) {
      await _ensurePrefs();
      return _prefs!.getInt('next_order_id') ?? 1;
    } else {
      final db = await _dbHelper.database;
      final nextOrderIdRow = await db.query(
        'metadata',
        where: 'key = ?',
        whereArgs: ['next_order_id'],
      );
      return nextOrderIdRow.isNotEmpty
          ? (nextOrderIdRow.first['value'] as int? ?? 1)
          : 1;
    }
  }

  Future<void> setNextOrderId(int id) async {
    if (kIsWeb) {
      await _ensurePrefs();
      await _prefs!.setInt('next_order_id', id);
    } else {
      final db = await _dbHelper.database;
      // Check if metadata entry exists, if not create it
      final existing = await db.query(
        'metadata',
        where: 'key = ?',
        whereArgs: ['next_order_id'],
        limit: 1,
      );
      if (existing.isEmpty) {
        await db.insert('metadata', {
          'key': 'next_order_id',
          'value': id,
        });
      } else {
        await db.update(
          'metadata',
          {'value': id},
          where: 'key = ?',
          whereArgs: ['next_order_id'],
        );
      }
    }
  }

  Future<int> getNextReviewId() async {
    if (kIsWeb) {
      await _ensurePrefs();
      return _prefs!.getInt('next_review_id') ?? 1;
    } else {
      final db = await _dbHelper.database;
      final nextReviewIdRow = await db.query(
        'metadata',
        where: 'key = ?',
        whereArgs: ['next_review_id'],
      );
      return nextReviewIdRow.isNotEmpty
          ? (nextReviewIdRow.first['value'] as int? ?? 1)
          : 1;
    }
  }

  Future<void> setNextReviewId(int id) async {
    if (kIsWeb) {
      await _ensurePrefs();
      await _prefs!.setInt('next_review_id', id);
    } else {
      final db = await _dbHelper.database;
      // Check if metadata entry exists, if not create it
      final existing = await db.query(
        'metadata',
        where: 'key = ?',
        whereArgs: ['next_review_id'],
        limit: 1,
      );
      if (existing.isEmpty) {
        await db.insert('metadata', {
          'key': 'next_review_id',
          'value': id,
        });
      } else {
        await db.update(
          'metadata',
          {'value': id},
          where: 'key = ?',
          whereArgs: ['next_review_id'],
        );
      }
    }
  }
}
