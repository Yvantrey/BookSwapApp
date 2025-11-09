class Chat {
  final String id;
  final List<String> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String bookId;

  Chat({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.bookId,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'participants': participants,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
    'bookId': bookId,
  };

  factory Chat.fromMap(Map<String, dynamic> map) => Chat(
    id: map['id'],
    participants: List<String>.from(map['participants']),
    lastMessage: map['lastMessage'],
    lastMessageTime: DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime']),
    bookId: map['bookId'],
  );
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'chatId': chatId,
    'senderId': senderId,
    'text': text,
    'timestamp': timestamp.millisecondsSinceEpoch,
  };

  factory Message.fromMap(Map<String, dynamic> map) => Message(
    id: map['id'],
    chatId: map['chatId'],
    senderId: map['senderId'],
    text: map['text'],
    timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
  );
}