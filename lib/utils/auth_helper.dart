import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/page_login.dart';

class AuthHelper {
  // Method untuk menangani redirect ke login ketika sesi berakhir
  static Future<void> handleSessionExpired(BuildContext context) async {
    try {
      // Clear semua data login dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Show message bahwa sesi telah berakhir
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi Anda telah berakhir. Silakan login kembali.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Navigate ke halaman login dengan pushReplacement
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false, // Remove semua route sebelumnya
        );
      }
    } catch (e) {
      debugPrint('Error handling session expired: $e');
      // Fallback: langsung navigate ke login
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  // Method untuk menangani error 401 secara konsisten
  static Future<void> handleUnauthorized(BuildContext context, String? customMessage) async {
    final message = customMessage ?? 'Sesi Anda telah berakhir. Silakan login kembali.';
    
    try {
      // Clear semua data login dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Show message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Navigate ke halaman login dengan pushAndRemoveUntil
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false, // Remove semua route sebelumnya
        );
      }
    } catch (e) {
      debugPrint('Error handling unauthorized: $e');
      // Fallback: langsung navigate ke login
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  // Method untuk check apakah response adalah 401 Unauthorized
  static bool isUnauthorizedResponse(int statusCode) {
    return statusCode == 401;
  }

  // Method untuk logout manual (bisa dipanggil dari UI)
  static Future<void> logout(BuildContext context) async {
    try {
      // Clear semua data login dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Show message logout berhasil
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda telah logout.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate ke halaman login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Fallback: langsung navigate ke login
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }
}
