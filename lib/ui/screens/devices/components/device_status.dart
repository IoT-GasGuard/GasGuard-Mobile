import 'package:flutter/material.dart';

class DeviceStatus extends StatelessWidget {
  final double gasLevel;
  final bool isEmergencyMode;
  final VoidCallback onEmergencyToggle;

  const DeviceStatus({
    Key? key,
    required this.gasLevel,
    required this.isEmergencyMode,
    required this.onEmergencyToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Título
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estado del gas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Botón de emergencia
              ElevatedButton(
                onPressed: onEmergencyToggle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEmergencyMode ? Colors.red : const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text(
                  isEmergencyMode ? 'Cancelar emergencia' : 'Simular fuga',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Nivel de gas y estado
          Row(
            children: [
              _buildGasLevelIndicator(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusText(),
                      style: TextStyle(
                        color: _getStatusColor(),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusDescription(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGasLevelIndicator() {
    final Color statusColor = _getStatusColor();
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF0A1A2A),
        border: Border.all(
          color: statusColor.withOpacity(0.5),
          width: 3,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${gasLevel.toStringAsFixed(1)}%',
              style: TextStyle(
                color: statusColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Nivel',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    if (gasLevel > 70) return 'Peligro';
    if (gasLevel > 30) return 'Precaución';
    return 'Seguro';
  }

  String _getStatusDescription() {
    if (gasLevel > 70) {
      return 'Niveles de gas peligrosos detectados';
    }
    if (gasLevel > 30) {
      return 'Niveles de gas moderados, monitorear';
    }
    return 'Niveles de gas dentro de límites seguros';
  }

  Color _getStatusColor() {
    if (gasLevel > 70) return Colors.red;
    if (gasLevel > 30) return Colors.orange;
    return const Color(0xFF4ECDC4);
  }
}