import 'package:dio/dio.dart';
import 'package:gasguard_mobile/shared/service/http_service.dart';

class DeviceService {
  static final HttpService _http = HttpService();

  static Future<Response> getDevicesByProfile(String profileId) {
    return _http.dio.get('/devices/profile/$profileId');
  }

  static Future<Response> updateDevice(String id, Map<String, dynamic> data) {
    return _http.dio.patch('/devices/$id', data: data);
  }

  static Future<Response> deleteDevice(String id) {
    return _http.dio.delete('/devices/$id');
  }

  static Future<Response> createDevice({
    required String deviceId,
    required String name,
    required String location,
    required String profileId,
  }) {
    return _http.dio.post('/devices', data: {
      'deviceId': deviceId,
      'name': name,
      'location': location,
      'profileId': int.parse(profileId),
    });
  }
}