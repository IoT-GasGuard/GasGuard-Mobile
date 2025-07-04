import 'package:flutter/material.dart';
import 'package:gasguard_mobile/models/daily_average.dart';
import 'package:gasguard_mobile/models/gas_incident.dart';
import 'package:gasguard_mobile/service/report_service.dart';
import 'package:gasguard_mobile/shared/helpers/storage_helper.dart';
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
  bool _isLoading = true;
  String? _error;

  // Datos cargados desde el API
  List<GasIncident> _incidents = [];
  List<DailyAverage> _dailyAverages = [];

  // Estadísticas calculadas
  double _averageGasLevel = 0.0;
  double _weeklyAverage = 0.0;
  double _peakGasLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Obtener usuario para el profileId
      final user = await StorageHelper.getUser();
      print('👤 Usuario obtenido: ${user?.toJson()}');
      
      if (user == null || user.profileId.isEmpty) {
        setState(() {
          _error = 'No se pudo obtener información del usuario';
          _isLoading = false;
        });
        return;
      }

      print('📊 Cargando reportes para profileId: ${user.profileId}');
      
      // Cargar reportes desde el API
      final response = await ReportService.getReportsByProfile(user.profileId);
      
      print('📊 Respuesta del API: ${response.statusCode}');
      print('📊 Datos recibidos: ${response.data}');
      
      if (response.statusCode == 200) {
        final dynamic responseData = response.data;
        
        // Verificar si la respuesta es una lista
        if (responseData is List) {
          final List<dynamic> reportsJson = responseData;
          final incidents = ReportService.parseReportsToIncidents(reportsJson);
          
          print('📊 Incidentes procesados: ${incidents.length}');
          
          setState(() {
            _incidents = incidents;
            _isLoading = false;
          });

          // Calcular estadísticas
          _calculateStatistics();
          _generateDailyAverages();
        } else {
          print('❌ Respuesta no es una lista: $responseData');
          setState(() {
            _error = 'Formato de respuesta inválido';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Error al cargar reportes: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error completo: $e');
      setState(() {
        _error = 'Error de conexión: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _calculateStatistics() {
    if (_incidents.isEmpty) return;

    // Calcular promedio general
    final totalGasLevel = _incidents.fold(0.0, (sum, incident) => sum + incident.gasLevel);
    _averageGasLevel = totalGasLevel / _incidents.length;

    // Calcular promedio semanal (últimos 7 días)
    final weekAgo = DateTime.now().subtract(Duration(days: 7));
    final weeklyIncidents = _incidents.where((incident) => 
      incident.detectedAt.isAfter(weekAgo)).toList();
    
    if (weeklyIncidents.isNotEmpty) {
      final weeklyTotal = weeklyIncidents.fold(0.0, (sum, incident) => sum + incident.gasLevel);
      _weeklyAverage = weeklyTotal / weeklyIncidents.length;
    }

    // Encontrar pico máximo
    _peakGasLevel = _incidents.fold(0.0, (max, incident) => 
      incident.gasLevel > max ? incident.gasLevel : max);
  }

  void _generateDailyAverages() {
    // Agrupar incidentes por día
    final Map<String, List<GasIncident>> dailyGroups = {};
    
    for (final incident in _incidents) {
      final dateKey = '${incident.detectedAt.year}-${incident.detectedAt.month}-${incident.detectedAt.day}';
      dailyGroups[dateKey] ??= [];
      dailyGroups[dateKey]!.add(incident);
    }

    // Calcular promedio por día
    final List<DailyAverage> averages = [];
    
    dailyGroups.forEach((dateKey, incidents) {
      final date = incidents.first.detectedAt;
      final totalGas = incidents.fold(0.0, (sum, incident) => sum + incident.gasLevel);
      final average = totalGas / incidents.length;
      
      averages.add(DailyAverage(
        date: DateTime(date.year, date.month, date.day),
        average: average,
      ));
    });

    // Ordenar por fecha (más reciente primero)
    averages.sort((a, b) => b.date.compareTo(a.date));
    
    setState(() {
      _dailyAverages = averages.take(10).toList(); // Solo últimos 10 días
    });
  }

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
              child: _isLoading
                  ? _buildLoadingState()
                  : _error != null
                      ? _buildErrorState()
                      : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF4ECDC4)),
          SizedBox(height: 16),
          Text(
            'Cargando reportes...',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            _error ?? 'Error desconocido',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadReports,
            child: Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return _showGasIncidents
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Report & Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _loadReports,
                icon: Icon(Icons.refresh, color: Color(0xFF4ECDC4)),
                tooltip: 'Actualizar reportes',
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  title: 'Gas Incidents (${_incidents.length})',
                  isSelected: _showGasIncidents,
                  onTap: () => setState(() => _showGasIncidents = true),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildTabButton(
                  title: 'Normal Operations',
                  isSelected: !_showGasIncidents,
                  onTap: () => setState(() => _showGasIncidents = false),
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
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF4ECDC4) : Color(0xFF1A2B3D),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  void _showReportGeneratedDialog(bool isIncidentReport) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF1A2B3D),
        title: Text('Report Generated', style: TextStyle(color: Colors.white)),
        content: Text(
          isIncidentReport 
              ? 'Your gas leak incident report has been generated successfully.'
              : 'Your operations report has been generated successfully.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF4ECDC4))),
          ),
        ],
      ),
    );
  }
}