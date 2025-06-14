import 'package:flutter/material.dart';
import 'package:gasguard_mobile/ui/screens/lighting/components/slider_with_labels.dart';

class MasterControlCard extends StatelessWidget {
  final bool isAutomaticMode;
  final ValueChanged<bool> onAutomaticModeChanged;
  final double masterIntensity;
  final ValueChanged<double> onMasterIntensityChanged;

  const MasterControlCard({
    Key? key,
    required this.isAutomaticMode,
    required this.onAutomaticModeChanged,
    required this.masterIntensity,
    required this.onMasterIntensityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A3B4D),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Master Lighting Control',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildAutomaticModeSwitch(),
          const SizedBox(height: 16),
          _buildMasterIntensitySlider(),
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
          inactiveTrackColor: Colors.grey.shade700,
          inactiveThumbColor: Colors.grey.shade400,
        ),
      ],
    );
  }

  Widget _buildMasterIntensitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Master Intensity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              '${masterIntensity.toInt()}%',
              style: const TextStyle(
                color: Color(0xFF4ECDC4),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderWithLabels(
          value: masterIntensity,
          onChanged: onMasterIntensityChanged,
          minLabel: '0%',
          maxLabel: '100%',
        ),
      ],
    );
  }
}