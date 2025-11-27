import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/app_data_manager.dart';
import '../services/book_data_service.dart';
import '../widgets/book_card_widget.dart';
import 'book_detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  final String? selectedGenre;

  const CatalogScreen({super.key, this.selectedGenre});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String selectedGenre = 'All';
  String sortBy = 'Popularity';
  final dataManager = AppDataManager();

  @override
  void initState() {
    super.initState();
    if (widget.selectedGenre != null) {
      selectedGenre = widget.selectedGenre!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    List books = dataManager.allBooks;

    // Debug: Print book count
    if (books.isEmpty) {
      debugPrint(
        'WARNING: CatalogScreen - No books found in dataManager.allBooks',
      );
    } else {
      debugPrint('CatalogScreen: Found ${books.length} books');
    }

    if (selectedGenre != 'All') {
      books = books.where((book) => book.genre == selectedGenre).toList();
    }

    if (sortBy == 'Price: Low to High') {
      books.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == 'Price: High to Low') {
      books.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortBy == 'Rating') {
      books.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (sortBy == 'Popularity') {
      books.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }

    final genres = ['All', ...BookDataService.getAllGenres()];

    // Responsive grid columns
    int crossAxisCount;
    double childAspectRatio;
    double spacing;

    if (isMobile) {
      crossAxisCount = 2;
      childAspectRatio = 0.55;
      spacing = 12;
    } else if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 0.6;
      spacing = 16;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 0.65;
      spacing = 20;
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Bookstore',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.purpleAccent.withValues(alpha: 0.5),
                  AppColors.darkSurface.withValues(alpha: 0.5),
                ],
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.purpleAccent.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                if (isMobile)
                  // Mobile: Stack dropdowns vertically
                  Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedGenre,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Genre',
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppColors.darkCard.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                          ),
                        ),
                        dropdownColor: AppColors.darkCard,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: genres.map((genre) {
                          return DropdownMenuItem(
                            value: genre,
                            child: Text(genre),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => selectedGenre = value!),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: sortBy,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Sort By',
                          labelStyle: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                          filled: true,
                          fillColor: AppColors.darkCard.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.borderColor,
                            ),
                          ),
                        ),
                        dropdownColor: AppColors.darkCard,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: const [
                          DropdownMenuItem(
                            value: 'Popularity',
                            child: Text('Popularity'),
                          ),
                          DropdownMenuItem(
                            value: 'Rating',
                            child: Text('Rating'),
                          ),
                          DropdownMenuItem(
                            value: 'Price: Low to High',
                            child: Text('Price: Low to High'),
                          ),
                          DropdownMenuItem(
                            value: 'Price: High to Low',
                            child: Text('Price: High to Low'),
                          ),
                        ],
                        onChanged: (value) => setState(() => sortBy = value!),
                      ),
                    ],
                  )
                else
                  // Tablet/Desktop: Show dropdowns side by side
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedGenre,
                          decoration: InputDecoration(
                            labelText: 'Genre',
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.darkCard.withValues(
                              alpha: 0.5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderColor,
                              ),
                            ),
                          ),
                          dropdownColor: AppColors.darkCard,
                          style: const TextStyle(color: AppColors.textPrimary),
                          items: genres.map((genre) {
                            return DropdownMenuItem(
                              value: genre,
                              child: Text(genre),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => selectedGenre = value!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: sortBy,
                          decoration: InputDecoration(
                            labelText: 'Sort By',
                            labelStyle: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.darkCard.withValues(
                              alpha: 0.5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.borderColor,
                              ),
                            ),
                          ),
                          dropdownColor: AppColors.darkCard,
                          style: const TextStyle(color: AppColors.textPrimary),
                          items: const [
                            DropdownMenuItem(
                              value: 'Popularity',
                              child: Text('Popularity'),
                            ),
                            DropdownMenuItem(
                              value: 'Rating',
                              child: Text('Rating'),
                            ),
                            DropdownMenuItem(
                              value: 'Price: Low to High',
                              child: Text('Price: Low to High'),
                            ),
                            DropdownMenuItem(
                              value: 'Price: High to Low',
                              child: Text('Price: High to Low'),
                            ),
                          ],
                          onChanged: (value) => setState(() => sortBy = value!),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: genres.map((genre) {
                      final isSelected = selectedGenre == genre;
                      return Padding(
                        padding: EdgeInsets.only(right: isMobile ? 6 : 8),
                        child: FilterChip(
                          label: Text(
                            genre,
                            style: TextStyle(fontSize: isMobile ? 12 : 14),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => selectedGenre = genre);
                          },
                          selectedColor: AppColors.purpleAccent,
                          backgroundColor: AppColors.darkCard,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: books.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No books found',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedGenre != 'All'
                              ? 'Try selecting a different genre'
                              : 'Check back later for new books',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      return BookCardWidget(
                        book: books[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookDetailScreen(book: books[index]),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
