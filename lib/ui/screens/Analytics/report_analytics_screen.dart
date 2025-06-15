import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/daily_average.dart';
import 'package:gasguard_mobile/models/gas_incident.dart';
import 'package:gasguard_mobile/ui/screens/Analytics/components/gas_incidents_tab.dart';
import 'package:gasguard_mobile/ui/screens/Analytics/components/normal_operations_tab.dart';
import 'package:gasguard_mobile/utils/top_menu.dart';
import '../../common/app_header.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  bool _showGasIncidents = true;

  // Datos de ejemplo para incidentes de gas
  final List<GasIncident> _incidents = [
    GasIncident(
      id: '1',
      deviceName: 'Kitchen Sensor',
      location: 'Kitchen',
      gasLevel: 85.0,
      detectedAt: DateTime(2023, 6, 5, 18, 30),
      duration: const Duration(minutes: 5),
      isResolved: true,
      actionsPerformed: [
        'Windows open',
        'Power supply shut off',
        'Alert sent to emergency contacts'
      ],
    ),
  ];

  // Datos de ejemplo para promedios diarios
  final List<DailyAverage> _dailyAverages = [
    DailyAverage(date: DateTime(2023, 6, 6), average: 4.1),
    DailyAverage(date: DateTime(2023, 6, 5), average: 4.1),
    DailyAverage(date: DateTime(2023, 6, 4), average: 4.1),
  ];

  // Estadísticas de operación normal
  final double _averageGasLevel = 4.2;
  final double _weeklyAverage = 3.9;
  final double _peakGasLevel = 50.2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1A2A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabSelector(),
            Expanded(
              child: _showGasIncidents
                  ? GasIncidentsTab(
                      incidents: _incidents,
                      onGenerateReport: _showReportGeneratedDialog,
                    )
                  : NormalOperationsTab(
                      dailyAverages: _dailyAverages,
                      averageGasLevel: _averageGasLevel,
                      weeklyAverage: _weeklyAverage,
                      peakGasLevel: _peakGasLevel,
                      onGenerateReport: _showReportGeneratedDialog,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
  return AppHeader(
    title: "", 
    onBackPressed: () => Navigator.pop(context),
    onMenuPressed: () => TopMenu.showMenu(context),
  );
}

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report & Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  title: 'Gas Incidents',
                  isSelected: _showGasIncidents,
                  onTap: () {
                    setState(() {
                      _showGasIncidents = true;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTabButton(
                  title: 'Normal Operations',
                  isSelected: !_showGasIncidents,
                  onTap: () {
                    setState(() {
                      _showGasIncidents = false;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4ECDC4) : const Color(0xFF1A2B3D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showTopMenu() {
    TopMenu.showMenu(context);
  }
  
  void _showReportGeneratedDialog(bool isIncidentReport) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2B3D),
        title: const Text(
          'Report Generated',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          isIncidentReport 
              ? 'Your gas leak incident report has been generated successfully and is ready to download.'
              : 'Your operations report has been generated successfully and is ready to download.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF4ECDC4)),
            ),
          ),
        ],
      ),
    );
  }
}