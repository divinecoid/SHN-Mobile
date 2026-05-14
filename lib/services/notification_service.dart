import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../utils/auth_helper.dart';

class NotificationService {
  static Future<List<NotificationItem>> fetchMyNotifications({bool unreadOnly = false}) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final endpoint = dotenv.env['API_NOTIFICATIONS'] ?? '/api/notifications';
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) return [];

      final queryParams = unreadOnly ? '?unread=1' : '';
      final url = Uri.parse('$baseUrl$endpoint/mine$queryParams');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> items = data['data'];
          return items.map((json) => NotificationItem.fromJson(json)).toList();
        }
      } else if (AuthHelper.isUnauthorizedResponse(response.statusCode)) {
        throw Exception('Unauthorized');
      }
      
      return [];
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  static Future<bool> markAsRead(int notificationId) async {
    try {
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final endpoint = dotenv.env['API_NOTIFICATIONS'] ?? '/api/notifications';
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) return false;

      final url = Uri.parse('$baseUrl$endpoint/$notificationId/read');
      
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking notification as read: $e');
      return false;
    }
  }
}
