import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/user_model.dart';
import '../models/book_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';
import 'book_data_service.dart';
import 'database_helper.dart';
import 'unified_storage.dart';

class AppDataManager {
  static final AppDataManager _instance = AppDataManager._internal();
  factory AppDataManager() => _instance;

  AppDataManager._internal();

  UserAccount? currentUser;
  final List<UserAccount> registeredUsers = [];
  final List<CartItem> shoppingCart = [];
  final List<Book> wishlist = [];
  final List<Order> orderHistory = [];
  final List<BookReview> allReviews = [];
  int nextOrderId = 1;
  int nextReviewId = 1;

  final List<Book> _customBooks = [];
  bool _isInitialized = false;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final UnifiedStorage _storage = UnifiedStorage();

  List<Book> get allBooks {
    final defaultBooks = BookDataService.getAllBooks();
    return [...defaultBooks, ..._customBooks];
  }

  bool isDefaultBook(int bookId) {
    final defaultBooks = BookDataService.getAllBooks();
    return defaultBooks.any((book) => book.id == bookId);
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load only essential data first (fast) - works on both web and mobile
      await loadEssentialData();

      // Initialize with a default admin user if no users exist
      if (registeredUsers.isEmpty) {
        try {
          final adminUser = UserAccount(
            name: 'Admin User',
            email: 'admin@legacy.com',
            password: 'admin123',
            isAdmin: true,
          );
          await _storage.addUser(adminUser);
          registeredUsers.add(adminUser);
        } catch (e) {
          // Error creating admin user: $e
        }
      } else {
        // Check if admin user exists, if not create it
        final hasAdmin = registeredUsers.any(
          (u) => u.email == 'admin@legacy.com',
        );
        if (!hasAdmin) {
          try {
            final adminUser = UserAccount(
              name: 'Admin User',
              email: 'admin@legacy.com',
              password: 'admin123',
              isAdmin: true,
            );
            await _storage.addUser(adminUser);
            registeredUsers.add(adminUser);
          } catch (e) {
            // Error creating admin user: $e
          }
        }
      }

      // Add 4 sample books to database if books table is empty
      if (_customBooks.isEmpty) {
        final sampleBooks = [
          Book(
            id: 1001,
            title: 'Midnight Tales',
            author: 'Sarah Chen',
            genre: 'Fiction',
            price: 24.99,
            rating: 4.8,
            reviewCount: 1234,
            coverImageUrl:
                'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=600&fit=crop',
            description:
                'A collection of captivating stories that take you on a journey through the night. Each tale is carefully crafted to keep you on the edge of your seat.',
            isBestseller: true,
            isNewArrival: false,
            releaseDate: DateTime(2023, 1, 15),
          ),
          Book(
            id: 1002,
            title: 'The Silent Echo',
            author: 'Marcus Webb',
            genre: 'Mystery',
            price: 19.99,
            rating: 4.9,
            reviewCount: 856,
            coverImageUrl:
                'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=400&h=600&fit=crop',
            description:
                'A gripping mystery that will keep you guessing until the very end. Follow the clues as the story unfolds.',
            isBestseller: true,
            isNewArrival: true,
            releaseDate: DateTime(2024, 11, 1),
          ),
          Book(
            id: 1003,
            title: 'Quantum Dreams',
            author: 'Dr. Lisa Park',
            genre: 'Science Fiction',
            price: 29.99,
            rating: 4.7,
            reviewCount: 2341,
            coverImageUrl:
                'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&h=600&fit=crop',
            description:
                'Explore the boundaries of reality in this mind-bending science fiction novel that questions everything we know about the universe.',
            isBestseller: false,
            isNewArrival: true,
            releaseDate: DateTime(2024, 10, 15),
          ),
          Book(
            id: 1004,
            title: 'Dark Matter',
            author: 'Blake Crouch',
            genre: 'Science Fiction',
            price: 16.99,
            rating: 4.6,
            reviewCount: 5678,
            coverImageUrl:
                'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&h=600&fit=crop',
            description:
                'A thrilling journey through parallel universes where every choice creates a new reality.',
            isBestseller: true,
            isNewArrival: false,
            releaseDate: DateTime(2022, 5, 20),
          ),
        ];

        // Add books in parallel for faster initialization
        await Future.wait(sampleBooks.map((book) => _storage.addBook(book)));
        _customBooks.addAll(sampleBooks);
      }

      _isInitialized = true;
    } catch (e) {
      // Initialization error: $e
      // Mark as initialized anyway to prevent infinite loops
      _isInitialized = true;
    }
  }

  // ========== DATA LOADING METHODS ==========

  // Load only essential data for fast startup
  Future<void> loadEssentialData() async {
    try {
      // Load essential data in parallel for faster startup
      final results = await Future.wait([
        _storage.getUsers(),
        _storage.getCurrentUserEmail(),
        _storage.getBooks(),
        _storage.getNextOrderId(),
        _storage.getNextReviewId(),
      ]);

      // Process results
      final users = results[0] as List<UserAccount>;
      final userEmail = results[1] as String?;
      final books = results[2] as List<Book>;
      final orderId = results[3] as int;
      final reviewId = results[4] as int;

      // Update in-memory data
      registeredUsers.clear();
      registeredUsers.addAll(users);

      // Set current user if session exists
      if (userEmail != null) {
        try {
          currentUser = registeredUsers.firstWhere((u) => u.email == userEmail);
        } catch (e) {
          currentUser = null;
        }
      } else {
        currentUser = null;
      }

      // Update books
      _customBooks.clear();
      _customBooks.addAll(books);

      // Update metadata
      nextOrderId = orderId;
      nextReviewId = reviewId;

      // Load user-specific data in background if logged in (non-blocking)
      if (currentUser != null) {
        Future.microtask(() async {
          await _loadUserCart();
          await _loadUserWishlist();
        });
      }

      // Load heavy data in background (non-blocking)
      loadHeavyData();
    } catch (e) {
      // Error loading essential data: $e
    }
  }

  // Load heavy data in background (orders, reviews)
  Future<void> loadHeavyData() async {
    try {
      await _loadOrders();
      await _loadReviews();
    } catch (e) {
      // Error loading heavy data: $e
    }
  }

  // Full data load (for when needed)
  Future<void> loadData() async {
    await loadEssentialData();
    await loadHeavyData();
  }

  Future<void> _loadUsersAndCurrentUser() async {
    final users = await _storage.getUsers();
    registeredUsers.clear();
    registeredUsers.addAll(users);

    final userEmail = await _storage.getCurrentUserEmail();
    if (userEmail != null) {
      currentUser = registeredUsers.firstWhere(
        (u) => u.email == userEmail,
        orElse: () => UserAccount(name: '', email: '', password: ''),
      );
      if (currentUser!.email.isEmpty) {
        currentUser = null;
      }
    } else {
      currentUser = null;
    }
  }

  Future<void> _loadUserCart() async {
    if (currentUser == null) return;

    try {
      final cartItems = await _storage.getCart(currentUser!.email, allBooks);
      shoppingCart.clear();
      shoppingCart.addAll(cartItems);
    } catch (e) {
      // Error loading cart: $e
    }
  }

  Future<void> _loadUserWishlist() async {
    if (currentUser == null) return;

    try {
      final wishlistIds = await _storage.getWishlist(currentUser!.email);
      wishlist.clear();
      for (var bookId in wishlistIds) {
        final book = getBookById(bookId);
        if (book != null) {
          wishlist.add(book);
        }
      }
    } catch (e) {
      // Error loading wishlist: $e
    }
  }

  Future<void> _loadOrders() async {
    try {
      // Use UnifiedStorage to load orders (works on both web and mobile)
      final orders = await _storage.getOrders(null, allBooks);
      orderHistory.clear();
      orderHistory.addAll(orders);
    } catch (e) {
      // Error loading orders: $e
    }
  }

  Future<void> _loadReviews() async {
    try {
      final db = await _dbHelper.database;
      final reviewsList = await db.query(
        'reviews',
        orderBy: 'review_date DESC',
      );

      allReviews.clear();
      for (var reviewRow in reviewsList) {
        final reviewId = reviewRow['id'] as int;

        // Load review likes
        final likesList = await db.query(
          'review_likes',
          where: 'review_id = ?',
          whereArgs: [reviewId],
        );

        final likedByUsers = likesList
            .map((l) => l['user_email'] as String)
            .toList();

        allReviews.add(
          BookReview(
            id: reviewId,
            bookId: reviewRow['book_id'] as int,
            userId: reviewRow['user_email'] as String,
            userName: reviewRow['user_name'] as String,
            rating: (reviewRow['rating'] as num).toDouble(),
            comment: reviewRow['comment'] as String,
            reviewDate: DateTime.parse(reviewRow['review_date'] as String),
            likesCount: likedByUsers.length,
            likedByUsers: likedByUsers,
          ),
        );
      }
    } catch (e) {
      // Error loading reviews: $e
    }
  }

  // ========== USER METHODS ==========

  Future<void> addUser(UserAccount user) async {
    try {
      // Ensure initialization is complete
      if (!_isInitialized) {
        await initialize();
      }

      await _storage.addUser(user);

      // Add to in-memory list
      if (!registeredUsers.any((u) => u.email == user.email)) {
        registeredUsers.add(user);
      }
    } catch (e) {
      // Error adding user: $e
      rethrow;
    }
  }

  Future<bool> loginUser(String email, String password) async {
    try {
      // Ensure initialization is complete
      if (!_isInitialized) {
        await initialize();
      }

      final user = await _storage.getUserByEmail(email);

      if (user != null && user.password == password) {
        currentUser = user;

        // Save current session
        await _storage.setCurrentUserEmail(currentUser!.email);

        // Load user-specific data
        await _loadUserCart();
        await _loadUserWishlist();

        return true;
      }

      return false;
    } catch (e) {
      // Error logging in: $e
      return false;
    }
  }

  Future<void> logoutUser() async {
    try {
      await _storage.setCurrentUserEmail(null);
      currentUser = null;
      shoppingCart.clear();
      wishlist.clear();

      // Sign out from Google if logged in with Google
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn.instance;
        await googleSignIn.signOut();
      } catch (e) {
        // Not logged in with Google, ignore
      }

      // Sign out from Facebook if logged in with Facebook
      try {
        await FacebookAuth.instance.logOut();
      } catch (e) {
        // Not logged in with Facebook, ignore
      }
    } catch (e) {
      // Error logging out: $e
    }
  }

  // Social login - creates user if doesn't exist, then logs in
  Future<bool> loginWithGoogle(
    String email,
    String name,
    String? photoUrl,
  ) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Check if user exists using UnifiedStorage
      UserAccount? existingUser = await _storage.getUserByEmail(email);

      UserAccount user;
      if (existingUser == null) {
        // Create new user from Google account
        user = UserAccount(
          name: name,
          email: email,
          password:
              'google_oauth_${DateTime.now().millisecondsSinceEpoch}', // Dummy password for OAuth users
          isAdmin: false,
        );
        await addUser(user);

        // Reload users to ensure the new user is in the list
        await _loadUsersAndCurrentUser();
      } else {
        // Use existing user
        user = existingUser;
      }

      // Set as current user
      currentUser = user;

      // Save session using UnifiedStorage
      await _storage.setCurrentUserEmail(currentUser!.email);

      // Load user-specific data
      await _loadUserCart();
      await _loadUserWishlist();

      // ✓ Google login successful: ${currentUser!.email}');
      return true;
    } catch (e) {
      // Error with Google login: $e');
      return false;
    }
  }

  Future<bool> loginWithFacebook(
    String email,
    String name,
    String? photoUrl,
  ) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      // Check if user exists using UnifiedStorage
      UserAccount? existingUser = await _storage.getUserByEmail(email);

      UserAccount user;
      if (existingUser == null) {
        // Create new user from Facebook account
        user = UserAccount(
          name: name,
          email: email,
          password:
              'facebook_oauth_${DateTime.now().millisecondsSinceEpoch}', // Dummy password for OAuth users
          isAdmin: false,
        );
        await addUser(user);

        // Reload users to ensure the new user is in the list
        await _loadUsersAndCurrentUser();
      } else {
        // Use existing user
        user = existingUser;
      }

      // Set as current user
      currentUser = user;

      // Save session using UnifiedStorage
      await _storage.setCurrentUserEmail(currentUser!.email);

      // Load user-specific data
      await _loadUserCart();
      await _loadUserWishlist();

      // ✓ Facebook login successful: ${currentUser!.email}');
      return true;
    } catch (e) {
      // Error with Facebook login: $e');
      return false;
    }
  }

  // ========== CART METHODS ==========

  Future<void> addToCart(Book book) async {
    if (currentUser == null) return;

    try {
      await _storage.addToCart(currentUser!.email, book);

      // Update in-memory cart
      final existing = shoppingCart.firstWhere(
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
        shoppingCart.add(CartItem(book: book));
      }
    } catch (e) {
      // Error adding to cart: $e
    }
  }

  Future<void> removeFromCart(int bookId) async {
    if (currentUser == null) return;

    try {
      await _storage.removeFromCart(currentUser!.email, bookId);
      shoppingCart.removeWhere((item) => item.book.id == bookId);
    } catch (e) {
      // Error removing from cart: $e
    }
  }

  Future<void> updateCartQuantity(int bookId, int quantity) async {
    if (currentUser == null) return;

    try {
      await _storage.updateCartQuantity(currentUser!.email, bookId, quantity);

      if (quantity <= 0) {
        shoppingCart.removeWhere((item) => item.book.id == bookId);
      } else {
        final item = shoppingCart.firstWhere(
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
          item.quantity = quantity;
        }
      }
    } catch (e) {
      // Error updating cart quantity: $e
    }
  }

  double getCartTotal() {
    return shoppingCart.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // ========== WISHLIST METHODS ==========

  Future<void> toggleWishlist(Book book) async {
    if (currentUser == null) return;

    try {
      await _storage.toggleWishlist(currentUser!.email, book.id);

      // Update in-memory wishlist
      if (wishlist.any((b) => b.id == book.id)) {
        wishlist.removeWhere((b) => b.id == book.id);
      } else {
        wishlist.add(book);
      }
    } catch (e) {
      // Error toggling wishlist: $e
    }
  }

  bool isInWishlist(int bookId) {
    return wishlist.any((b) => b.id == bookId);
  }

  // ========== ORDER METHODS ==========

  Future<Order> createOrder(String shippingAddress) async {
    if (currentUser == null) {
      throw Exception('User must be logged in to create an order');
    }

    try {
      // Ensure initialization is complete
      if (!_isInitialized) {
        await initialize();
      }

      // Ensure nextOrderId is loaded and valid
      if (nextOrderId < 1) {
        nextOrderId = await _storage.getNextOrderId();
      }
      // Double-check: if still invalid or null, set to 1
      if (nextOrderId < 1) {
        nextOrderId = 1;
        await _storage.setNextOrderId(1);
      }

      final orderId = 'ORD-${nextOrderId.toString().padLeft(6, '0')}';
      final now = DateTime.now();

      // Save cart items before clearing
      final cartItems = List<CartItem>.from(shoppingCart);
      final cartTotal = getCartTotal();
      final totalAmount = cartTotal + 5.99 + (cartTotal * 0.08);

      // Create order object
      final order = Order(
        orderId: orderId,
        userId: currentUser!.email,
        items: cartItems,
        totalAmount: totalAmount,
        orderDate: now,
        status: OrderStatus.confirmed,
        shippingAddress: shippingAddress,
        trackingNumber: 'TRK${now.millisecondsSinceEpoch}',
      );

      // Save order to storage
      await _storage.addOrder(order);

      // Clear cart
      shoppingCart.clear();
      await _storage.saveCart(currentUser!.email, []);

      // Update next order ID
      nextOrderId++;
      await _storage.setNextOrderId(nextOrderId);

      // Reload orders
      await _loadOrders();

      return order;
    } catch (e) {
      // Error creating order: $e
      rethrow;
    }
  }

  List<Order> getUserOrders() {
    if (currentUser == null) return [];
    return orderHistory
        .where((order) => order.userId == currentUser!.email)
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      // Update in storage
      await _storage.updateOrderStatus(orderId, newStatus);

      // Update in-memory order
      final order = orderHistory.firstWhere(
        (o) => o.orderId == orderId,
        orElse: () => Order(
          orderId: '',
          userId: '',
          items: [],
          totalAmount: 0,
          orderDate: DateTime.now(),
          shippingAddress: '',
        ),
      );
      if (order.orderId == orderId) {
        order.status = newStatus;
      }
    } catch (e) {
      // Error updating order status: $e
      rethrow;
    }
  }

  // ========== REVIEW METHODS ==========

  Future<void> addReview(BookReview review) async {
    try {
      await _storage.addReview(review);

      allReviews.add(review);

      // Update next review ID
      nextReviewId++;
      await _storage.setNextReviewId(nextReviewId);
    } catch (e) {
      // Error adding review: $e
      rethrow;
    }
  }

  List<BookReview> getBookReviews(int bookId) {
    return allReviews.where((review) => review.bookId == bookId).toList();
  }

  Future<void> toggleReviewLike(int reviewId, String userId) async {
    try {
      final db = await _dbHelper.database;
      final existing = await db.query(
        'review_likes',
        where: 'review_id = ? AND user_email = ?',
        whereArgs: [reviewId, userId],
        limit: 1,
      );

      final review = allReviews.firstWhere(
        (r) => r.id == reviewId,
        orElse: () => BookReview(
          id: -1,
          bookId: -1,
          userId: '',
          userName: '',
          rating: 0,
          comment: '',
          reviewDate: DateTime.now(),
        ),
      );

      if (review.id == reviewId) {
        if (existing.isNotEmpty) {
          // Unlike
          await db.delete(
            'review_likes',
            where: 'review_id = ? AND user_email = ?',
            whereArgs: [reviewId, userId],
          );
          review.likedByUsers.remove(userId);
          review.likesCount--;
        } else {
          // Like
          await db.insert('review_likes', {
            'review_id': reviewId,
            'user_email': userId,
            'created_at': DateTime.now().toIso8601String(),
          });
          review.likedByUsers.add(userId);
          review.likesCount++;
        }
      }
    } catch (e) {
      // Error toggling review like: $e');
    }
  }

  bool hasUserLikedReview(int reviewId, String userId) {
    final review = allReviews.firstWhere(
      (r) => r.id == reviewId,
      orElse: () => BookReview(
        id: -1,
        bookId: -1,
        userId: '',
        userName: '',
        rating: 0,
        comment: '',
        reviewDate: DateTime.now(),
      ),
    );
    return review.likedByUsers.contains(userId);
  }

  // ========== BOOK MANAGEMENT METHODS ==========

  Future<void> addBook(Book book) async {
    try {
      await _storage.addBook(book);
      if (!_customBooks.any((b) => b.id == book.id)) {
        _customBooks.add(book);
      }
    } catch (e) {
      // Error adding book: $e
      rethrow;
    }
  }

  Future<void> removeBook(int bookId) async {
    try {
      await _storage.removeBook(bookId);
      _customBooks.removeWhere((book) => book.id == bookId);
    } catch (e) {
      // Error removing book: $e
      rethrow;
    }
  }

  Future<void> updateBook(Book updatedBook) async {
    try {
      await _storage.updateBook(updatedBook);

      final index = _customBooks.indexWhere(
        (book) => book.id == updatedBook.id,
      );
      if (index != -1) {
        _customBooks[index] = updatedBook;
      } else {
        _customBooks.add(updatedBook);
      }
    } catch (e) {
      // Error updating book: $e
      rethrow;
    }
  }

  Book? getBookById(int bookId) {
    try {
      return allBooks.firstWhere((book) => book.id == bookId);
    } catch (e) {
      return null;
    }
  }
}
