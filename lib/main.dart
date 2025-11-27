import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'theme/app_colors.dart';
import 'screens/splash_screen.dart';
import 'services/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for desktop/mobile before running app
  // Note: SQLite doesn't work on web - UnifiedStorage handles web storage
  if (!kIsWeb) {
    await DatabaseHelper.initialize();
  }

  runApp(const BookStoreApp());
}

class BookStoreApp extends StatelessWidget {
  const BookStoreApp({super.key});

  @override 
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Legacy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.indigoPrimary,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.indigoPrimary,
          secondary: AppColors.purpleAccent,
          surface: AppColors.darkSurface,
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
