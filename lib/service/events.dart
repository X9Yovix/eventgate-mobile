import 'dart:convert';
import 'dart:io';
import 'package:eventgate_flutter/model/token.dart';
import 'package:eventgate_flutter/utils/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class EventsService {
  final String baseUrlEvent = 'http://10.0.2.2:8000/api/events';
  final String baseUrlRegister = 'http://10.0.2.2:8000/api/register';

  Token? _getTokenFromProvider(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.token;
  }

  Future<Map<String, dynamic>?> getTags(BuildContext context) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) {
      return {'error': 'Token is null'};
    }
    final url = Uri.parse('$baseUrlEvent/tags');
    final headers = {
      'Authorization': 'Bearer ${token.access}',
    };

    final response = await http.get(
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
        'Failed to logout: ${response.statusCode}, ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>?> addEvent(
    BuildContext context,
    String eventName,
    String eventLocation,
    String date,
    String startTime,
    String endTime,
    List<String> tags,
    List<File> images,
  ) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) {
      return {'error': 'Token is null'};
    }

    final url = Uri.parse('$baseUrlEvent/add');
    final headers = {
      'Authorization': 'Bearer ${token.access}',
    };

    final request = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..fields['event_name'] = eventName
      ..fields['location'] = eventLocation
      ..fields['day'] = date
      ..fields['start_time'] = startTime
      ..fields['end_time'] = endTime
      ..fields['tags'] = tags.join(',');

    if (images.isNotEmpty) {
      for (var image in images) {
        final imageBytes = await image.readAsBytes();
        final imagePart = http.MultipartFile.fromBytes(
          'images',
          imageBytes,
          filename: image.path.split('/').last,
        );
        request.files.add(imagePart);
      }
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
      throw Exception('Failed to add event: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> getRecentEvents(
    BuildContext context, {
    required int page,
    required int pageSize,
  }) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) {
      return {'error': 'Token is null'};
    }

    final url =
        Uri.parse('$baseUrlEvent/recent?page=$page&page_size=$pageSize');
    final headers = {
      'Authorization': 'Bearer ${token.access}',
    };

    final response = await http.get(url, headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'data': data};
    } else if (response.statusCode == 400) {
      debugPrint(data['error']);
      return {'error': data['error']};
    } else {
      throw Exception(
        'Failed to fetch recent events: ${response.statusCode}, ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>?> getEvent(BuildContext context, int id) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) {
      return {'error': 'Token is null'};
    }

    final headers = {
      'Authorization': 'Bearer ${token.access}',
    };
    final url = Uri.parse('$baseUrlEvent/?id=$id');
    final response = await http.get(url, headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'data': data};
    } else if (response.statusCode == 400) {
      debugPrint(data['error']);
      return {'error': data['error']};
    } else {
      throw Exception(
        'Failed to fetch event: ${response.statusCode}, ${response.body}',
      );
    }
  }

  Future<String> getPlaceName(double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Unknown location';
      }
      return 'Unknown location';
    } catch (e) {
      return 'Failed to fetch location';
    }
  }

  Future<Map<String, dynamic>?> markInterested(
      BuildContext context, int eventId) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) {
      return {'error': 'Token is null'};
    }

    final headers = {
      'Authorization': 'Bearer ${token.access}',
    };
    final url = Uri.parse('$baseUrlRegister/interested?event_id=$eventId');
    final response = await http.post(url, headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
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

  Future<Map<String, dynamic>?> requestToJoin(
      BuildContext context, int eventId) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) {
      return {'error': 'Token is null'};
    }

    final headers = {
      'Authorization': 'Bearer ${token.access}',
    };
    final url = Uri.parse('$baseUrlRegister/request?event_id=$eventId');
    final response = await http.post(url, headers: headers);
    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
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

  Future<Map<String, dynamic>?> checkUserEventStatus(
      BuildContext context, int eventId) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) {
      return {'error': 'Token is null'};
    }

    final headers = {
      'Authorization': 'Bearer ${token.access}',
    };
    final url = Uri.parse('$baseUrlRegister/event/status?event_id=$eventId');
    final response = await http.get(url, headers: headers);
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

  Future<Map<String, dynamic>?> removeInterest(
      BuildContext context, int eventId) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) return {'error': 'Token is null'};

    final headers = {
      'Authorization': 'Bearer ${token.access}',
    };
    final url = Uri.parse('$baseUrlRegister/interested/remove?event_id=$eventId');
    final response = await http.delete(url, headers: headers);

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

  Future<Map<String, dynamic>?> cancelRequest(
      BuildContext context, int eventId) async {
    Token? token = _getTokenFromProvider(context);
    if (token == null) return {'error': 'Token is null'};

    final headers = {
      'Authorization': 'Bearer ${token.access}',
    };
    final url = Uri.parse('$baseUrlRegister/request/cancel?event_id=$eventId');
    final response = await http.delete(url, headers: headers);

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
