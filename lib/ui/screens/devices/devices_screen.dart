import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:gasguard_mobile/models/device.dart';
import 'package:gasguard_mobile/models/gas_reading.dart';
import 'package:gasguard_mobile/models/system_status.dart';
import 'package:gasguard_mobile/ui/common/app_header.dart';
import 'package:gasguard_mobile/ui/screens/devices/components/device_item.dart';
import '../../../utils/app_router.dart';
import '../../../utils/top_menu.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({Key? key}) : super(key: key);

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  late List<Device> _devices;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() {
    // Simulamos una carga de datos
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        final now = DateTime.now();
        
        _devices = [
          Device(
            id: 'DEV0001XXXXXX',
            name: 'Sensor Cocina',
            isOnline: true,
            lastSeen: now,
            location: 'Cocina',
            lastReading: GasReading(
              value: 15.0,
              timestamp: now,
            ),
            systemStatus: SystemStatus(),
            readings: _generateSampleReadings(now, 20, false),
          ),
          Device(
            id: 'DEV0002XXXXXX',
            name: 'Sensor Sala',
            isOnline: true,
            lastSeen: now.subtract(const Duration(minutes: 5)),
            location: 'Sala',
            lastReading: GasReading(
              value: 12.0,
              timestamp: now.subtract(const Duration(minutes: 5)),
            ),
            systemStatus: SystemStatus(),
            readings: _generateSampleReadings(now.subtract(const Duration(minutes: 5)), 20, false),
          ),
          Device(
            id: 'DEV0003XXXXXX',
            name: 'Sensor Sótano',
            isOnline: false,
            lastSeen: now.subtract(const Duration(hours: 3)),
            location: 'Sótano',
            lastReading: GasReading(
              value: 8.0,
              timestamp: now.subtract(const Duration(hours: 3)),
            ),
            systemStatus: SystemStatus(lightingSystemActive: false),
            readings: _generateSampleReadings(now.subtract(const Duration(hours: 3)), 20, false),
          ),
        ];
        
        _isLoading = false;
      });
    });
  }
  
  // Generar lecturas de muestra
  List<GasReading> _generateSampleReadings(DateTime endTime, int count, bool includeEmergency) {
    List<GasReading> readings = [];
    final random = math.Random();
    
    for (int i = 0; i < count; i++) {
      final timestamp = endTime.subtract(Duration(minutes: (count - i) * 10));
      
      double value;
      bool isEmergencyReading = false;
      
      if (includeEmergency && i > count * 0.7) {
        // Lecturas de emergencia hacia el final
        value = 70.0 + random.nextDouble() * 25.0;
        isEmergencyReading = true;
      } else {
        // Lecturas normales
        value = 10.0 + random.nextDouble() * 20.0;
        
        // Pequeña probabilidad de una lectura anómala
        if (random.nextInt(100) < 5) {
          value = 20.0 + random.nextDouble() * 30.0;
        }
      }
      
      readings.add(GasReading(
        value: value,
        timestamp: timestamp,
        isEmergency: isEmergencyReading,
      ));
    }
    
    return readings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2A),
      body: SafeArea(
        child: Column(
          children: [
            // Header con el logo y menú
            AppHeader(
              title: 'Dispositivos',
              onMenuPressed: () => _showTopMenu(context),
            ),

            // Contenido principal
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1A2B3D),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mis dispositivos',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!_isLoading)
                            Text(
                              '${_devices.length} dispositivos',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Lista de dispositivos
                      Expanded(
                        child: _isLoading
                            ? _buildLoadingState()
                            : _devices.isEmpty
                                ? _buildEmptyState()
                                : _buildDevicesList(),
                      ),

                      // Botón para añadir dispositivo
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _navigateToAddDevice(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4ECDC4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Añadir dispositivo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar estado de carga
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF4ECDC4),
          ),
          SizedBox(height: 16),
          Text(
            'Cargando dispositivos...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para mostrar cuando no hay dispositivos
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron dispositivos',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade tu primer dispositivo para comenzar a monitorear',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget para mostrar la lista de dispositivos
  Widget _buildDevicesList() {
    return ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) {
        final device = _devices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: DeviceItem(
            device: device,
            onTap: () => _navigateToDeviceDetail(context, device),
          ),
        );
      },
    );
  }

  // Navegar a la pantalla de detalle del dispositivo
  void _navigateToDeviceDetail(BuildContext context, Device device) {
    Navigator.pushNamed(
      context,
      AppRouter.deviceDetail,
      arguments: {'device': device},
    );
  }

  // Navegar a la pantalla para añadir dispositivo
  void _navigateToAddDevice(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRouter.deviceDetail,
    ).then((_) {
      // Refrescar la lista cuando vuelva
      _loadDevices();
    });
  }

  // Muestra el menú superior
  void _showTopMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => TopMenu(
        onLogout: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, AppRouter.auth);
        },
      ),
    );
  }
}