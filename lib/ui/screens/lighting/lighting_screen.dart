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
  double _masterIntensity = 65.0;
  
  final List<LightingZone> _zones = [
    LightingZone(name: 'Living Room', intensity: 45.0),
    LightingZone(name: 'Kitchen', intensity: 28.0),
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
              showBackButton: true,
              onBackPressed: () => Navigator.pop(context),
              onMenuPressed: () => TopMenu.showMenu(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MasterControlCard(
                      isAutomaticMode: _isAutomaticMode,
                      onAutomaticModeChanged: _handleAutomaticModeChanged,
                      masterIntensity: _masterIntensity,
                      onMasterIntensityChanged: _handleMasterIntensityChanged,
                    ),
                    const SizedBox(height: 24),
                    _buildZoneControl(),
                  ],
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
            onIntensityChanged: (value) => _handleZoneIntensityChanged(index, value),
          ),
        ),
      ],
    );
  }

  void _handleAutomaticModeChanged(bool value) {
    setState(() {
      _isAutomaticMode = value;
    });
  }

  void _handleMasterIntensityChanged(double value) {
    setState(() {
      _masterIntensity = value;
      // Opcional: Ajustar todas las zonas proporcionalmente
      if (!_isAutomaticMode) {
        for (var zone in _zones) {
          zone.intensity = value;
        }
      }
    });
  }

  void _handleZoneIntensityChanged(int zoneIndex, double value) {
    setState(() {
      _zones[zoneIndex].intensity = value;
      // Opcional: Recalcular el valor maestro basado en promedios
      if (!_isAutomaticMode) {
        _masterIntensity = _zones.map((z) => z.intensity).reduce((a, b) => a + b) / _zones.length;
      }
    });
  }
}