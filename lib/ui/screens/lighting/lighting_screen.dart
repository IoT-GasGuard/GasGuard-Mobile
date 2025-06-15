import 'package:flutter/material.dart';
import 'package:gasguard_mobile/ui/common/app_header.dart';
import 'package:gasguard_mobile/ui/screens/lighting/components/master_control_card.dart';
import 'package:gasguard_mobile/ui/screens/lighting/components/zone_control_item.dart';
import 'package:gasguard_mobile/utils/top_menu.dart';

class LightingZone {
  final String name;
  double intensity;

  LightingZone({
    required this.name,
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

  final List<LightingZone> _zones = [
    LightingZone(name: 'Living Room', intensity: 45.0),
    LightingZone(name: 'Kitchen', intensity: 25.0),
    LightingZone(name: 'Bedroom', intensity: 75.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppHeader(
              title: "Lighting",
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Master Control Card
                      MasterControlCard(
                        isAutomaticMode: _isAutomaticMode,
                        onAutomaticModeChanged: _handleAutomaticModeChanged,
                        masterIntensity: _masterIntensity,
                        onMasterIntensityChanged: _handleMasterIntensityChanged,
                      ),
                      const SizedBox(height: 24),

                      // Zone Control
                      _buildZoneControl(),
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

  Widget _buildZoneControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zone Control',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          _zones.length,
              (index) => ZoneControlItem(
            zoneName: _zones[index].name,
            intensity: _zones[index].intensity,
            onIntensityChanged: _isAutomaticMode
                ? null // Deshabilitar en modo automático
                : (value) => _handleZoneIntensityChanged(index, value),
          ),
        ),
      ],
    );
  }

  void _handleAutomaticModeChanged(bool value) {
    setState(() {
      _isAutomaticMode = value;
      if (value) {
        // En modo automático, simular ajuste basado en condiciones ambientales
        _simulateAutomaticAdjustment();
      }
    });
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
    }
  }

  void _handleZoneIntensityChanged(int zoneIndex, double value) {
    if (!_isAutomaticMode) {
      setState(() {
        _zones[zoneIndex].intensity = value;
        // Recalcular el valor maestro basado en promedios
        _masterIntensity = _zones.map((z) => z.intensity).reduce((a, b) => a + b) / _zones.length;
      });
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
  }
}