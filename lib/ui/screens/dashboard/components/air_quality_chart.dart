import 'package:flutter/material.dart';

import '../../../widgets/gasLevel_chart_painter .dart';

class AirQualityChart extends StatelessWidget {
  final List<double> gasLevelData;
  final double gasLevel;
  final bool isEmergencyMode;
  final VoidCallback toggleEmergencyMode;

  const AirQualityChart({
    Key? key,
    required this.gasLevelData,
    required this.gasLevel,
    required this.isEmergencyMode,
    required this.toggleEmergencyMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isEmergencyMode ? Colors.red : const Color(0xFF2A3B4D),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Concentración de gas en tiempo real',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getLevelColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${gasLevel.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: _getLevelColor(),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Gráfica
          Expanded(
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: GasLevelChartPainter(
                gasLevelData,
                isEmergency: isEmergencyMode,
              ),
            ),
          ),
          
          // Leyenda
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('0%', style: TextStyle(color: Colors.white54, fontSize: 12)),
                Text(
                  'Nivel de alerta: 70%', 
                  style: TextStyle(
                    color: isEmergencyMode ? Colors.red : Colors.white54, 
                    fontSize: 12
                  )
                ),
                const Text('100%', style: TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor() {
    if (gasLevel > 70) return Colors.red;
    if (gasLevel > 30) return Colors.orange;
    return const Color(0xFF4ECDC4);
  }
}