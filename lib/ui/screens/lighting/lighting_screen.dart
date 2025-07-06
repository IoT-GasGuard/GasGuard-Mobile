import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/device.dart';
import 'package:gasguard_mobile/service/device_service.dart';
import 'package:gasguard_mobile/service/stomp_web_socket_service.dart';
import 'package:gasguard_mobile/shared/helpers/storage_helper.dart';
import 'package:gasguard_mobile/ui/common/app_header.dart';
import 'package:gasguard_mobile/ui/screens/lighting/components/master_control_card.dart';
import 'package:gasguard_mobile/ui/screens/lighting/components/zone_control_item.dart';
import 'package:gasguard_mobile/utils/top_menu.dart';

class LightingZone {
  final String name;
  final String deviceId;
  double intensity;

  LightingZone({
    required this.name,
    required this.deviceId,
    this.intensity = 50.0,
  });
}

class LightingScreen extends StatefulWidget {
  const LightingScreen({Key? key}) : super(key: key);

  @override
  State<LightingScreen> createState() => _LightingScreenState();
}

class _LightingScreenState extends State<LightingScreen> {
  bool _isAutomaticMode = false;
  double _masterIntensity = 25.0;
  bool _isLoading = true;
  String? _error;

  List<LightingZone> _zones = [];
  List<Device> _devices = [];

  // 🔥 USAR EL MISMO STOMP SERVICE
  final StompWebSocketService _stompService = StompWebSocketService();

  @override
  void initState() {
    super.initState();
    _loadDevicesAndSetupZones();
  }

  @override
  void dispose() {
    _stompService.disconnect();
    super.dispose();
  }

  Future<void> _loadDevicesAndSetupZones() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await StorageHelper.getUser();
      if (user == null || user.profileId.isEmpty) {
        setState(() {
          _error = 'No se pudo obtener información del usuario';
          _isLoading = false;
        });
        return;
      }

      final response = await DeviceService.getDevicesByProfile(user.profileId);

      if (response.statusCode == 200) {
        final List<dynamic> devicesJson = response.data;
        final List<Device> devices = devicesJson
            .map((json) => Device.fromJson(json))
            .toList();

        if (devices.isEmpty) {
          setState(() {
            _error = 'No hay dispositivos disponibles';
            _isLoading = false;
          });
          return;
        }

        // Crear zonas basadas en los dispositivos reales
        final List<LightingZone> zones = devices.map((device) {
          return LightingZone(
            name: device.location.isNotEmpty ? device.location : device.name,
            deviceId: device.deviceId,
            intensity: 25.0,
          );
        }).toList();

        setState(() {
          _devices = devices;
          _zones = zones;
          _isLoading = false;
        });

        // 🔥 CONECTAR STOMP PARA EL PRIMER DISPOSITIVO
        if (_zones.isNotEmpty) {
          await _stompService.connect(_zones.first.deviceId);
        }
      } else {
        setState(() {
          _error = 'Error al cargar dispositivos: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
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
              title: "Lighting Control",
              onBackPressed: () => Navigator.pop(context),
              onMenuPressed: () => TopMenu.showMenu(context),
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
                child: _isLoading
                    ? _buildLoadingState()
                    : _error != null
                        ? _buildErrorState()
                        : _buildContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4ECDC4)),
          SizedBox(height: 16),
          Text(
            'Cargando dispositivos...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            _error ?? 'Error desconocido',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadDevicesAndSetupZones,
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_zones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lightbulb_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay dispositivos de iluminación disponibles',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status del WebSocket
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _stompService.isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _stompService.isConnected ? Colors.green : Colors.red,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _stompService.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _stompService.isConnected ? Colors.green : Colors.red,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  _stompService.isConnected ? 'Conectado' : 'Desconectado',
                  style: TextStyle(
                    color: _stompService.isConnected ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Master Control Card
          MasterControlCard(
            isAutomaticMode: _isAutomaticMode,
            onAutomaticModeChanged: _handleAutomaticModeChanged,
            masterIntensity: _masterIntensity,
            onMasterIntensityChanged: _handleMasterIntensityChanged,
            onMasterIntensityChangeEnd: _handleMasterIntensityChangeEnd, // AGREGAR ESTA LÍNEA
          ),
          const SizedBox(height: 24),

          // Zone Control
          _buildZoneControl(),
        ],
      ),
    );
  }

  Widget _buildZoneControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Control (${_zones.length})',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          _zones.length,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 8),
            child: ZoneControlItem(
              zoneName: '${_zones[index].name} (${_zones[index].deviceId})',
              intensity: _zones[index].intensity,
              onIntensityChanged: _isAutomaticMode
                  ? null
                  : (value) => _handleZoneIntensityChanged(index, value),
              onIntensityChangeEnd: _isAutomaticMode 
                  ? null
                  : (value) => _handleZoneIntensityChangeEnd(index, value),
            ),
          ),
        ),
      ],
    );
  }

  void _handleAutomaticModeChanged(bool value) {
    setState(() {
      _isAutomaticMode = value;
    });

    // 🔥 ENVIAR COMANDO AUTOMÁTICO A TODOS LOS DISPOSITIVOS
    for (final zone in _zones) {
      _sendLightingCommand(zone.deviceId, zone.intensity.round(), value);
    }

    if (value) {
      _simulateAutomaticAdjustment();
    }
  }

  void _handleMasterIntensityChanged(double value) {
    if (!_isAutomaticMode) {
      setState(() {
        _masterIntensity = value;
        // Ajustar todas las zonas proporcionalmente
        for (var zone in _zones) {
          zone.intensity = value;
        }
      });

      // Solo enviamos el comando al soltar el slider o terminar el gesto
      // No enviamos mientras se arrastra
    }
  }

  // Agregar este método para enviar cuando el usuario termina de mover el slider
  void _handleMasterIntensityChangeEnd(double value) {
    if (!_isAutomaticMode) {
      // Enviar comando a todos los dispositivos cuando el usuario termina de mover el slider
      for (final zone in _zones) {
        _sendLightingCommand(zone.deviceId, value.round(), false);
      }
    }
  }

  void _handleZoneIntensityChanged(int zoneIndex, double value) {
    if (!_isAutomaticMode) {
      setState(() {
        _zones[zoneIndex].intensity = value;
        // Recalcular el valor maestro basado en promedios
        _masterIntensity = _zones.map((z) => z.intensity).reduce((a, b) => a + b) / _zones.length;
      });

      // REMOVER ESTA LÍNEA - No enviar comando aquí
      // _sendLightingCommand(_zones[zoneIndex].deviceId, value.round(), false);
    }
  }

  // Lo mismo para los controles de zona individual
  void _handleZoneIntensityChangeEnd(int zoneIndex, double value) {
    if (!_isAutomaticMode) {
      // Enviar comando al dispositivo específico cuando termina el movimiento
      _sendLightingCommand(_zones[zoneIndex].deviceId, value.round(), false);
    }
  }

  // 🔥 MÉTODO CLAVE: Enviar comando por STOMP
  Future<void> _sendLightingCommand(String deviceId, int intensityPercent, bool auto) async {
    try {
      // Convertir porcentaje (0-100) a valor PWM (0-255)
      final int value = ((intensityPercent / 100.0) * 255).round();
      
      print('💡 Enviando comando: Device=$deviceId, Percent=$intensityPercent%, Value=$value, Auto=$auto');
      
      final success = await _stompService.sendLightingCommand(
        deviceId: deviceId,
        value: value,
        auto: auto,
      );

      if (success) {
        print('✅ Comando enviado exitosamente a $deviceId');
        
        // Mostrar feedback al usuario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Comando enviado a $deviceId'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        print('❌ Error enviando comando a $deviceId');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error controlando $deviceId'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error completo enviando comando a $deviceId: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de conexión con $deviceId'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _simulateAutomaticAdjustment() {
    // Simular ajuste automático basado en hora del día
    final hour = DateTime.now().hour;
    double targetIntensity;

    if (hour >= 6 && hour < 12) {
      targetIntensity = 30.0; // Mañana - luz suave
    } else if (hour >= 12 && hour < 18) {
      targetIntensity = 15.0; // Tarde - menos intensidad
    } else if (hour >= 18 && hour < 22) {
      targetIntensity = 60.0; // Noche - más intensidad
    } else {
      targetIntensity = 10.0; // Madrugada - muy baja
    }

    setState(() {
      _masterIntensity = targetIntensity;
      for (var zone in _zones) {
        // Ajustar cada zona con pequeñas variaciones
        zone.intensity = targetIntensity + (zone.name.hashCode % 20 - 10);
        if (zone.intensity < 0) zone.intensity = 0;
        if (zone.intensity > 100) zone.intensity = 100;
      }
    });

    // 🔥 ENVIAR COMANDOS AUTOMÁTICOS
    for (final zone in _zones) {
      _sendLightingCommand(zone.deviceId, zone.intensity.round(), true);
    }
  }
}