class User {
  final String userId;
  final String name;
  final String username;
  final String password;

  const User({
    required this.userId,
    required this.name,
    required this.username,
    required this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] as String,
      name: json['name'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }
}