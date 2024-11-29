import 'dart:convert';
import 'dart:io';
import 'package:eventgate_flutter/model/token.dart';
import 'package:eventgate_flutter/model/user.dart' as app_user;
import 'package:eventgate_flutter/utils/auth_provider.dart'
    as app_auth_provider;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api/profiles';

  Token? _getTokenFromProvider(BuildContext context) {
    final authProvider =
        Provider.of<app_auth_provider.AuthProvider>(context, listen: false);
    return authProvider.token;
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'data': data};
    } else if (response.statusCode == 400) {
      return {'error': data['error']};
    } else {
      throw Exception(
          'Failed to login: ${response.statusCode}, ${response.toString()}');
    }
  }

  Future<void> authenticateWithFirebase(String firebaseToken) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
      debugPrint('userCredential: $userCredential');
    } catch (e) {
      debugPrint('error authenticating with Firebase: $e');
    }
  }

  Future<Map<String, dynamic>?> register(
      app_user.User user, String password) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': user.username,
        'first_name': user.firstName,
        'last_name': user.lastName,
        'email': user.email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return {'data': data};
    } else if (response.statusCode == 400) {
      debugPrint(data['error']);
      return {'error': data['error']};
    } else {
      throw Exception(
          'Failed to login: ${response.statusCode}, ${response.toString()}');
    }
  }

  Future<Map<String, dynamic>?> logout(context) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) {
      return {'error': 'Token is null'};
    }
    final url = Uri.parse('$baseUrl/logout');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token.access}',
    };
    final body = jsonEncode({'refresh': token.refresh});

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 205) {
      return {'data': data};
    } else if (response.statusCode == 400) {
      debugPrint(data['error']);
      return {'error': data['error']};
    } else {
      throw Exception(
        'Failed to logout: ${response.statusCode}, ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>?> completeProfile(
      context, app_user.Profile profile, File? image) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) {
      return {'error': 'Token is null'};
    }

    final url = Uri.parse('$baseUrl/complete-profile');
    final headers = {
      'Authorization': 'Bearer ${token.access}',
    };

    final request = http.MultipartRequest('PATCH', url)
      ..headers.addAll(headers)
      ..fields['birth_date'] = profile.birthDate ?? ''
      ..fields['bio'] = profile.bio ?? ''
      ..fields['phone_number'] = profile.phoneNumber ?? ''
      ..fields['gender'] = profile.gender ?? '';

    if (image != null) {
      final imageBytes = await image.readAsBytes();
      final imagePart = http.MultipartFile.fromBytes(
        'profile_picture',
        imageBytes,
        filename: image.path.split('/').last,
      );
      request.files.add(imagePart);
    }

    final response = await request.send();

    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);

    if (response.statusCode == 201) {
      return {'data': data};
    } else if (response.statusCode == 400) {
      debugPrint(data['error']);
      return {'error': data['error']};
    } else {
      throw Exception(
        'Failed to complete profile: ${response.statusCode}',
      );
    }
  }

  Future<Map<String, dynamic>?> skipCompleteProfile(context) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) {
      return {'error': 'Token is null'};
    }
    final url = Uri.parse('$baseUrl/skip-complete-profile');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token.access}',
    };

    final response = await http.patch(
      url,
      headers: headers,
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return {'data': data};
    } else if (response.statusCode == 400) {
      debugPrint(data['error']);
      return {'error': data['error']};
    } else {
      throw Exception(
        'Failed to complete profile: ${response.statusCode}, ${response.body}',
      );
    }
  }
}
