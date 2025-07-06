import 'package:flutter/material.dart';

class MasterControlCard extends StatelessWidget {
  final bool isAutomaticMode;
  final Function(bool) onAutomaticModeChanged;
  final double masterIntensity;
  final Function(double) onMasterIntensityChanged;
  final Function(double)? onMasterIntensityChangeEnd; // AGREGAR ESTE PARÁMETRO

  const MasterControlCard({
    Key? key,
    required this.isAutomaticMode,
    required this.onAutomaticModeChanged,
    required this.masterIntensity,
    required this.onMasterIntensityChanged,
    this.onMasterIntensityChangeEnd, // AGREGAR ESTE PARÁMETRO
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF4ECDC4);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Master Lighting Control',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildAutomaticModeSwitch(),
          const SizedBox(height: 25),
          
          // Master intensity section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Master intensity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color, width: 1),
                ),
                child: Text(
                  '${masterIntensity.round()}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Slider with percentage labels
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: const Color(0xFF2A3B4D),
              thumbColor: Colors.white,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: masterIntensity,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: isAutomaticMode ? null : onMasterIntensityChanged,
              onChangeEnd: isAutomaticMode ? null : onMasterIntensityChangeEnd, // AGREGAR ESTA LÍNEA
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0%', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                Text('50%', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                Text('100%', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutomaticModeSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Automatic Mode',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Adjust lighting based on\nambient conditions',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
        Switch(
          value: isAutomaticMode,
          onChanged: onAutomaticModeChanged,
          activeColor: const Color(0xFF4ECDC4),
          inactiveTrackColor: Colors.grey.shade800,
          inactiveThumbColor: Colors.grey.shade400,
        ),
      ],
    );
  }
}