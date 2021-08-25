class User {
  User.privateConstructor();
  static final User _instance = User.privateConstructor();
  Map<String, dynamic>? info;

  factory User() {
    return _instance;
  }
}