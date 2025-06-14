import 'package:flutter/material.dart';

class SliderWithLabels extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String minLabel;
  final String maxLabel;
  final Color activeColor;
  final Color inactiveColor;

  const SliderWithLabels({
    Key? key,
    required this.value,
    required this.onChanged,
    this.minLabel = '0',
    this.maxLabel = '100',
    this.activeColor = const Color(0xFF4ECDC4),
    this.inactiveColor = const Color(0xFF2A3B4D),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: activeColor,
            inactiveTrackColor: inactiveColor,
            thumbColor: activeColor,
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16.0),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minLabel,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
              Text(
                maxLabel,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}