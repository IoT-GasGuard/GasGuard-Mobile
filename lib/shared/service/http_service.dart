import 'package:dio/dio.dart';
import 'package:gasguard_mobile/shared/helpers/storage_helper.dart';
import 'package:gasguard_mobile/config/environment.dart';

class HttpService {
  final Dio dio;
  static String? _token;

  HttpService()
      : dio = Dio(
          BaseOptions(
            baseUrl: Environment.BASE_URL,
            connectTimeout: Duration(seconds: 30),
            receiveTimeout: Duration(seconds: 30),
          ),
        ) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // Obtener token cada vez (no cachear)
          final token = await StorageHelper.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Content-Type'] = 'application/json';
          
          print('🔍 Request: ${options.method} ${options.path}');
          print('🔍 Headers: ${options.headers}');
          
          handler.next(options);
        } catch (e) {
          print('❌ Error en interceptor: $e');
          handler.next(options);
        }
      },
      onResponse: (response, handler) {
        print('✅ Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ HTTP Error: ${error.response?.statusCode} ${error.message}');
        handler.next(error);
      },
    ));
  }
}