import 'package:flutter/material.dart';
import '../../../../models/gas_reading.dart';
import 'package:intl/intl.dart'; 

class DeviceChart extends StatelessWidget {
  final List<GasReading> readings;
  final bool isEmergencyMode;

  const DeviceChart({
    Key? key,
    required this.readings,
    required this.isEmergencyMode,
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
            'Historial de lecturas',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Gráfico
          SizedBox(
            height: 180,
            child: readings.isEmpty
                ? _buildEmptyChart()
                : _buildChart(context),
          ),
          
          const SizedBox(height: 16),
          
          // Leyenda de tiempo
          _buildTimeScaleLegend(),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return const Center(
      child: Text(
        'No hay datos históricos disponibles',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    // Convertir las lecturas a valores para la gráfica
    final List<double> chartData = readings.map((r) => r.value).toList();
    
    return CustomPaint(
      size: Size.infinite,
      painter: GasReadingsChartPainter(
        data: chartData,
        isEmergency: isEmergencyMode,
      ),
    );
  }

  Widget _buildTimeScaleLegend() {
    if (readings.isEmpty || readings.length < 2) {
      return const SizedBox();
    }

    final DateFormat formatter = DateFormat('HH:mm');
    final String startTime = formatter.format(readings.first.timestamp);
    final String endTime = formatter.format(readings.last.timestamp);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          startTime,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const Text(
          'Tiempo',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          endTime,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class GasReadingsChartPainter extends CustomPainter {
  final List<double> data;
  final bool isEmergency;

  GasReadingsChartPainter({
    required this.data,
    required this.isEmergency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Usar la misma lógica de tu GasLevelChartPainter existente
    if (data.isEmpty) return;

    final Paint linePaint = Paint()
      ..color = isEmergency ? Colors.red : const Color(0xFF4ECDC4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          isEmergency ? Colors.red.withOpacity(0.5) : const Color(0xFF4ECDC4).withOpacity(0.5),
          isEmergency ? Colors.red.withOpacity(0.0) : const Color(0xFF4ECDC4).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    
    // Línea horizontal para el nivel de alerta (70%)
    final Paint alertLinePaint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    double alertY = size.height * (1 - 0.7); // 70% desde abajo
    canvas.drawLine(
      Offset(0, alertY),
      Offset(size.width, alertY),
      alertLinePaint,
    );
    
    // Dibujar paths
    final Path linePath = Path();
    final Path fillPath = Path();
    
    // Iniciar los paths
    double startX = 0;
    double startY = size.height * (1 - data.first / 100);
    linePath.moveTo(startX, startY);
    fillPath.moveTo(startX, size.height);
    fillPath.lineTo(startX, startY);
    
    // Calcular paso X
    double xStep = size.width / (data.length - 1 > 0 ? data.length - 1 : 1);
    
    // Dibujar líneas entre puntos
    for (int i = 1; i < data.length; i++) {
      double x = i * xStep;
      double y = size.height * (1 - data[i] / 100);
      
      linePath.lineTo(x, y);
      fillPath.lineTo(x, y);
    }
    
    // Completar el path de relleno
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    
    // Dibujar
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
    
    // Dibujar puntos de datos
    for (int i = 0; i < data.length; i++) {
      double x = i * xStep;
      double y = size.height * (1 - data[i] / 100);
      
      // Dibujar solo algunos puntos para no saturar la gráfica
      if (i % 3 == 0 || i == data.length - 1) {
        final Paint dotPaint = Paint()
          ..color = isEmergency ? Colors.red : const Color(0xFF4ECDC4)
          ..style = PaintingStyle.fill;
          
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is GasReadingsChartPainter) {
      return oldDelegate.isEmergency != isEmergency || 
             oldDelegate.data != data;
    }
    return true;
  }
}