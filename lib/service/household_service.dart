import 'package:dio/dio.dart';
import 'package:gasguard_mobile/shared/service/http_service.dart';

class HouseholdService {
  static final HttpService _http = HttpService();

  static Future<Response> getHouseholdMembersByProfile(String profileId) {
    return _http.dio.get('/contacts/profile/$profileId');
  }

  static Future<Response> createHouseholdMember({
    required String profileId,
    required String name,
    required String email,
    required String phone,
    required bool emergencyContact,
    required bool gasAlerts,
  }) {
    return _http.dio.post('/contacts', data: {
      'profileId': int.parse(profileId),
      'name': name,
      'email': email,
      'phone': phone,
      'emergencyContact': emergencyContact,
      'gasAlerts': gasAlerts,
    });
  }

  static Future<Response> updateHouseholdMember(String id, {
    required String name,
    required String email,
    required String phone,
    required bool emergencyContact,
    required bool gasAlerts,
  }) {
    return _http.dio.patch('/contacts/$id', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'emergencyContact': emergencyContact,
      'gasAlerts': gasAlerts,
    });
  }

  static Future<Response> deleteHouseholdMember(String id) {
    return _http.dio.delete('/contacts/$id');
  }
}