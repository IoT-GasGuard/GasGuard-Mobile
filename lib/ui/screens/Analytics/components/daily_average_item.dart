import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/daily_average.dart';
import 'package:intl/intl.dart';

class DailyAverageItem extends StatelessWidget {
  final DailyAverage average;

  const DailyAverageItem({
    Key? key,
    required this.average,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd-MM-yyyy');
    final formattedDate = dateFormatter.format(average.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2A3B4D),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              formattedDate,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: average.average / 100,
                backgroundColor: const Color(0xFF1A2B3D),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF4ECDC4),
                width: 1,
              ),
            ),
            child: Text(
              '${average.average}%',
              style: const TextStyle(
                color: Color(0xFF4ECDC4),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}