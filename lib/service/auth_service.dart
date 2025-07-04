import 'package:dio/dio.dart';
import 'package:gasguard_mobile/shared/service/http_service.dart';

class AuthService {
  static final HttpService _http = HttpService();

  static Future<Response> signUp(String email, String password) {
    return _http.dio.post(
      '/auth/sign-up',
      data: {'email': email, 'password': password},
    );
  }

  static Future<Response> signIn(String email, String password) {
    return _http.dio.post(
      '/auth/sign-in',
      data: {'email': email, 'password': password},
    );
  }
}