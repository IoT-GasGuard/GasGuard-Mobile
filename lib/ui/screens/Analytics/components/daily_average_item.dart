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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
          Text(
            '${average.average}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}