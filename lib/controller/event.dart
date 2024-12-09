import 'dart:async';
import 'dart:io';

import 'package:eventgate_flutter/service/events.dart';
import 'package:eventgate_flutter/utils/auth_provider.dart';
import 'package:flutter/material.dart';

class EventController {
  final AuthProvider authProvider = AuthProvider();
  final EventsService eventsService = EventsService();

  String? _message;
  String? _error;

  String? getMessage() => _message;
  String? getError() => _error;
  void setMessage(String? message) => _message = message;
  void setError(String? error) => _error = error;

  Future<List<String>> getTags(BuildContext context) async {
    try {
      var response = await eventsService.getTags(context);
      if (response != null && response['data'] != null) {
        return List<String>.from(response['data']['tags']);
      }
    } catch (e) {
      debugPrint('Error: $e');
      _error = 'Internal server error';
    }
    return [];
  }

  Future<void> addEvent(
    BuildContext context,
    String eventName,
    String eventLocation,
    String date,
    String startTime,
    String endTime,
    List<String> tags,
    List<File> image,
  ) async {
    try {
      final response = await eventsService.addEvent(
        context,
        eventName,
        eventLocation,
        date,
        startTime,
        endTime,
        tags,
        image,
      );

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
    } catch (error) {
      setError('Error: $error');
      debugPrint('Error: $error');
    }
  }

  Future<Map<String, dynamic>> getRecentEvents(
    BuildContext context, {
    int page = 1,
    int pageSize = 5,
  }) async {
    try {
      var response = await eventsService.getRecentEvents(
        context,
        page: page,
        pageSize: pageSize,
      );

      if (response != null) {
        if (response['error'] != null) {
          _error = response['error'];
          return {};
        }

        if (response['data'] != null) {
          return response['data'];
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      _error = 'Internal server error';
    }
    return {};
  }

  Future<Map<String, dynamic>> getEvent(BuildContext context, int id) async {
    try {
      var response = await eventsService.getEvent(context, id);

      if (response != null) {
        if (response['error'] != null) {
          _error = response['error'];
          return {};
        }

        if (response['data'] != null) {
          return response['data'];
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
      _error = 'Internal server error';
    }
    return {};
  }

  Future<String> getPlaceName(double latitude, double longitude) async {
    try {
      String placeName = await eventsService.getPlaceName(latitude, longitude);

      if (placeName == 'Unknown location' ||
          placeName == 'Failed to fetch location') {
        _error = 'Could not fetch place name';
        return placeName;
      }

      return placeName;
    } catch (e) {
      debugPrint('Error in getPlaceName: $e');
      _error = 'Internal server error';
      return 'Failed to fetch location';
    }
  }

  Future<void> markInterested(BuildContext context, int eventId) async {
    try {
      final response = await eventsService.markInterested(context, eventId);

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
    } catch (error) {
      setError('Error: $error');
      debugPrint('Error: $error');
    }
  }

  Future<void> requestToJoin(BuildContext context, int eventId) async {
    try {
      final response = await eventsService.requestToJoin(context, eventId);

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
    } catch (error) {
      setError('Error: $error');
      debugPrint('Error: $error');
    }
  }

  Future<Map<String, dynamic>?> checkUserEventStatus(
      BuildContext context, int eventId) async {
    try {
      final response =
          await eventsService.checkUserEventStatus(context, eventId);

      if (response != null) {
        if (response['error'] != null) {
          _error = response['error'];
          return null;
        }
        return response['data'];
      }
    } catch (e) {
      debugPrint('Error: $e');
      _error = 'Internal server error';
    }
    return null;
  }

  Future<void> removeInterest(BuildContext context, int eventId) async {
    try {
      final response = await eventsService.removeInterest(context, eventId);
      if (response != null) {
        if (response['error'] != null) {
          setError(response['error']);
          return;
        }
        setMessage('Interest removed successfully.');
      }
    } catch (error) {
      setError('Error: $error');
      debugPrint('Error: $error');
    }
  }

  Future<void> cancelRequest(BuildContext context, int eventId) async {
    try {
      final response = await eventsService.cancelRequest(context, eventId);
      if (response != null) {
        if (response['error'] != null) {
          setError(response['error']);
          return;
        }
        setMessage('Request canceled successfully.');
      }
    } catch (error) {
      setError('Error: $error');
      debugPrint('Error: $error');
    }
  }
}
