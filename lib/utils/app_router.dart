import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/device.dart'; // ¡FALTA ESTA IMPORTACIÓN!
import 'package:gasguard_mobile/ui/screens/auth/auth_screen.dart';
import 'package:gasguard_mobile/ui/screens/dashboard/dashboard_screen.dart';
import 'package:gasguard_mobile/ui/screens/devices/devices_screen.dart';
import 'package:gasguard_mobile/ui/screens/devices/device_detail_screen.dart';

class AppRouter {
  /// Rutas estáticas de la aplicación
  static const String auth = '/';
  static const String dashboard = '/dashboard';
  static const String devices = '/devices';
  static const String deviceDetail = '/device-detail';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      auth: (context) => const AuthScreen(),
      dashboard: (context) => const DashboardScreen(),
      devices: (context) => const DevicesScreen(),
    };
  }

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case deviceDetail:
        // Corregir esta parte
        final args = settings.arguments as Map<String, dynamic>?;
        final device = args != null ? args['device'] as Device? : null;
        
        return MaterialPageRoute(
          builder: (_) => DeviceDetailScreen(device: device),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Ruta no encontrada'),
            ),
          ),
        );
    }
  }
}