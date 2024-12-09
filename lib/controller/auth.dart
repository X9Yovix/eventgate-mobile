import 'dart:io';

import 'package:eventgate_flutter/model/token.dart';
import 'package:eventgate_flutter/model/user.dart';
import 'package:eventgate_flutter/service/auth.dart';
import 'package:eventgate_flutter/utils/auth_provider.dart';
import 'package:flutter/material.dart';

class AuthController {
  final AuthProvider authProvider = AuthProvider();
  final AuthService authService = AuthService();

  User? _user;
  Profile? _profile;
  Token? _token;

  String? _message;
  String? _error;

  User? getUser() => _user;
  Profile? getProfile() => _profile;
  Token? getToken() => _token;

  String? getMessage() => _message;
  String? getError() => _error;
  void setMessage(String? message) => _message = message;
  void setError(String? error) => _error = error;

  Future<void> login(String username, String password) async {
    try {
      var response = await authService.login(username, password);

      if (response != null) {
        if (response['error'] != null) {
          _error = response['error'];
          return;
        }

        if (response['data'] != null) {
          _user = User.fromJson(response['data']['user']);
          _profile = Profile.fromJson(response['data']['profile']);
          _token = Token.fromJson(response['data']['token']);
          _message = response['data']['message'];

          authService.authenticateWithFirebase(_token!.firebaseToken);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      _error = 'Internal server error';
    }
  }

  Future<void> register(User user, String password) async {
    try {
      var response = await authService.register(user, password);

      if (response != null) {
        if (response['error'] != null) {
          _error = response['error'];
          return;
        }

        if (response['data'] != null) {
          _message = response['data']['message'];
          return;
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      _error = 'Internal server error';
    }
  }

  Future<void> logout(context) async {
    try {
      var response = await authService.logout(context);

      if (response != null) {
        if (response['error'] != null) {
          _error = response['error'];
          return;
        }

        if (response['data'] != null) {
          await authProvider.logout();
          _message = response['data']['message'];
          return;
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      _error = 'Internal server error';
    }
  }

  Future<void> completeProfile(context, Profile profile, File? image) async {
    try {
      var response = await authService.completeProfile(context, profile, image);

      if (response != null) {
        if (response['error'] != null) {
          _error = response['error'];
          return;
        }

        if (response['data'] != null) {
          _message = response['data']['message'];
          return;
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      _error = 'Internal server error';
    }
  }

  Future<void> skipCompleteProfile(context) async {
    try {
      debugPrint('he: start controller');
      var response = await authService.skipCompleteProfile(context);
      debugPrint('he: controller $response');
      if (response != null) {
        if (response['error'] != null) {
          _error = response['error'];
          return;
        }

        if (response['data'] != null) {
          _message = response['data']['message'];
          return;
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      _error = 'Internal server error';
    }
  }
}
