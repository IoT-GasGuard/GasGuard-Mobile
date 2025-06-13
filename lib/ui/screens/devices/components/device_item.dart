import 'package:flutter/material.dart';
import '../../../../models/device.dart';

class DeviceItem extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceItem({
    Key? key,
    required this.device,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF2A3B4D),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                // Icono del dispositivo según tipo
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.gas_meter,
                    color: const Color(0xFF4ECDC4),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),

                // Información principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ubicación: ${device.location}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Información de estado
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: device.isOnline ? Colors.green : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          device.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: device.isOnline ? Colors.green : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hace ${device.getTimeSinceLastSeen()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),

                    // Mostrar nivel si hay una lectura
                    if (device.lastReading != null)
                      Text(
                        '${device.lastReading!.value.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _getLevelColor(device.lastReading!.value),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),

                // Icono de flecha
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(double value) {
    if (value > 70) return Colors.red;
    if (value > 30) return Colors.orange;
    return const Color(0xFF4ECDC4);
  }
}