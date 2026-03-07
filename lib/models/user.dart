class User {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String profileImage;
  final String accountType;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage = '',
    this.accountType = 'Standard',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImage: json['profileImage'] ?? '',
      accountType: json['accountType'] ?? 'Standard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'accountType': accountType,
    };
  }

  String get fullName => '$firstName $lastName';
}
