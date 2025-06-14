import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/daily_average.dart';
import 'package:gasguard_mobile/ui/screens/Analytics/components/daily_average_item.dart';
import 'package:gasguard_mobile/ui/screens/Analytics/components/stat_card.dart';

class NormalOperationsTab extends StatelessWidget {
  final List<DailyAverage> dailyAverages;
  final double averageGasLevel;
  final double weeklyAverage;
  final double peakGasLevel;
  final Function(bool) onGenerateReport;

  const NormalOperationsTab({
    Key? key,
    required this.dailyAverages,
    required this.averageGasLevel,
    required this.weeklyAverage,
    required this.peakGasLevel,
    required this.onGenerateReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.trending_up,
                    title: 'Average Gas Level',
                    value: '$averageGasLevel%',
                    color: const Color(0xFF4ECDC4),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icon: Icons.calendar_today,
                    title: 'Week Average',
                    value: '$weeklyAverage%',
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icon: Icons.show_chart,
                    title: 'Peak Gas Level',
                    value: '$peakGasLevel%',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Daily Gas Averages',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...dailyAverages.map((average) => DailyAverageItem(average: average)),
            const SizedBox(height: 30),
            _buildGenerateReportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateReportButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: () => onGenerateReport(false),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ECDC4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(Icons.file_download),
        label: Text(
          'Generate Operations Report',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}