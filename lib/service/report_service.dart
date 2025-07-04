import 'package:dio/dio.dart';
import 'package:gasguard_mobile/shared/service/http_service.dart';
import 'package:gasguard_mobile/models/gas_incident.dart';

class ReportService {
  static final HttpService _http = HttpService();

  static Future<Response> getReportsByProfile(String profileId) async {
    try {
      print('📊 Solicitando reportes para profileId: $profileId');
      final response = await _http.dio.get('/reports/profile/$profileId');
      print('📊 Respuesta recibida: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Error en ReportService: $e');
      rethrow;
    }
  }

  // Método para convertir respuesta del API a GasIncident
  static List<GasIncident> parseReportsToIncidents(List<dynamic> reportsJson) {
    try {
      return reportsJson.map((json) => GasIncident.fromApiJson(json)).toList();
    } catch (e) {
      print('❌ Error parseando reportes: $e');
      return [];
    }
  }
}