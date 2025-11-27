# Legacy Book Store - Complete Documentation

## Table of Contents

1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Features Documentation](#features-documentation)
4. [User Guide](#user-guide)
5. [Admin Guide](#admin-guide)
6. [Developer Guide](#developer-guide)
7. [API Reference](#api-reference)
8. [Database Schema](#database-schema)
9. [Testing Guide](#testing-guide)
10. [Deployment Guide](#deployment-guide)

---

## 1. Project Overview

### 1.1 Application Name
**Legacy** - A modern book store application

### 1.2 Purpose
Legacy is a comprehensive e-commerce application designed for book retail. It provides users with a seamless shopping experience while offering administrators powerful tools to manage inventory, users, and orders.

### 1.3 Technology Stack
- **Frontend Framework**: Flutter 3.8.0+
- **Programming Language**: Dart
- **UI Framework**: Material Design 3
- **State Management**: Singleton Pattern with AppDataManager
- **PDF Generation**: pdf package (v3.11.1)
- **Printing**: printing package (v5.13.3)
- **Local Storage**: shared_preferences (v2.2.2)

### 1.4 Platform Support
- Android (API 21+)
- iOS (iOS 12+)
- Web (Chrome, Firefox, Safari, Edge)
- Windows
- macOS
- Linux

---

## 2. System Architecture

### 2.1 Architecture Pattern
The application follows a **Layered Architecture** pattern:

```
┌─────────────────────────────────────┐
│         Presentation Layer         │
│    (Screens, Widgets, Theme)        │
├─────────────────────────────────────┤
│         Business Logic Layer        │
│    (Services, Data Managers)        │
├─────────────────────────────────────┤
│          Data Layer                 │
│    (Models, Data Services)          │
└─────────────────────────────────────┘
```

### 2.2 Project Structure

```
lib/
├── main.dart                    # Application entry point
│
├── models/                      # Data Models
│   ├── book_model.dart          # Book entity
│   ├── user_model.dart          # User account entity
│   ├── cart_item_model.dart     # Shopping cart item
│   ├── order_model.dart         # Order entity with status
│   └── review_model.dart        # Book review entity
│
├── screens/                     # Application Screens
│   ├── splash_screen.dart       # App launch screen
│   ├── login_screen.dart        # User authentication
│   ├── signup_screen.dart       # User registration
│   ├── forgot_password_screen.dart  # Password recovery
│   ├── home_screen.dart         # Main dashboard
│   ├── catalog_screen.dart      # Book catalog with filters
│   ├── search_screen.dart       # Search functionality
│   ├── book_detail_screen.dart  # Book details and reviews
│   ├── cart_screen.dart         # Shopping cart
│   ├── checkout_screen.dart     # Order checkout
│   ├── wishlist_screen.dart     # User wishlist
│   ├── profile_screen.dart       # User profile management
│   ├── orders_screen.dart       # Order history
│   ├── order_detail_screen.dart # Order details
│   ├── review_screen.dart       # Add/view reviews
│   └── admin_panel_screen.dart  # Admin dashboard
│
├── services/                    # Business Logic
│   ├── app_data_manager.dart    # Centralized data management
│   └── book_data_service.dart   # Book catalog service
│
├── widgets/                     # Reusable Components
│   └── book_card_widget.dart    # Book card component
│
└── theme/                       # Theming
    └── app_colors.dart          # Color palette
```

### 2.3 Data Flow

1. **User Interaction** → Screen Widget
2. **Screen Widget** → AppDataManager (Service Layer)
3. **AppDataManager** → Data Models / Services
4. **Data Update** → State Management → UI Update

---

## 3. Features Documentation

### 3.1 User Authentication

#### 3.1.1 User Registration
- **Screen**: `SignUpScreen`
- **Fields Required**:
  - Full Name (required)
  - Email Address (required, validated)
  - Phone Number (optional)
  - Password (required, minimum 6 characters)
  - Confirm Password (required, must match)
- **Validation**:
  - Email format validation
  - Password strength (minimum 6 characters)
  - Password confirmation match
  - Duplicate email check
- **Process**: Creates new user account and automatically logs in

#### 3.1.2 User Login
- **Screen**: `LoginScreen`
- **Fields Required**:
  - Email Address
  - Password
- **Validation**: Email and password must match registered user
- **Error Handling**: Displays error message for invalid credentials

#### 3.1.3 Password Reset
- **Screen**: `ForgotPasswordScreen`
- **Functionality**: Sends password reset link to user's email
- **Note**: Currently shows success message (email integration required for production)

### 3.2 Book Catalog

#### 3.2.1 Book Display
- **Screen**: `CatalogScreen`
- **Features**:
  - Responsive grid layout (2 columns mobile, 3 tablet, 4 desktop)
  - Book cards with cover images, title, author, price, rating
  - Bestseller and New Arrival badges
  - Wishlist toggle on each card

#### 3.2.2 Filtering
- **Genre Filter**: Filter books by genre (All, Fiction, Mystery, etc.)
- **Sort Options**:
  - Popularity (by review count)
  - Rating (highest to lowest)
  - Price: Low to High
  - Price: High to Low
- **Genre Chips**: Quick filter selection via chips

#### 3.2.3 Search
- **Screen**: `SearchScreen`
- **Search By**:
  - Book Title
  - Author Name
  - Genre
- **Real-time Search**: Results update as user types
- **Display**: Grid view of matching books

### 3.3 Shopping Cart

#### 3.3.1 Add to Cart
- **Location**: Book Detail Screen, Catalog Screen
- **Functionality**: Adds book to cart or increments quantity if already present

#### 3.3.2 Cart Management
- **Screen**: `CartScreen`
- **Features**:
  - View all cart items
  - Adjust quantities (increase/decrease)
  - Remove items
  - View subtotal, shipping, tax, and total
  - Clear entire cart
- **Calculations**:
  - Subtotal: Sum of all items
  - Shipping: $5.99 (free if subtotal > $50)
  - Tax: 8% of subtotal
  - Total: Subtotal + Shipping + Tax

#### 3.3.3 Checkout
- **Screen**: `CheckoutScreen`
- **Process**:
  1. Enter shipping address
  2. Review order total
  3. Place order
  4. Order confirmation
  5. Redirect to order history

### 3.4 Wishlist

#### 3.4.1 Add to Wishlist
- **Location**: Book cards, Book detail screen
- **Functionality**: Toggle wishlist status with heart icon

#### 3.4.2 Wishlist Management
- **Screen**: `WishlistScreen`
- **Features**:
  - View all wishlisted books
  - Remove individual items
  - Clear entire wishlist
  - Navigate to book details

### 3.5 Book Details

#### 3.5.1 Book Information
- **Screen**: `BookDetailScreen`
- **Displays**:
  - Book cover image
  - Title and author
  - Genre badge
  - Rating and review count
  - Price
  - Description
  - Add to cart button
  - Wishlist toggle

#### 3.5.2 Reviews Section
- **Features**:
  - View all reviews for the book
  - Display review rating (stars)
  - Review comments
  - Reviewer name and date
  - Like reviews
  - Add new review button

### 3.6 Reviews and Ratings

#### 3.6.1 Add Review
- **Screen**: `ReviewScreen`
- **Process**:
  1. Select rating (1-5 stars)
  2. Write review comment
  3. Submit review
- **Validation**: Comment is required

#### 3.6.2 Review Features
- **Rating Display**: Star rating system (1-5 stars)
- **Like Reviews**: Users can like other users' reviews
- **Review Count**: Shows total number of reviews per book

### 3.7 Order Management

#### 3.7.1 Order Placement
- **Process**:
  1. Add items to cart
  2. Proceed to checkout
  3. Enter shipping address
  4. Confirm order
  5. Order created with unique ID

#### 3.7.2 Order History
- **Screen**: `OrdersScreen`
- **Displays**:
  - Order ID
  - Order date
  - Order status
  - Total amount
  - Number of items

#### 3.7.3 Order Details
- **Screen**: `OrderDetailScreen`
- **Information**:
  - Complete order details
  - All items with quantities
  - Price breakdown
  - Shipping address
  - Tracking number
  - Order status

#### 3.7.4 Order Status
- **Status Types**:
  - Pending
  - Confirmed
  - Processing
  - Shipped
  - Delivered
  - Cancelled

### 3.8 User Profile

#### 3.8.1 Profile Information
- **Screen**: `ProfileScreen`
- **Editable Fields**:
  - Full Name
  - Email (read-only)
  - Phone Number
  - Shipping Address
  - Payment Method
- **Features**:
  - Update profile information
  - View order history
  - Access admin panel (admin users only)
  - Logout functionality

### 3.9 Admin Panel

#### 3.9.1 Access Control
- **Requirement**: User must have `isAdmin = true`
- **Access**: Profile Screen → Admin Panel option

#### 3.9.2 Books Management
- **Tab**: Books
- **Features**:
  - View all books (default + custom)
  - Add new books
  - Edit existing books
  - Delete custom books (default books cannot be deleted)
- **Add Book Form**:
  - Title (required)
  - Author (required)
  - Genre (required)
  - Price (required, numeric)
  - Description (optional)

#### 3.9.3 Users Management
- **Tab**: Users
- **Displays**:
  - All registered users
  - User name and email
  - Admin badge for admin users
  - User count

#### 3.9.4 Orders Management
- **Tab**: Orders
- **Features**:
  - View all orders from all users
  - Change order status via dropdown
  - View order details
  - Download order as PDF
- **Order Information**:
  - Order ID
  - User email
  - Order date
  - Total amount
  - Current status

#### 3.9.5 PDF Generation
- **Feature**: Download order invoice as PDF
- **PDF Contains**:
  - Order header with invoice title
  - Order ID and date
  - Customer information
  - Itemized list of books
  - Quantity and prices
  - Subtotal, shipping, tax
  - Total amount
  - Shipping address
  - Tracking number (if available)

---

## 4. User Guide

### 4.1 Getting Started

#### 4.1.1 First Time Setup
1. Launch the Legacy app
2. View the splash screen (3 seconds)
3. You'll be directed to the Login screen

#### 4.1.2 Creating an Account
1. Tap "Sign Up" on the login screen
2. Fill in your details:
   - Full Name
   - Email Address
   - Phone Number (optional)
   - Password (minimum 6 characters)
   - Confirm Password
3. Tap "Sign Up" button
4. You'll be automatically logged in and redirected to Home

### 4.2 Browsing Books

#### 4.2.1 Home Screen
- **Trending Now**: Scrollable horizontal list of bestseller books
- **New Arrivals**: Scrollable horizontal list of new books
- **Browse Categories**: Quick access to genre categories
- **Search Bar**: Tap to search for books

#### 4.2.2 Catalog Screen
1. Tap "Shop" in bottom navigation
2. Use filters:
   - Select genre from dropdown or chips
   - Choose sort option (Popularity, Rating, Price)
3. Browse books in grid view
4. Tap any book to view details

#### 4.2.3 Search Books
1. Tap search bar on home screen
2. Type book title, author, or genre
3. View results in real-time
4. Tap book to view details

### 4.3 Shopping

#### 4.3.1 Viewing Book Details
1. Tap any book card
2. View complete book information
3. Read reviews from other users
4. Add to cart or wishlist

#### 4.3.2 Adding to Cart
- **From Book Card**: Tap "Add to Cart" button
- **From Book Details**: Tap "Add to Cart" button
- Cart icon in header shows item count

#### 4.3.3 Managing Cart
1. Tap cart icon in header or "Cart" in bottom navigation
2. View all items
3. Adjust quantities using +/- buttons
4. Remove items by decreasing quantity to 0
5. View total including shipping and tax
6. Tap "Checkout" to proceed

#### 4.3.4 Placing Order
1. From cart, tap "Checkout"
2. Enter shipping address
3. Review order total
4. Tap "Place Order"
5. Order confirmation appears
6. Redirected to order history

### 4.4 Wishlist

#### 4.4.1 Adding to Wishlist
- Tap heart icon on any book card
- Heart fills red when added
- Wishlist count appears in header

#### 4.4.2 Managing Wishlist
1. Tap "Wishlist" in bottom navigation
2. View all wishlisted books
3. Remove items by tapping heart icon
4. Tap "Clear All" to remove everything

### 4.5 Reviews

#### 4.5.1 Adding Review
1. Go to book detail screen
2. Tap "Add Review" button
3. Select rating (1-5 stars)
4. Write your review comment
5. Tap "Submit Review"

#### 4.5.2 Viewing Reviews
- Reviews appear on book detail screen
- Shows first 3 reviews, tap "View All Reviews" for more
- Each review shows:
  - Reviewer name
  - Rating (stars)
  - Comment
  - Date
  - Like count

#### 4.5.3 Liking Reviews
- Tap heart icon on any review
- Like count increases
- You can unlike by tapping again

### 4.6 Profile Management

#### 4.6.1 Accessing Profile
- Tap menu (three dots) in header
- Select "Profile"

#### 4.6.2 Updating Profile
1. Edit any field (except email)
2. Tap "Update Profile"
3. Success message appears

#### 4.6.3 Viewing Orders
1. In Profile screen
2. Tap "Order History"
3. View all your orders
4. Tap any order to see details

---

## 5. Admin Guide

### 5.1 Admin Access

#### 5.1.1 Default Admin Account
- **Email**: `admin@legacy.com`
- **Password**: `admin123`

#### 5.1.2 Accessing Admin Panel
1. Login with admin credentials
2. Go to Profile screen
3. Tap "Admin Panel" option
4. Admin panel opens with three tabs

### 5.2 Managing Books

#### 5.2.1 Viewing All Books
- **Tab**: Books
- Shows all books (default + custom)
- Each book displays:
  - Cover image
  - Title
  - Author
  - Price

#### 5.2.2 Adding New Book
1. Tap "Add New Book" button
2. Fill in the form:
   - **Title**: Book title (required)
   - **Author**: Author name (required)
   - **Genre**: Book genre (required)
   - **Price**: Book price in dollars (required)
   - **Description**: Book description (optional)
3. Tap "Add"
4. Book appears in catalog immediately

#### 5.2.3 Editing Book
1. Find book in Books tab
2. Tap edit icon (pencil)
3. Modify fields in the dialog
4. Tap "Update"
5. Changes saved immediately

**Note**: Editing default books creates a custom copy with your changes.

#### 5.2.4 Deleting Book
1. Find book in Books tab
2. Tap delete icon (trash)
3. Confirm deletion
4. Book removed from catalog

**Note**: Default books cannot be deleted. Only books you added can be removed.

### 5.3 Managing Users

#### 5.3.1 Viewing Users
- **Tab**: Users
- Shows all registered users
- Displays:
  - User name
  - Email address
  - Admin badge (if admin)

### 5.4 Managing Orders

#### 5.4.1 Viewing All Orders
- **Tab**: Orders
- Shows all orders from all users
- Each order displays:
  - Order ID
  - User email
  - Order date
  - Total amount
  - Current status

#### 5.4.2 Changing Order Status
1. Find order in Orders tab
2. Use status dropdown
3. Select new status:
   - Pending
   - Confirmed
   - Processing
   - Shipped
   - Delivered
   - Cancelled
4. Status updates immediately

#### 5.4.3 Downloading Order PDF
1. Find order in Orders tab
2. Tap "Download PDF" button
3. PDF preview opens
4. Options to:
   - Print
   - Save as PDF
   - Share

**PDF Contents**:
- Order invoice header
- Order ID and date
- Customer information
- Complete itemized list
- Price breakdown
- Shipping address
- Tracking number

---

## 6. Developer Guide

### 6.1 Setup Development Environment

#### 6.1.1 Install Flutter
1. Download Flutter SDK from [flutter.dev](https://flutter.dev)
2. Extract to desired location
3. Add Flutter to system PATH
4. Verify installation: `flutter doctor`

#### 6.1.2 Install Dependencies
```bash
flutter pub get
```

#### 6.1.3 Run Application
```bash
# Run on connected device
flutter run

# Run on specific device
flutter run -d chrome        # Web
flutter run -d android       # Android
flutter run -d ios           # iOS
```

### 6.2 Code Structure

#### 6.2.1 Models
All data models are in `lib/models/`:
- **Book**: Represents a book with all properties
- **UserAccount**: User information and admin flag
- **CartItem**: Shopping cart item with quantity
- **Order**: Order with status tracking
- **BookReview**: Review with rating and likes

#### 6.2.2 Services
- **AppDataManager**: Singleton pattern for centralized data management
  - User management
  - Cart operations
  - Wishlist operations
  - Order management
  - Review management
  - Book CRUD operations

- **BookDataService**: Static book catalog data
  - Default book collection
  - Genre list
  - Bestseller list
  - New arrivals list

#### 6.2.3 Screens
All screens follow consistent structure:
- StatefulWidget for state management
- AppDataManager instance for data access
- Theme colors from AppColors
- Consistent navigation patterns

#### 6.2.4 Widgets
- **BookCardWidget**: Reusable book card component
  - Responsive design
  - Wishlist toggle
  - Rating display
  - Badge support

### 6.3 Adding New Features

#### 6.3.1 Adding a New Screen
1. Create new file in `lib/screens/`
2. Follow existing screen structure
3. Import required dependencies
4. Add navigation route

#### 6.3.2 Adding a New Model
1. Create new file in `lib/models/`
2. Define class with properties
3. Add to AppDataManager if needed

#### 6.3.3 Modifying Theme
- Edit `lib/theme/app_colors.dart`
- Update color constants
- Changes reflect across entire app

### 6.4 State Management

#### 6.4.1 Current Approach
- **Singleton Pattern**: AppDataManager
- **setState()**: For local UI updates
- **Global State**: Accessible via AppDataManager instance

#### 6.4.2 Data Persistence
Currently in-memory. For production:
- Implement SharedPreferences for local storage
- Add database integration (SQLite, Firebase, etc.)
- Implement API integration

### 6.5 Best Practices

#### 6.5.1 Code Style
- Use descriptive variable names
- Follow Dart naming conventions
- Keep functions focused and small
- Add comments for complex logic

#### 6.5.2 Error Handling
- Validate user input
- Show user-friendly error messages
- Handle network errors gracefully
- Use try-catch for critical operations

#### 6.5.3 Performance
- Use const constructors where possible
- Implement lazy loading for large lists
- Optimize image loading
- Minimize rebuilds with proper state management

---

## 7. API Reference

### 7.1 AppDataManager

#### 7.1.1 User Management
```dart
// Add new user
void addUser(UserAccount user)

// Login user
bool loginUser(String email, String password)

// Logout user
void logoutUser()
```

#### 7.1.2 Book Management
```dart
// Get all books
List<Book> get allBooks

// Add new book
void addBook(Book book)

// Update book
void updateBook(Book updatedBook)

// Remove book
void removeBook(int bookId)

// Check if default book
bool isDefaultBook(int bookId)
```

#### 7.1.3 Cart Operations
```dart
// Add to cart
void addToCart(Book book)

// Remove from cart
void removeFromCart(int bookId)

// Update quantity
void updateCartQuantity(int bookId, int quantity)

// Get cart total
double getCartTotal()
```

#### 7.1.4 Wishlist Operations
```dart
// Toggle wishlist
void toggleWishlist(Book book)

// Check if in wishlist
bool isInWishlist(int bookId)
```

#### 7.1.5 Order Management
```dart
// Create order
Order createOrder(String shippingAddress)

// Get user orders
List<Order> getUserOrders()
```

#### 7.1.6 Review Management
```dart
// Add review
void addReview(BookReview review)

// Get book reviews
List<BookReview> getBookReviews(int bookId)

// Toggle review like
void toggleReviewLike(int reviewId, String userId)

// Check if user liked review
bool hasUserLikedReview(int reviewId, String userId)
```

### 7.2 BookDataService

```dart
// Get all books
static List<Book> getAllBooks()

// Get bestsellers
static List<Book> getBestsellers()

// Get new arrivals
static List<Book> getNewArrivals()

// Get all genres
static List<String> getAllGenres()
```

---

## 8. Database Schema

### 8.1 Current Implementation
Currently uses in-memory data structures. Below is the proposed schema for database integration:

### 8.2 Proposed Schema

#### 8.2.1 Users Table
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    phone_number TEXT,
    shipping_address TEXT,
    payment_method TEXT,
    is_admin INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 8.2.2 Books Table
```sql
CREATE TABLE books (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
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
    release_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

#### 8.2.3 Cart Items Table
```sql
CREATE TABLE cart_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    quantity INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);
```

#### 8.2.4 Orders Table
```sql
CREATE TABLE orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id TEXT UNIQUE NOT NULL,
    user_id INTEGER NOT NULL,
    total_amount REAL NOT NULL,
    status TEXT NOT NULL,
    shipping_address TEXT NOT NULL,
    tracking_number TEXT,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

#### 8.2.5 Order Items Table
```sql
CREATE TABLE order_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    price REAL NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);
```

#### 8.2.6 Reviews Table
```sql
CREATE TABLE reviews (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    book_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    user_name TEXT NOT NULL,
    rating REAL NOT NULL,
    comment TEXT NOT NULL,
    likes_count INTEGER DEFAULT 0,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

#### 8.2.7 Review Likes Table
```sql
CREATE TABLE review_likes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    review_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    FOREIGN KEY (review_id) REFERENCES reviews(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    UNIQUE(review_id, user_id)
);
```

#### 8.2.8 Wishlist Table
```sql
CREATE TABLE wishlist (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (book_id) REFERENCES books(id),
    UNIQUE(user_id, book_id)
);
```

---

## 9. Testing Guide

### 9.1 Manual Testing Checklist

#### 9.1.1 Authentication
- [ ] User registration with valid data
- [ ] User registration with invalid email
- [ ] User registration with weak password
- [ ] User registration with duplicate email
- [ ] User login with correct credentials
- [ ] User login with incorrect credentials
- [ ] Password reset functionality
- [ ] Logout functionality

#### 9.1.2 Book Catalog
- [ ] Display all books
- [ ] Filter by genre
- [ ] Sort by price (low to high)
- [ ] Sort by price (high to low)
- [ ] Sort by rating
- [ ] Sort by popularity
- [ ] Search by title
- [ ] Search by author
- [ ] Search by genre
- [ ] Responsive layout on different screen sizes

#### 9.1.3 Shopping Cart
- [ ] Add book to cart
- [ ] Increase quantity
- [ ] Decrease quantity
- [ ] Remove item from cart
- [ ] Clear entire cart
- [ ] Calculate subtotal correctly
- [ ] Calculate shipping (free over $50)
- [ ] Calculate tax (8%)
- [ ] Display total correctly

#### 9.1.4 Wishlist
- [ ] Add book to wishlist
- [ ] Remove from wishlist
- [ ] View wishlist
- [ ] Clear wishlist
- [ ] Wishlist count in header

#### 9.1.5 Orders
- [ ] Place order successfully
- [ ] View order history
- [ ] View order details
- [ ] Order status display
- [ ] Order total calculation

#### 9.1.6 Reviews
- [ ] Add review with rating
- [ ] View all reviews
- [ ] Like a review
- [ ] Unlike a review
- [ ] Review count updates

#### 9.1.7 Admin Panel
- [ ] Admin access only
- [ ] View all books
- [ ] Add new book
- [ ] Edit book
- [ ] Delete custom book
- [ ] Cannot delete default book
- [ ] View all users
- [ ] View all orders
- [ ] Change order status
- [ ] Download order PDF

### 9.2 Test Accounts

#### Regular User
- Create account through Sign Up screen
- Test all user features

#### Admin User
- Email: `admin@legacy.com`
- Password: `admin123`
- Test all admin features

---

## 10. Deployment Guide

### 10.1 Building for Production

#### 10.1.1 Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

#### 10.1.2 Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

#### 10.1.3 iOS
```bash
flutter build ios --release
```
Then archive and upload via Xcode

#### 10.1.4 Web
```bash
flutter build web --release
```
Output: `build/web/`

### 10.2 Pre-Deployment Checklist

- [ ] Update app version in `pubspec.yaml`
- [ ] Test on all target platforms
- [ ] Update app icons and splash screens
- [ ] Configure app signing (Android/iOS)
- [ ] Update app name in AndroidManifest.xml
- [ ] Update app name in Info.plist (iOS)
- [ ] Test all features thoroughly
- [ ] Remove debug code
- [ ] Optimize images
- [ ] Test performance
- [ ] Prepare app store listings

### 10.3 Environment Configuration

#### 10.3.1 Android
- Update `android/app/build.gradle.kts`
- Configure signing configs
- Set version code and version name

#### 10.3.2 iOS
- Update `ios/Runner/Info.plist`
- Configure bundle identifier
- Set version and build number

### 10.4 Production Considerations

#### 10.4.1 Security
- Implement proper password hashing
- Use secure storage for sensitive data
- Implement API authentication
- Add input validation and sanitization

#### 10.4.2 Performance
- Implement image caching
- Optimize database queries
- Add pagination for large lists
- Implement lazy loading

#### 10.4.3 Monitoring
- Add crash reporting (Firebase Crashlytics, Sentry)
- Implement analytics (Firebase Analytics, Google Analytics)
- Add performance monitoring
- Set up error logging

---

## 11. Troubleshooting

### 11.1 Common Issues

#### 11.1.1 App Won't Start
- Check Flutter installation: `flutter doctor`
- Run `flutter pub get`
- Clear build cache: `flutter clean`
- Restart IDE

#### 11.1.2 Build Errors
- Check Android SDK path in `local.properties`
- Verify Flutter SDK path
- Update dependencies: `flutter pub upgrade`
- Check platform-specific requirements

#### 11.1.3 Runtime Errors
- Check console for error messages
- Verify data is properly initialized
- Check null safety issues
- Review state management

### 11.2 Performance Issues

#### 11.2.1 Slow Loading
- Check image loading optimization
- Implement lazy loading
- Reduce widget rebuilds
- Optimize list rendering

#### 11.2.2 Memory Issues
- Check for memory leaks
- Dispose controllers properly
- Clear unused data
- Optimize image sizes

---

## 12. Future Enhancements

### 12.1 Planned Features
- [ ] Database integration (SQLite/Firebase)
- [ ] User authentication with Firebase
- [ ] Social media login (Google, Facebook)
- [ ] Payment gateway integration
- [ ] Push notifications
- [ ] Email notifications
- [ ] Advanced search filters
- [ ] Book recommendations
- [ ] Reading progress tracking
- [ ] E-book support
- [ ] Multi-language support
- [ ] Dark/Light theme toggle
- [ ] Offline mode support

### 12.2 Technical Improvements
- [ ] State management with Provider/Riverpod
- [ ] API integration
- [ ] Image caching
- [ ] Data persistence
- [ ] Unit testing
- [ ] Integration testing
- [ ] CI/CD pipeline
- [ ] Code documentation

---

## 13. Support and Contact

### 13.1 Getting Help
- Review this documentation
- Check code comments
- Review Flutter documentation
- Contact eProjects Team for support

### 13.2 Reporting Issues
When reporting issues, include:
- Device/platform information
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)

---

## 14. License and Credits

### 14.1 Project Information
- **Project Name**: Legacy Book Store
- **Version**: 1.0.0
- **Framework**: Flutter
- **Language**: Dart

### 14.2 Dependencies
- Flutter SDK
- pdf: ^3.11.1
- printing: ^5.13.3
- shared_preferences: ^2.2.2
- cupertino_icons: ^1.0.8

### 14.3 Credits
- Developed as part of eProject learning initiative
- Design inspired by modern e-commerce applications

---

*Last Updated: 2024*
*Documentation Version: 1.0*

