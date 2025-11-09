class Book {
  final String id;
  final String title;
  final String author;
  final String condition;
  final String imageUrl;
  final String ownerId;
  final String status;
  final String category;
  final DateTime createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    required this.imageUrl,
    required this.ownerId,
    this.status = 'available',
    this.category = 'General',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'author': author,
    'condition': condition,
    'imageUrl': imageUrl,
    'ownerId': ownerId,
    'status': status,
    'category': category,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Book.fromMap(Map<String, dynamic> map) => Book(
    id: map['id'],
    title: map['title'],
    author: map['author'],
    condition: map['condition'],
    imageUrl: map['imageUrl'],
    ownerId: map['ownerId'],
    status: map['status'] ?? 'available',
    category: map['category'] ?? 'General',
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
  );
}