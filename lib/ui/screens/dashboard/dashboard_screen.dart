import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/device.dart';
import 'package:gasguard_mobile/models/gas_reading.dart';
import 'package:gasguard_mobile/service/device_service.dart';
import 'package:gasguard_mobile/shared/helpers/storage_helper.dart';
import 'package:gasguard_mobile/ui/common/app_header.dart';
import 'package:gasguard_mobile/utils/top_menu.dart';
import '../../../service/stomp_web_socket_service.dart';
import 'components/air_quality_chart.dart';
import 'components/air_quality_status.dart';
import 'components/systems_control.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  Device? selectedDevice;
  List<Device> devices = [];
  bool isLoading = true;
  bool isEmergencyMode = false;
  String? error;

  // 🔥 USAR SINGLETON
  final StompWebSocketService _webSocketService = StompWebSocketService();
  bool _alertDialogShown = false;
  
  bool _isFirstLoad = true;
  Map<String, Device> _deviceStates = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDevices();
    
    // 🔥 CONFIGURAR CALLBACK DEL SINGLETON
    _webSocketService.onDataReceived = _handleWebSocketData;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 🔥 NO DESCONECTAR COMPLETAMENTE - SOLO PAUSAR
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (selectedDevice != null) {
        print('🔄 App volvió al foreground - reconectando WebSocket');
        _connectWebSocket();
      }
    }
  }

  // 🔥 MÉTODO MEJORADO PARA PRESERVAR ESTADO
  Future<void> _loadDevices() async {
    setState(() {
      if (_isFirstLoad) {
        isLoading = true;
      }
      error = null;
    });

    try {
      final user = await StorageHelper.getUser();
      print('👤 Usuario obtenido de StorageHelper: ${user?.toJson()}');
      
      if (user == null || user.profileId.isEmpty) {
        setState(() {
          error = 'No se pudo obtener información del usuario';
          isLoading = false;
        });
        return;
      }

      print('📱 Cargando dispositivos para profileId: ${user.profileId}');
      final response = await DeviceService.getDevicesByProfile(user.profileId);

      if (response.statusCode == 200) {
        final List<dynamic> devicesJson = response.data;
        final List<Device> loadedDevices = devicesJson
            .map((json) => Device.fromJson(json))
            .toList();

        print('📱 Dispositivos cargados: ${loadedDevices.length}');

        if (loadedDevices.isEmpty) {
          setState(() {
            devices = [];
            selectedDevice = null;
            isLoading = false;
          });
          return;
        }

        // 🔥 PRESERVAR DATOS EXISTENTES O INICIALIZAR
        for (var device in loadedDevices) {
          final existingDevice = _deviceStates[device.deviceId];
          
          if (existingDevice != null) {
            // Preservar datos existentes
            device.readings = existingDevice.readings;
            device.lastReading = existingDevice.lastReading;
            device.status = existingDevice.status;
            device.systemStatus = existingDevice.systemStatus;
            print('📋 Preservando datos existentes para ${device.deviceId}');
          } else {
            // 🔥 INTENTAR OBTENER DATOS DESDE CACHE DEL WEBSOCKET
            final cachedData = _webSocketService.getLastData(device.deviceId);
            if (cachedData != null) {
              final gasValue = (cachedData['value'] as num?)?.toDouble()?.clamp(0.0, 100.0) ?? 0.0;
              final status = cachedData['status'] ?? 'NORMAL';
              
              device.lastReading = GasReading(
                value: gasValue,
                timestamp: DateTime.now(),
                isEmergency: status == 'ALERT',
              );
              device.status = status;
              
              // Agregar lectura al historial
              device.readings = [device.lastReading!];
              
              print('💾 Restaurando datos desde cache WebSocket para ${device.deviceId}: ${gasValue}%, Status: $status');
            } else if (_isFirstLoad) {
              // Solo inicializar con datos simulados si no hay cache
              final now = DateTime.now();
              device.readings = _generateSampleReadings(now, 5, false);
              device.lastReading ??= GasReading(value: 0.0, timestamp: now);
              print('🆕 Inicializando datos simulados para ${device.deviceId}');
            }
          }
          
          _deviceStates[device.deviceId] = device;
        }

        setState(() {
          devices = loadedDevices;
          
          // 🔥 PRESERVAR DISPOSITIVO SELECCIONADO
          if (selectedDevice != null) {
            final currentDeviceId = selectedDevice!.deviceId;
            selectedDevice = devices.firstWhere(
              (d) => d.deviceId == currentDeviceId,
              orElse: () => devices.first,
            );
            isEmergencyMode = selectedDevice!.status == 'ALERT';
          } else {
            selectedDevice = devices.isNotEmpty ? devices.first : null;
          }
          
          isLoading = false;
          _isFirstLoad = false;
        });

        // Conectar WebSocket y restaurar callback
        if (selectedDevice != null) {
          print('🔌 Reconectando WebSocket para: ${selectedDevice!.deviceId}');
          _webSocketService.onDataReceived = _handleWebSocketData;
          _connectWebSocket();
        }
      } else {
        setState(() {
          error = 'Error al cargar dispositivos: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error completo en _loadDevices: $e');
      setState(() {
        error = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  void _connectWebSocket() {
    if (selectedDevice != null) {
      print('🔌 Conectando WebSocket para: ${selectedDevice!.deviceId}');
      _webSocketService.connect(selectedDevice!.deviceId);
    }
  }

  void _handleWebSocketData(Map<String, dynamic> data) {
    if (!mounted) return;

    setState(() {
      double rawGasValue = (data['value'] as num?)?.toDouble() ??
          (data['ppm'] as num?)?.toDouble() ?? 0.0;
      
      final double gasValue = rawGasValue.clamp(0.0, 100.0);
      final String status = data['status'] ?? 'NORMAL';
      final String deviceId = data['deviceId'] ?? '';
      final bool isEmergency = status == 'ALERT';

      print('📊 Datos WebSocket: Device=$deviceId, Value=$gasValue, Status=$status');

      if (selectedDevice != null && deviceId == selectedDevice!.deviceId) {
        print('✅ Actualizando UI para dispositivo correcto: ${selectedDevice!.name}');

        final newReading = GasReading(
          value: gasValue,
          timestamp: DateTime.now(),
          isEmergency: isEmergency,
        );

        selectedDevice!.addReading(newReading);
        selectedDevice!.status = status;
        _deviceStates[deviceId] = selectedDevice!;

        print('🎯 Nueva lectura agregada: ${gasValue}% - Total lecturas: ${selectedDevice!.readings.length}');

        // Manejo de emergencia
        if (status == 'ALERT' && !isEmergencyMode) {
          isEmergencyMode = true;
          selectedDevice!.systemStatus.activateEmergencyProtocol();
          
          if (!_alertDialogShown) {
            _alertDialogShown = true;
            _showEmergencyAlert();
          }
          
          print('🔴 Modo emergencia ACTIVADO - Estado: ALERT');
        } else if (status != 'ALERT' && isEmergencyMode) {
          isEmergencyMode = false;
          selectedDevice!.systemStatus.restoreNormalOperation();
          _alertDialogShown = false;
          print('🟢 Modo emergencia DESACTIVADO - Estado: $status');
        }
      }
    });
  }

  // Generar lecturas simuladas para inicializar (solo usado al cargar por primera vez)
  List<GasReading> _generateSampleReadings(DateTime endTime, int count, bool includeEmergency) {
    // Tu código existente...
    List<GasReading> readings = [];
    final random = math.Random();

    for (int i = 0; i < count; i++) {
      final timestamp = endTime.subtract(Duration(minutes: (count - i) * 10));

      double value;
      bool isEmergencyReading = false;

      if (includeEmergency && i > count * 0.7) {
        value = 70.0 + random.nextDouble() * 25.0;
        isEmergencyReading = true;
      } else {
        value = 10.0 + random.nextDouble() * 20.0;
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

  // Método para cambiar entre modo normal y emergencia
  void _toggleEmergencyMode() {
    setState(() {
      isEmergencyMode = !isEmergencyMode;

      if (selectedDevice != null) {
        if (isEmergencyMode) {
          selectedDevice!.systemStatus.activateEmergencyProtocol();
        } else {
          selectedDevice!.systemStatus.restoreNormalOperation();
        }
      }
    });
  }

  // Mostrar alerta de emergencia
  void _showEmergencyAlert() {
    if (!mounted || selectedDevice == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2B3D),
        title: Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            Text(
              'ALERTA DE EMERGENCIA',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Se ha detectado una fuga de gas en ${selectedDevice!.location}.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Protocolos de seguridad activados:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            _buildProtocolItem('Corte de suministro de gas'),
            _buildProtocolItem('Apertura de puertas y ventanas'),
            _buildProtocolItem('Activación de sistema de ventilación'),
            _buildProtocolItem('Notificación a servicios de emergencia'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ENTENDIDO', style: TextStyle(color: Color(0xFF4ECDC4))),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF4ECDC4), size: 16),
          SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              onMenuPressed: () => TopMenu.showMenu(context),
            ),
            Expanded(
              child: isLoading
                  ? _buildLoadingState()
                  : error != null
                  ? _buildErrorState()
                  : devices.isEmpty
                  ? _buildEmptyState()
                  : _buildDashboardContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A2B3D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: const Center(
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
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A2B3D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              error ?? 'Error desconocido',
              style: TextStyle(
                color: Colors.red.withOpacity(0.7),
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDevices,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A2B3D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sensors_off,
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
              'Añade un dispositivo para comenzar a monitorear',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/devices'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4),
              ),
              child: const Text('Añadir dispositivo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    if (selectedDevice == null) return Container();

    return Container(
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
            _buildDeviceSelector(),
            const SizedBox(height: 20),

            Container(
              height: 90,
              child: AirQualityStatus(
                gasLevel: selectedDevice!.lastReading?.value ?? 0,
                isEmergencyMode: isEmergencyMode,
                onEmergencyToggle: _toggleEmergencyMode,
              ),
            ),
            const SizedBox(height: 15),

            Expanded(
              flex: 3, // 🔥 CAMBIAR DE 2 A 3 PARA QUE EL GRÁFICO OCUPE MÁS ESPACIO
              child: AirQualityChart(
                gasLevelData: selectedDevice!.readings.map((r) => r.value).toList(),
                gasLevel: selectedDevice!.lastReading?.value ?? 0,
                isEmergencyMode: isEmergencyMode,
                toggleEmergencyMode: _toggleEmergencyMode,
              ),
            ),

            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF0F1B2A),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estadísticas del día',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Nivel máximo',
                            '${selectedDevice!.readings.isNotEmpty ? selectedDevice!.readings.map((r) => r.value).reduce((a, b) => a > b ? a : b).toStringAsFixed(1) : "0.0"}%',
                            Icons.trending_up,
                            Colors.red,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Nivel promedio',
                            '${selectedDevice!.readings.isNotEmpty ? (selectedDevice!.readings.map((r) => r.value).reduce((a, b) => a + b) / selectedDevice!.readings.length).toStringAsFixed(1) : "0.0"}%',
                            Icons.show_chart,
                            Color(0xFF4ECDC4),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Estado del sensor',
                            selectedDevice!.status,
                            Icons.sensors,
                            _getStatusColor(selectedDevice!.status), // 🔥 USAR MÉTODO ESPECÍFICO
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Última lectura',
                            '${DateTime.now().difference(selectedDevice!.lastReading?.timestamp ?? DateTime.now()).inMinutes} min',
                            Icons.access_time,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget selector de dispositivo
  Widget _buildDeviceSelector() {
    if (devices.isEmpty) return Container();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFF2A3B4D)),
      ),
      child: DropdownButton<Device>(
        value: selectedDevice,
        onChanged: (Device? newValue) {
          if (newValue != null) {
            setState(() {
              selectedDevice = newValue;
              isEmergencyMode = selectedDevice!.lastReading?.isEmergency ?? false;

              // Reconectar WebSocket con el nuevo dispositivo
              _connectWebSocket();
            });
          }
        },
        items: devices.map<DropdownMenuItem<Device>>((Device device) {
          return DropdownMenuItem<Device>(
            value: device,
            child: Row(
              children: [
                Icon(
                  Icons.sensors,
                  color: device.isOnline ? Color(0xFF4ECDC4) : Colors.grey,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  '${device.name} (${device.location})',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        }).toList(),
        dropdownColor: Color(0xFF0F1B2A),
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        style: TextStyle(color: Colors.white),
        isExpanded: true,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF1A2B3D),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 AGREGAR ESTE MÉTODO
  Color _getStatusColor(String status) {
    switch (status) {
      case 'ALERT':
        return Colors.red;
      case 'WARNING':
        return Colors.orange;
      case 'NORMAL':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}