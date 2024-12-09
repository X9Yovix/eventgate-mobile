import 'dart:convert';

import 'package:eventgate_flutter/model/token.dart';
import 'package:eventgate_flutter/model/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as app_firebase_auth;

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  User? _user;
  Token? _token;
  Profile? _profile;

  Token? get token => _token;
  User? get user => _user;
  Profile? get profile => _profile;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(User? user, Profile? profile, Token? token) async {
    if (user == null || token == null || profile == null) {
      return false;
    }

    _isAuthenticated = true;
    _user = user;
    _profile = profile;
    _token = token;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
    await prefs.setString('user', jsonEncode(user.toJson()));
    await prefs.setString('profile', jsonEncode(profile.toJson()));
    await prefs.setString('token', jsonEncode(token.toJson()));
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    await app_firebase_auth.FirebaseAuth.instance.signOut();

    _isAuthenticated = false;
    _user = null;
    _profile = null;
    _token = null;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    debugPrint('isAuthenticated: $_isAuthenticated');
    String? userJson = prefs.getString('user');
    String? profileJson = prefs.getString('profile');
    String? tokenJson = prefs.getString('token');

    if (_isAuthenticated &&
        userJson != null &&
        profileJson != null &&
        tokenJson != null) {
      _user = User.fromJson(jsonDecode(userJson));
      _profile = Profile.fromJson(jsonDecode(profileJson));
      _token = Token.fromJson(jsonDecode(tokenJson));
    }

    notifyListeners();
  }
}
