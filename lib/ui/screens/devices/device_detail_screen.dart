import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/device.dart';
import 'package:gasguard_mobile/models/gas_reading.dart';
import 'package:gasguard_mobile/models/system_status.dart';
import 'package:gasguard_mobile/ui/common/app_header.dart';
import 'dart:math' as math;

import 'components/device_chart.dart';
import 'components/device_status.dart';
import 'components/device_systems_control.dart';

class DeviceDetailScreen extends StatefulWidget {
  final Device? device;

  const DeviceDetailScreen({
    Key? key,
    this.device,
  }) : super(key: key);

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late Device device;
  late bool isNewDevice;
  late TextEditingController nameController;
  late TextEditingController locationController;

  @override
  void initState() {
    super.initState();
    isNewDevice = widget.device == null;
    
    if (isNewDevice) {
      // Crear un nuevo dispositivo con datos por defecto
      final now = DateTime.now();
      final deviceId = 'GSD${now.millisecondsSinceEpoch.toString().substring(6)}';
      
      device = Device(
        id: deviceId,
        name: 'Nuevo Sensor',
        isOnline: true,
        lastSeen: now,
        location: 'Sin ubicación',
        lastReading: GasReading(
          value: 10.0,
          timestamp: now,
        ),
        systemStatus: SystemStatus(),
        readings: _generateInitialReadings(now),
      );
    } else {
      device = widget.device!;
    }
    
    nameController = TextEditingController(text: device.name);
    locationController = TextEditingController(text: device.location);
  }
  
  List<GasReading> _generateInitialReadings(DateTime now) {
    List<GasReading> readings = [];
    final random = math.Random();
    
    for (int i = 0; i < 20; i++) {
      final timestamp = now.subtract(Duration(minutes: (20 - i) * 10));
      final value = 10.0 + random.nextDouble() * 15.0;
      
      readings.add(GasReading(
        value: value,
        timestamp: timestamp,
      ));
    }
    
    return readings;
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2A),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            AppHeader(
              title: isNewDevice ? 'Nuevo Dispositivo' : device.name,
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              onMenuPressed: () {},
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
                child: ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    // Información del dispositivo
                    _buildDeviceInfoSection(),
                    const SizedBox(height: 24),
                    
                    // Si no es un dispositivo nuevo, mostrar datos detallados
                    if (!isNewDevice) ...[
                      // Estado actual del dispositivo
                      DeviceStatus(
                        gasLevel: device.lastReading?.value ?? 0,
                        isEmergencyMode: device.lastReading?.isEmergency ?? false,
                        onEmergencyToggle: _toggleEmergencyMode,
                      ),
                      const SizedBox(height: 24),
                      
                      // Gráfica de lecturas históricas
                      DeviceChart(
                        readings: device.readings,
                        isEmergencyMode: device.lastReading?.isEmergency ?? false,
                      ),
                      const SizedBox(height: 24),
                      
                      // Control de sistemas
                      DeviceSystemsControl(
                        systemStatus: device.systemStatus,
                        onSystemToggle: _handleSystemToggle,
                      ),
                    ],
                    
                    const SizedBox(height: 30),
                    
                    // Botón guardar/actualizar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveDevice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ECDC4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          isNewDevice ? 'Añadir dispositivo' : 'Guardar cambios',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    // Si no es un dispositivo nuevo, añadir botón eliminar
                    if (!isNewDevice) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _confirmDeleteDevice,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Eliminar dispositivo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF2A3B4D),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Id del dispositivo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.qr_code, color: Color(0xFF4ECDC4), size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'ID del dispositivo:',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Text(
                device.id,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Campo de nombre
          const Text(
            'Nombre del dispositivo',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF162635),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) {
            },
          ),
          
          const SizedBox(height: 16),
          
          // Campo de ubicación
          const Text(
            'Ubicación',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: locationController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF162635),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) {
            },
          ),
          
          // Si no es nuevo, mostrar estado de conexión
          if (!isNewDevice) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Estado de conexión
                Row(
                  children: [
                    Icon(
                      device.isOnline ? Icons.wifi : Icons.wifi_off,
                      color: device.isOnline ? Colors.green : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      device.isOnline ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: device.isOnline ? Colors.green : Colors.grey,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                // Última vez visto
                Text(
                  'Hace ${device.getTimeSinceLastSeen()}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _toggleEmergencyMode() {
    setState(() {
      // Simulación de emergencia
      final now = DateTime.now();
      
      if (device.lastReading?.isEmergency ?? false) {
        // Cancelar emergencia
        final newReading = GasReading(
          value: 15.0 + math.Random().nextDouble() * 10.0,
          timestamp: now,
          isEmergency: false,
        );
        
        device.addReading(newReading);
        device.systemStatus.restoreNormalOperation();
      } else {
        // Activar emergencia
        final emergencyLevel = 75.0 + math.Random().nextDouble() * 20.0;
        final newReading = GasReading(
          value: emergencyLevel,
          timestamp: now,
          isEmergency: true,
        );
        
        device.addReading(newReading);
      }
    });
  }

  void _handleSystemToggle(String systemName, bool value) {
    setState(() {
      switch (systemName) {
        case 'gasValve':
          device.systemStatus.gasValveActive = value;
          break;
        case 'ventilation':
          device.systemStatus.ventilationActive = value;
          break;
        case 'doorSystem':
          device.systemStatus.doorSystemActive = value;
          break;
        case 'lighting':
          device.systemStatus.lightingSystemActive = value;
          break;
      }
    });
  }

  void _saveDevice() {
    // Aquí actualizar dispositivo con los nuevos valores
    device.name = nameController.text;
    device.location = locationController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isNewDevice ? 
          'Dispositivo añadido correctamente' : 
          'Dispositivo actualizado correctamente'),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Volver a la pantalla anterior
    Navigator.pop(context, device);
  }

  void _confirmDeleteDevice() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2B3D),
        title: const Text(
          'Eliminar dispositivo',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este dispositivo? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar', 
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Dispositivo eliminado correctamente'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              
              Navigator.pop(context, 'deleted');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}