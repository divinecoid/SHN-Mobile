import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../pages/page_dashboard.dart';
import '../models/login_model.dart';

class LoginController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // Getters
  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  
  // Callback untuk update UI
  late VoidCallback onStateChanged;
  
  LoginController({required this.onStateChanged});
  
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    onStateChanged();
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    onStateChanged();
  }
  
  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;
    
    _setLoading(true);
    
    try {
      // Prepare login request
      final loginRequest = LoginRequest(
        username: usernameController.text,
        password: passwordController.text,
      );
      
      // Get base URL from environment
      final baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8000';
      final loginEndpoint = dotenv.env['API_LOGIN'] ?? '/api/auth/login';
      final url = Uri.parse('$baseUrl$loginEndpoint');
      
      // Debug: Print URL being used
      print('Login URL: $url');
      print('Request Body: ${json.encode(loginRequest.toMap())}');
      
      // Make HTTP request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(loginRequest.toMap()),
      );
      
      // Debug: Print response details
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      // Parse response regardless of status code
      Map<String, dynamic> responseData;
      LoginResponse loginResponse;
      
      try {
        responseData = json.decode(response.body);
        loginResponse = LoginResponse.fromMap(responseData);
      } catch (parseError) {
        print('JSON Parse Error: $parseError');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Response tidak valid dari server'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
      
      if (response.statusCode == 200 && loginResponse.success && loginResponse.data != null) {
        // Login successful
        // Save login state and token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', loginResponse.data!.username);
        await prefs.setString('name', loginResponse.data!.name);
        await prefs.setString('token', loginResponse.data!.token);
        await prefs.setString('refresh_token', loginResponse.data!.refreshToken);
        await prefs.setStringList('roles', loginResponse.data!.roles);
        
        if (context.mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginResponse.message),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 422 || response.statusCode == 400) {
        // Login failed (Unauthorized, Validation Error, Bad Request)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginResponse.message.isNotEmpty 
                ? loginResponse.message 
                : 'Username atau password salah'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else if (response.statusCode >= 500) {
        // Server error
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Server sedang bermasalah. Coba lagi nanti (${response.statusCode})'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // Other HTTP errors
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loginResponse.message.isNotEmpty 
                ? loginResponse.message 
                : 'Terjadi kesalahan. Coba lagi (${response.statusCode})'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Network or parsing error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    _setLoading(false);
  }
  
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username tidak boleh kosong';
    }
    return null;
  }
  
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    return null;
  }
  
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}
