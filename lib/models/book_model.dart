class Book {
  final int id;
  final String title;
  final String author;
  final String genre;
  final double price;
  final double rating;
  final int reviewCount;
  final String coverImageUrl;
  final String description;
  final bool isBestseller;
  final bool isNewArrival;
  final DateTime releaseDate;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.coverImageUrl,
    required this.description,
    this.isBestseller = false,
    this.isNewArrival = false,
    required this.releaseDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'genre': genre,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'coverImageUrl': coverImageUrl,
      'description': description,
      'isBestseller': isBestseller,
      'isNewArrival': isNewArrival,
      'releaseDate': releaseDate.toIso8601String(),
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      genre: json['genre'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      coverImageUrl: json['coverImageUrl'] ?? '',
      description: json['description'] ?? '',
      isBestseller: json['isBestseller'] ?? false,
      isNewArrival: json['isNewArrival'] ?? false,
      releaseDate: DateTime.parse(json['releaseDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

