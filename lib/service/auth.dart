import 'dart:convert';
import 'package:eventgate_flutter/model/user.dart';
import 'package:eventgate_flutter/utils/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api/profiles';
  final AuthProvider authProvider = AuthProvider();

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

  Future<Map<String, dynamic>?> register(User user, String password) async {
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

  Future<Map<String, dynamic>?> logout(String access, String refresh) async {
    final url = Uri.parse('$baseUrl/logout');


    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $access',
    };
    final body = jsonEncode({'refresh': refresh});

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
}
