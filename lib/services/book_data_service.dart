import '../models/book_model.dart';

class BookDataService {
  static List<Book> getAllBooks() {
    return [
      Book(
        id: 1,
        title: 'Midnight Tales',
        author: 'Sarah Chen',
        genre: 'Fiction',
        price: 24.99,
        rating: 4.8,
        reviewCount: 1234,
        coverImageUrl: 'https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=400&h=600&fit=crop',
        description: 'A collection of captivating stories that take you on a journey through the night. Each tale is carefully crafted to keep you on the edge of your seat.',
        isBestseller: true,
        isNewArrival: false,
        releaseDate: DateTime(2023, 1, 15),
      ),
      Book(
        id: 2,
        title: 'The Silent Echo',
        author: 'Marcus Webb',
        genre: 'Mystery',
        price: 19.99,
        rating: 4.9,
        reviewCount: 856,
        coverImageUrl: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=400&h=600&fit=crop',
        description: 'A gripping mystery that will keep you guessing until the very end. Follow the clues as the story unfolds.',
        isBestseller: true,
        isNewArrival: true,
        releaseDate: DateTime(2024, 11, 1),
      ),
      Book(
        id: 3,
        title: 'Quantum Dreams',
        author: 'Dr. Lisa Park',
        genre: 'Science Fiction',
        price: 29.99,
        rating: 4.7,
        reviewCount: 2341,
        coverImageUrl: 'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400&h=600&fit=crop',
        description: 'Explore the boundaries of reality in this mind-bending science fiction novel that questions everything we know about the universe.',
        isBestseller: false,
        isNewArrival: true,
        releaseDate: DateTime(2024, 10, 15),
      ),
      Book(
        id: 4,
        title: 'Dark Matter',
        author: 'Blake Crouch',
        genre: 'Science Fiction',
        price: 16.99,
        rating: 4.6,
        reviewCount: 5678,
        coverImageUrl: 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&h=600&fit=crop',
        description: 'A thrilling journey through parallel universes where every choice creates a new reality.',
        isBestseller: true,
        isNewArrival: false,
        releaseDate: DateTime(2022, 5, 20),
      ),
      Book(
        id: 5,
        title: 'The Alchemist',
        author: 'Paulo Coelho',
        genre: 'Fiction',
        price: 14.99,
        rating: 4.8,
        reviewCount: 12456,
        coverImageUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&h=600&fit=crop',
        description: 'A magical fable about following your dreams. The story of Santiago, an Andalusian shepherd boy who yearns to travel in search of treasure.',
        isBestseller: true,
        isNewArrival: false,
        releaseDate: DateTime(1988, 1, 1),
      ),
      Book(
        id: 6,
        title: 'Sapiens',
        author: 'Yuval Noah Harari',
        genre: 'History',
        price: 22.99,
        rating: 4.9,
        reviewCount: 8901,
        coverImageUrl: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=400&h=600&fit=crop',
        description: 'A brief history of humankind. How did our species succeed in the battle for dominance? Why did our foraging ancestors come together to create cities?',
        isBestseller: true,
        isNewArrival: false,
        releaseDate: DateTime(2011, 1, 1),
      ),
    ];
  }

  static List<Book> getBestsellers() {
    return getAllBooks().where((book) => book.isBestseller).toList();
  }

  static List<Book> getNewArrivals() {
    return getAllBooks().where((book) => book.isNewArrival).toList();
  }

  static List<String> getAllGenres() {
    return getAllBooks().map((book) => book.genre).toSet().toList()..sort();
  }
}

