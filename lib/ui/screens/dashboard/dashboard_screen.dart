import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/device.dart';
import 'package:gasguard_mobile/models/gas_reading.dart';
import 'package:gasguard_mobile/models/system_status.dart';
import 'package:gasguard_mobile/ui/common/app_header.dart';
import 'package:gasguard_mobile/utils/app_router.dart';
import 'package:gasguard_mobile/utils/top_menu.dart';
import 'components/air_quality_chart.dart';
import 'components/air_quality_status.dart';
import 'components/systems_control.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Device selectedDevice;
  late List<Device> devices;

  Timer? _monitoringTimer;
  bool isEmergencyMode = false;

  @override
  void initState() {
    super.initState();
    _initializeDevices();
    _startGasMonitoring();
  }

  // Inicializar dispositivos con datos simulados
  void _initializeDevices() {
    final now = DateTime.now();
    devices = [
      Device(
        id: 'DEV0001',
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
        id: 'DEV0002',
        name: 'Sensor Sala',
        isOnline: true,
        lastSeen: now,
        location: 'Sala',
        lastReading: GasReading(
          value: 12.0,
          timestamp: now,
        ),
        systemStatus: SystemStatus(),
        readings: _generateSampleReadings(now, 20, false),
      ),
    ];

    selectedDevice = devices.first;
  }

  // Generar lecturas simuladas
  List<GasReading> _generateSampleReadings(DateTime endTime, int count, bool includeEmergency) {
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
  
  // Método para monitoreo continuo
  void _startGasMonitoring() {
    // Cancelar timer existente si hay uno
    _monitoringTimer?.cancel();
    
    // Crear nuevo timer para actualizar cada 3 segundos
    _monitoringTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      
      setState(() {
        // Generar nueva lectura
        final now = DateTime.now();
        double newValue;
        
        if (isEmergencyMode) {
          // En emergencia, mantener niveles altos
          newValue = 70.0 + math.Random().nextDouble() * 25.0;
          
          // Pequeña probabilidad de mejoría
          if (math.Random().nextInt(100) < 10) {
            newValue = 65.0 - math.Random().nextDouble() * 15.0;
          }
        } else {
          // Lecturas normales con variaciones
          newValue = 10.0 + math.Random().nextDouble() * 15.0;
          
          // Pequeña probabilidad de lectura anómala
          if (math.Random().nextInt(100) < 5) {
            newValue = 25.0 + math.Random().nextDouble() * 20.0;
          }
        }
        
        // Crear nueva lectura
        final newReading = GasReading(
          value: newValue,
          timestamp: now,
          isEmergency: newValue > 70,
        );
        
        // Añadir a dispositivo seleccionado
        selectedDevice.addReading(newReading);
        
        // Si es emergencia pero no estamos en modo emergencia, activarlo
        if (newReading.isEmergency && !isEmergencyMode && math.Random().nextInt(100) < 5) {
          isEmergencyMode = true;
          _showEmergencyAlert();
        }
      });
    });
  }
  
  // Método para cambiar entre modo normal y emergencia
  void _toggleEmergencyMode() {
    _monitoringTimer?.cancel();

    setState(() {
      isEmergencyMode = !isEmergencyMode;
      final now = DateTime.now();

      if (isEmergencyMode) {
        selectedDevice.systemStatus.activateEmergencyProtocol();
        
        final emergencyLevel = 75.0 + math.Random().nextDouble() * 20.0;
        final newReading = GasReading(
          value: emergencyLevel,
          timestamp: now,
          isEmergency: true,
        );
        selectedDevice.addReading(newReading);
        
        _showEmergencyAlert();
      } else {
        selectedDevice.systemStatus.restoreNormalOperation();
        
        final newReading = GasReading(
          value: 15.0 + math.Random().nextDouble() * 10.0,
          timestamp: now,
          isEmergency: false,
        );
        selectedDevice.addReading(newReading);
      }
    });

    _startGasMonitoring();
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    super.dispose();
  }
  
  // Mostrar alerta de emergencia
  void _showEmergencyAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2B3D),
        title: Wrap( // Cambiado de Row a Wrap
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
              'Se ha detectado una fuga de gas en ${selectedDevice.location}.',
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
              onMenuPressed: () => _showTopMenu(context),
            ),
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
                      _buildDeviceSelector(),
                      const SizedBox(height: 20),
                      
                      Container(
                        height: 90,
                        child: AirQualityStatus(
                          gasLevel: selectedDevice.lastReading?.value ?? 0,
                          isEmergencyMode: isEmergencyMode,
                          onEmergencyToggle: _toggleEmergencyMode,
                        ),
                      ),
                      const SizedBox(height: 15),
                      
                      Expanded(
                        flex: 2,
                        child: AirQualityChart(
                          gasLevelData: selectedDevice.readings.map((r) => r.value).toList(),
                          gasLevel: selectedDevice.lastReading?.value ?? 0,
                          isEmergencyMode: isEmergencyMode,
                          toggleEmergencyMode: _toggleEmergencyMode,
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Control de sistemas
                      Expanded(
                        flex: 3,
                        child: SystemsControl(
                          gasValveActive: selectedDevice.systemStatus.gasValveActive,
                          ventilationActive: selectedDevice.systemStatus.ventilationActive,
                          doorSystemActive: selectedDevice.systemStatus.doorSystemActive,
                          lightingSystemActive: selectedDevice.systemStatus.lightingSystemActive,
                          isEmergencyMode: isEmergencyMode,
                          onGasValveToggle: (value) {
                            setState(() {
                              selectedDevice.systemStatus.gasValveActive = value;
                            });
                          },
                          onVentilationToggle: (value) {
                            setState(() {
                              selectedDevice.systemStatus.ventilationActive = value;
                            });
                          },
                          onDoorSystemToggle: (value) {
                            setState(() {
                              selectedDevice.systemStatus.doorSystemActive = value;
                            });
                          },
                          onLightingToggle: (value) {
                            setState(() {
                              selectedDevice.systemStatus.lightingSystemActive = value;
                            });
                          },
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
  
  // Widget selector de dispositivo
  Widget _buildDeviceSelector() {
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
              isEmergencyMode = selectedDevice.lastReading?.isEmergency ?? false;
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