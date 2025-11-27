# Book Store Application - eProject

## 1. Introduction

The thirst for learning, upgrading technical skills and applying the concepts in real life environment at a fast pace is what the industry demands from IT professionals today. However busy work schedules, far-flung locations, unavailability of convenient time-slots pose as major barriers when it comes to applying the concepts into realism. And hence the need to look out for alternative means of implementation in the form of laddered approach.

The above truly pose as constraints especially for our students too! With their busy schedules, it is indeed difficult for our students to keep up with the genuine and constant need for integrated application which can be seen live especially so in the field of IT education where technology can change on the spur of a moment. Well, technology does come to our rescue at such times!!

Keeping the above in mind and in tune with our constant endeavour to use Technology in our training model, we at Aptech have thought of revolutionizing the way our students learn and implement the concepts using tools themselves by providing a live and synchronous eProject learning environment!

### So what is this eProject?

eProject is a step by step learning environment that closely simulates the classroom and Lab based learning environment into actual implementation. It is a project implementation at your fingertips!! An electronic, live juncture on the machine that allows you to:

- Practice step by step i.e. laddered approach.
- Build a larger more robust application.
- Usage of certain utilities in applications designed by user.
- Single program to unified code leading to a complete application.
- Learn implementation of concepts in a phased manner.
- Enhance skills and add value.
- Work on real life projects.
- Give a real life scenario and help to create applications more complicated and useful.
- Mentoring through email support.

The students at the centre are expected to complete this eProject and send complete documentation with source code to eProjects Team.

Looking forward to a positive response from your end!!

### Background

The Book Store app was conceived as a response to the evolving landscape of the book retail industry. Traditional brick-and-mortar bookstores faced increasing challenges due to the rise of e-commerce, digital books, and changing consumer preferences. Recognizing the need to adapt to these changes, a well-established book retailer with both physical stores and an online presence decided to venture into mobile app development to enhance its services and remain competitive.

---

## 2. Objectives

The Objective of this program is to give a sample project to work on real life projects. These applications help you build a larger more robust application.

The objective is not to teach you the concepts but to provide you with a real life scenario and help you create applications using the tools.

You can revise them before you start with the project.

It is very essential that a student has a clear understanding of the subject.

Kindly get back to eProjects Team, in case of any doubts regarding the application or its objectives.

---

## 3. Problem Statement

### Functional Requirements

#### User Registration and Authentication:
- Users should be able to create accounts with their email or social media accounts.
- Users must be able to log in and log out securely.
- Password reset option should be available.

#### Book Catalog:
- The app should display a comprehensive catalog of books, including titles, authors, genres, descriptions, cover images, and prices.
- Books should be categorized by genres and authors.
- Users must be able to access bestsellers and new arrivals.

#### Search and Filters:
- Users should be able to search for books by title, author, or genre.
- Filters should allow sorting by price, popularity, and release date.

#### User Profiles:
- Registered users should have personal profiles.
- Users must be able to update their profile information, including shipping addresses and payment methods.

#### Shopping Cart:
- Users should be able to add books to their shopping cart.
- Users must be able to adjust quantities in the cart.
- The cart should display the total price.

#### Ratings and Reviews:
- Users should be able to rate books and provide reviews.
- Ratings and reviews should be displayed on book details pages.
- Users should be able to like on reviews.

#### Order Management:
- Registered users should be able to view their order history.
- Order status updates should be available to users.
- Users must be able to track the delivery status of their orders.

#### Admin Panel:
- Administrators should have access to an admin panel for managing book listings, user accounts, and orders.
- Admins should be able to add, update, or remove books from the catalog.

#### Wishlist:
- Users should have the option to create and manage a wishlist of books they intend to purchase in the future.

### Non-Functional Requirements

- **Responsiveness**: The app should respond to user interactions within 1-2 seconds, ensuring a smooth and lag-free experience.
- **Loading Time**: The app's initial loading time should be minimized to ensure users can access it quickly.
- **User Interface**: The app's user interface should be intuitive, following best design practices for mobile apps to ensure ease of use.
- **Accessible**: The application should have clear and legible fonts, user-interface elements, and navigation elements.
- **User-friendly**: The application should be easy to navigate with clear menus and other elements and easy to understand.
- **Operability**: The application should operate in a reliably efficient manner.
- **Error Handling**: Implement robust error handling to provide clear error messages to users and gracefully handle unexpected situations.
- **Scalability**: The application architecture and infrastructure should be designed to handle increasing user traffic, data storage, and feature expansions.
- **Security**: The application should implement adequate security measures such as authentication. For example, only registered users can access certain features.
- **User Documentation**: Provide user guides, FAQs, and tutorials to help users understand and navigate the application.
- **Developer Documentation**: Maintain developer documentation to assist in further development and maintenance.
- **Video**: Provide video displaying complete working of the application.

---

## 4. Hardware/Software Requirements

### Hardware

- A minimum computer system that will help you access all the tools in the courses is a Pentium 166 or better
- 128 Megabytes of RAM or better
- Windows 2000 Server (or higher if possible)

### Software

Use software as per your requirement:

- Windows OS
- JAVA
- Android SDK
- Notepad
- SQL
- Dart
- Flutter

---

## Project Structure

This Flutter-based Legacy Book Store application includes:

### Core Features

- **User Authentication**: Login, Sign Up, and Password Reset functionality
- **Book Catalog**: Comprehensive display of books with categories, bestsellers, and new arrivals
- **Search & Filters**: Search books by title, author, or genre with advanced filtering options
- **Shopping Cart**: Add books, adjust quantities, calculate totals with tax and shipping
- **Wishlist**: Save favorite books for later purchase
- **User Profile**: Manage personal information, shipping addresses, and payment methods
- **Book Details**: View detailed information, ratings, and reviews with like functionality
- **Order Management**: Place orders, track order history, and view order details
- **Admin Panel**: Complete admin interface for managing books, users, and orders
- **PDF Generation**: Download order invoices as PDF documents

### Project Architecture

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models
│   ├── book_model.dart
│   ├── user_model.dart
│   ├── cart_item_model.dart
│   ├── order_model.dart
│   └── review_model.dart
├── screens/                  # Application screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── signup_screen.dart
│   ├── forgot_password_screen.dart
│   ├── home_screen.dart
│   ├── catalog_screen.dart
│   ├── search_screen.dart
│   ├── book_detail_screen.dart
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   ├── wishlist_screen.dart
│   ├── profile_screen.dart
│   ├── orders_screen.dart
│   ├── order_detail_screen.dart
│   ├── review_screen.dart
│   └── admin_panel_screen.dart
├── services/                 # Business logic and data management
│   ├── app_data_manager.dart
│   └── book_data_service.dart
├── widgets/                 # Reusable UI components
│   └── book_card_widget.dart
└── theme/                   # App theming
    └── app_colors.dart
```

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development - macOS only)

### Installation Steps

1. **Clone or download this project**
   ```bash
   git clone <repository-url>
   cd bookstore
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

4. **Build for specific platform**
   ```bash
   flutter build apk          # Android
   flutter build ios           # iOS
   flutter build web           # Web
   ```

### Default Admin Account

For testing admin features:
- **Email**: `admin@legacy.com`
- **Password**: `admin123`

## Technologies Used

- **Flutter**: Cross-platform mobile development framework (v3.8.0+)
- **Dart**: Programming language
- **Material Design 3**: Modern UI/UX framework
- **PDF Package**: For generating order invoices
- **Printing Package**: For PDF preview and sharing
- **Shared Preferences**: For local data persistence (ready for implementation)

## Features Implemented

✅ User Registration and Authentication  
✅ Password Reset Functionality  
✅ Book Catalog with Categories  
✅ Search by Title, Author, Genre  
✅ Advanced Filtering and Sorting  
✅ Shopping Cart with Quantity Management  
✅ Wishlist Management  
✅ User Profile Management  
✅ Book Ratings and Reviews  
✅ Review Likes Functionality  
✅ Order Placement and Management  
✅ Order Status Tracking  
✅ Admin Panel (Books, Users, Orders)  
✅ Book CRUD Operations (Add, Edit, Delete)  
✅ PDF Order Invoice Generation  
✅ Mobile Responsive Design  
✅ Dark Theme UI  

## Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

---

*This project is part of the eProject learning initiative by Aptech.*

For detailed documentation, see [DOCUMENTATION.md](DOCUMENTATION.md)
