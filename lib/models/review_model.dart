class BookReview {
  final int id;
  final int bookId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime reviewDate;
  int likesCount;
  List<String> likedByUsers;

  BookReview({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.reviewDate,
    this.likesCount = 0,
    List<String>? likedByUsers,
  }) : likedByUsers = likedByUsers ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'reviewDate': reviewDate.toIso8601String(),
      'likesCount': likesCount,
      'likedByUsers': likedByUsers,
    };
  }

  factory BookReview.fromJson(Map<String, dynamic> json) {
    return BookReview(
      id: json['id'] ?? 0,
      bookId: json['bookId'] ?? 0,
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      reviewDate: DateTime.parse(
        json['reviewDate'] ?? DateTime.now().toIso8601String(),
      ),
      likesCount: json['likesCount'] ?? 0,
      likedByUsers: List<String>.from(json['likedByUsers'] ?? []),
    );
  }
}
