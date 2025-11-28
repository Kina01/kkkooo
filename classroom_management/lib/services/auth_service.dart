// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://desktop-nkukmb9.local:8080/api/auth';
  // static const String baseUrl = 'http://172.50.169.165:8080/api/auth';

  static Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> data = (response.body.isNotEmpty)
          ? json.decode(response.body) as Map<String, dynamic>
          : {};

      if (response.statusCode == 200 || response.statusCode == 400) {
        return LoginResponse.fromJson(data);
      } else {
        return LoginResponse(message: 'Lỗi kết nối: ${response.statusCode}', status: 'error');
      }
    } catch (e) {
      return LoginResponse(message: 'Lỗi kết nối: $e', status: 'error');
    }
  }

  // ---------- GỬI MÃ XÁC THỰC ----------
  static Future<SimpleApiResponse> sendVerificationCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-verification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      final Map<String, dynamic> data = (response.body.isNotEmpty)
          ? json.decode(response.body) as Map<String, dynamic>
          : {};

      return SimpleApiResponse.fromJson(data);
    } catch (e) {
      return SimpleApiResponse(
          message: 'Lỗi kết nối: $e', status: 'error', data: null);
    }
  }

  // ---------- XÁC MINH OTP ----------
  static Future<VerifyOtpResponse> verifyOtp(
      String email, String otpCode) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'verificationCode': otpCode,
        }),
      );

      final Map<String, dynamic> data = (response.body.isNotEmpty)
          ? json.decode(response.body) as Map<String, dynamic>
          : {};

      return VerifyOtpResponse.fromJson(data);
    } catch (e) {
      return VerifyOtpResponse(
        message: 'Lỗi kết nối: $e',
        status: 'error',
        data: null,
        verified: false,
      );
    }
  }

  // ---------- ĐĂNG KÝ ----------
  static Future<SimpleApiResponse> register(
      RegistrationRequest request) async {
    try {
      // chọn endpoint dựa theo role
      final String url = request.isTeacher
          ? '$baseUrl/register/teacher'
          : '$baseUrl/register/student';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request.toJson()),
      );

      final Map<String, dynamic> data = (response.body.isNotEmpty)
          ? json.decode(response.body) as Map<String, dynamic>
          : {};

      return SimpleApiResponse.fromJson(data);
    } catch (e) {
      return SimpleApiResponse(
          message: 'Lỗi kết nối: $e', status: 'error', data: null);
    }
  }

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');
    if (userString != null && userString.isNotEmpty) {
      final Map<String, dynamic> userMap = json.decode(userString);
      return User.fromJson(Map<String, dynamic>.from(userMap));
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  static Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null;
  }
}
