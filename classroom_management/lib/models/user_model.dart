// lib/models/user_model.dart
class User {
  final int userId;
  final String email;
  final String fullName;
  final String role;

  User({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String _toString(dynamic v) => v == null ? '' : v.toString();

    return User(
      userId: _toInt(json['userId']),
      email: _toString(json['email']),
      fullName: _toString(json['fullName']),
      role: _toString(json['role']),
    );
  }

  bool get isTeacher => role.toUpperCase() == 'TEACHER';
  bool get isStudent => role.toUpperCase() == 'STUDENT';

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'email': email,
      'fullName': fullName,
      'role': role,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({ required this.email, required this.password });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}

class LoginResponse {
  final String message;
  final String status;
  final User? data;

  LoginResponse({ required this.message, required this.status, this.data });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? User.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

/// Response chung cho các API đơn giản (send-otp, register)
class SimpleApiResponse {
  final String message;
  final String status;
  final Map<String, dynamic>? data;

  SimpleApiResponse({
    required this.message,
    required this.status,
    this.data,
  });

  factory SimpleApiResponse.fromJson(Map<String, dynamic> json) {
    return SimpleApiResponse(
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }

  bool get isSuccess => status == 'success';
}

/// Response riêng cho verify OTP (có thêm trường verified)
class VerifyOtpResponse extends SimpleApiResponse {
  final bool verified;

  VerifyOtpResponse({
    required String message,
    required String status,
    Map<String, dynamic>? data,
    required this.verified,
  }) : super(message: message, status: status, data: data);

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'])
          : null,
      verified: json['verified'] == true,
    );
  }
}

/// Request đăng ký
class RegistrationRequest {
  final String fullName;
  final String email;
  final String password;
  final bool isTeacher; // true = giáo viên, false = sinh viên

  RegistrationRequest({
    required this.fullName,
    required this.email,
    required this.password,
    required this.isTeacher,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
      };
}