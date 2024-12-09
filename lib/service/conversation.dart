import 'dart:convert';
import 'package:eventgate_flutter/model/token.dart';
import 'package:eventgate_flutter/utils/auth_provider.dart'
    as app_auth_provider;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ConversationService {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Token? _getTokenFromProvider(BuildContext context) {
    final authProvider =
        Provider.of<app_auth_provider.AuthProvider>(context, listen: false);
    return authProvider.token;
  }

  Future<Map<String, dynamic>?> test(BuildContext context) async {
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
    if (response.statusCode == 200) {
      return {'data': data};
    } else if (response.statusCode == 400) {
      debugPrint(data['error']);
      return {'error': data['error']};
    } else {
      throw Exception(
        'Failed: ${response.statusCode}, ${response.body}',
      );
    }
  }
}
