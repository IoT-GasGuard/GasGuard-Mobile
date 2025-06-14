import 'package:flutter/material.dart';

class ZoneControlItem extends StatelessWidget {
  final String zoneName;
  final double intensity;
  final ValueChanged<double> onIntensityChanged;

  const ZoneControlItem({
    Key? key,
    required this.zoneName,
    required this.intensity,
    required this.onIntensityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                zoneName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                '${intensity.toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF4ECDC4),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Intensity',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: intensity / 100,
                    backgroundColor: const Color(0xFF2A3B4D),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFF4ECDC4),
              inactiveTrackColor: const Color(0xFF2A3B4D),
              thumbColor: const Color(0xFF4ECDC4),
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
            ),
            child: Slider(
              value: intensity,
              min: 0,
              max: 100,
              onChanged: onIntensityChanged,
            ),
          ),
        ],
      ),
    );
  }
}