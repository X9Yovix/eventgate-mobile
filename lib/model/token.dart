class Token {
  final String refresh;
  final String access;
  final String firebaseToken;

  Token(
      {required this.refresh,
      required this.access,
      required this.firebaseToken});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      refresh: json['refresh'],
      access: json['access'],
      firebaseToken: json['firebase_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'refresh': refresh,
      'access': access,
      'firebase_token': firebaseToken,
    };
  }
}
