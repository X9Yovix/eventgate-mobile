class User {
  final String username;
  final String firstName;
  final String lastName;
  final String email;

  User({
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };
  }
}

class Profile {
  final String? birthDate;
  final String? gender;
  final String? phoneNumber;
  final String? bio;
  final String? profilePicture;
  final bool isProfileComplete;
  final bool skipIsProfileComplete;

  Profile({
    this.birthDate,
    this.gender,
    this.phoneNumber,
    this.bio,
    this.profilePicture,
    required this.isProfileComplete,
    required this.skipIsProfileComplete,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      birthDate: json['birth_date'],
      gender: json['gender'],
      phoneNumber: json['phone_number'],
      bio: json['bio'],
      profilePicture: json['profile_picture'],
      isProfileComplete: json['is_profile_complete'],
      skipIsProfileComplete: json['skip_is_profile_complete'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'birth_date': birthDate,
      'gender': gender,
      'phone_number': phoneNumber,
      'bio': bio,
      "profile_picture": profilePicture,
      "is_profile_complete": isProfileComplete,
      "skip_is_profile_complete": skipIsProfileComplete
    };
  }
}
