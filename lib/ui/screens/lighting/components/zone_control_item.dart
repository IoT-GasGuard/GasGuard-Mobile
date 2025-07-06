import 'package:flutter/material.dart';

class ZoneControlItem extends StatelessWidget {
  final String zoneName;
  final double intensity;
  final ValueChanged<double>? onIntensityChanged;
  final ValueChanged<double>? onIntensityChangeEnd;

  const ZoneControlItem({
    Key? key,
    required this.zoneName,
    required this.intensity,
    this.onIntensityChanged,
    this.onIntensityChangeEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = const Color(0xFF4ECDC4);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(12),
      ),
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${intensity.round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Intensity',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: const Color(0xFF2A3B4D),
              thumbColor: color,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
            ),
            child: Slider(
              value: intensity,
              min: 0,
              max: 100,
              onChanged: onIntensityChanged,
              onChangeEnd: onIntensityChangeEnd,
            ),
          ),
        ],
      ),
    );
  }
}