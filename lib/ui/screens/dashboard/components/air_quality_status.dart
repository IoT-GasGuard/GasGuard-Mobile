import 'package:flutter/material.dart';

class AirQualityStatus extends StatelessWidget {
  final double gasLevel;
  final bool isEmergencyMode;
  final VoidCallback onEmergencyToggle;

  const AirQualityStatus({
    Key? key,
    required this.gasLevel,
    required this.isEmergencyMode,
    required this.onEmergencyToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isGood = !isEmergencyMode && gasLevel < 30; // Umbral invertido
    final statusText = isEmergencyMode ? 'Emergencia detectada' : 
                    isGood ? 'Nivel seguro' : 'Nivel elevado';
                    
    final statusIcon = isEmergencyMode ? Icons.warning_amber_rounded : 
                    isGood ? Icons.check_circle : Icons.info;
                    
    final statusColor = isEmergencyMode ? Colors.red : 
                    isGood ? const Color(0xFF4ECDC4) : Colors.orange;
  
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isEmergencyMode ? Colors.red : const Color(0xFF2A3B4D),
          width: 1,
        ),
      ),
      child: Row(
        children: [

          Expanded(
            flex: 6,
            child: Row(
              children: [
                // Valor del gas con FittedBox
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${gasLevel.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'de Gas',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12, // Reducido más
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusColor, size: 12),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              statusText,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11, // Reducido más
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Botón de emergencia - lado derecho
          Expanded(
            flex: 4,
            child: ElevatedButton(
              onPressed: onEmergencyToggle,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEmergencyMode ? Colors.red : const Color(0xFF4ECDC4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size.zero,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isEmergencyMode ? 'Cancelar' : 'Simular',
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}