class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  factory LoginRequest.fromMap(Map<String, dynamic> map) {
    return LoginRequest(
      username: map['username'] ?? '',
      password: map['password'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class LoginData {
  final String token;
  final String refreshToken;
  final String tokenType;
  final String username;
  final String name;
  final List<String> roles;

  LoginData({
    required this.token,
    required this.refreshToken,
    required this.tokenType,
    required this.username,
    required this.name,
    required this.roles,
  });

  factory LoginData.fromMap(Map<String, dynamic> map) {
    return LoginData(
      token: map['token'] ?? '',
      refreshToken: map['refresh_token'] ?? '',
      tokenType: map['token_type'] ?? 'Bearer',
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      roles: List<String>.from(map['roles'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'username': username,
      'name': name,
      'roles': roles,
    };
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;

  LoginResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory LoginResponse.fromMap(Map<String, dynamic> map) {
    // Untuk response sukses, data ada di level root
    // Untuk response gagal, data bernilai null
    LoginData? loginData;
    
    if (map['success'] == true && map['token'] != null) {
      // Jika sukses, ambil data dari response langsung
      loginData = LoginData.fromMap(map);
    }

    return LoginResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      data: loginData,
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> result = {
      'success': success,
      'message': message,
    };

    if (data != null) {
      // Jika ada data, gabungkan dengan response
      result.addAll(data!.toMap());
    } else {
      result['data'] = null;
    }

    return result;
  }
}
