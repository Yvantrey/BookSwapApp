class SwapOffer {
  final String id;
  final String bookId;
  final String requesterId;
  final String ownerId;
  final String status;
  final DateTime createdAt;

  SwapOffer({
    required this.id,
    required this.bookId,
    required this.requesterId,
    required this.ownerId,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'bookId': bookId,
    'requesterId': requesterId,
    'ownerId': ownerId,
    'status': status,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory SwapOffer.fromMap(Map<String, dynamic> map) => SwapOffer(
    id: map['id'],
    bookId: map['bookId'],
    requesterId: map['requesterId'],
    ownerId: map['ownerId'],
    status: map['status'] ?? 'pending',
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
  );
}