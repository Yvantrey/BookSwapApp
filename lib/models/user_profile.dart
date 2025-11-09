class UserProfile {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'email': email,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    uid: map['uid'],
    name: map['name'],
    email: map['email'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
  );
}