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
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.trending_up,
                    title: 'Average\nGas Level',
                    value: '$averageGasLevel%',
                    color: const Color(0xFF4ECDC4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.calendar_today,
                    title: 'Week\nAverage',
                    value: '$weeklyAverage%',
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.show_chart,
                    title: 'Peak Gas\nLevel',
                    value: '$peakGasLevel%',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            _buildDailyAveragesSection(),
            const SizedBox(height: 25),
            _buildGenerateReportButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyAveragesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1B2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2A3B4D),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.insights,
                color: Color(0xFF4ECDC4),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Daily Gas Averages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...dailyAverages.map((average) => DailyAverageItem(average: average)),
        ],
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
          elevation: 4,
          shadowColor: const Color(0xFF4ECDC4).withOpacity(0.5),
        ),
        icon: const Icon(Icons.file_download),
        label: const Text(
          'Generate Operations Report',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}