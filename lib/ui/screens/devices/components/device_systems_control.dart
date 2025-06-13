import 'package:flutter/material.dart';
import '../../../../models/system_status.dart';

class DeviceSystemsControl extends StatelessWidget {
  final SystemStatus systemStatus;
  final Function(String, bool) onSystemToggle;
  final bool isDisabled;

  const DeviceSystemsControl({
    Key? key,
    required this.systemStatus,
    required this.onSystemToggle,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF2A3B4D),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Control de sistemas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Controles de sistemas
          _buildSystemControl(
            'Válvula de gas',
            'Controla el suministro de gas',
            Icons.settings_input_component,
            systemStatus.gasValveActive,
            (value) => onSystemToggle('gasValve', value),
          ),
          
          _buildSystemControl(
            'Sistema de ventilación',
            'Extracción de aire',
            Icons.air,
            systemStatus.ventilationActive,
            (value) => onSystemToggle('ventilation', value),
          ),
          
          _buildSystemControl(
            'Sistema de puertas',
            'Apertura de emergencia',
            Icons.door_front_door,
            systemStatus.doorSystemActive,
            (value) => onSystemToggle('doorSystem', value),
          ),
          
          _buildSystemControl(
            'Sistema de iluminación',
            'Iluminación de emergencia',
            Icons.lightbulb,
            systemStatus.lightingSystemActive,
            (value) => onSystemToggle('lighting', value),
            isLastItem: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSystemControl(
    String title,
    String subtitle,
    IconData icon,
    bool isActive,
    Function(bool) onToggle, {
    bool isLastItem = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF4ECDC4).withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isActive ? const Color(0xFF4ECDC4) : Colors.grey,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: isDisabled ? null : onToggle,
              activeColor: const Color(0xFF4ECDC4),
              activeTrackColor: const Color(0xFF4ECDC4).withOpacity(0.3),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
            ),
          ],
        ),
        if (!isLastItem)
          const Divider(
            color: Color(0xFF2A3B4D),
            height: 24,
          ),
      ],
    );
  }
}