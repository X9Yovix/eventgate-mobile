class Token {
  final String refresh;
  final String access;

  Token({required this.refresh, required this.access});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      refresh: json['refresh'],
      access: json['access'],
    );
  }
}
