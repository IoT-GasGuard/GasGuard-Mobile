import 'package:dio/dio.dart';
import 'package:gasguard_mobile/shared/service/http_service.dart';

class ProfileService {
  static final HttpService _http = HttpService();

  static Future<Response> getProfileById(String id) {
    return _http.dio.get('/profiles/$id');
  }
}