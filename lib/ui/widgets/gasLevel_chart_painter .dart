import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GasLevelChartPainter extends CustomPainter {
  final List<double> data;
  final bool isEmergency;

  GasLevelChartPainter(this.data, {this.isEmergency = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final Paint linePaint = Paint()
      ..color = isEmergency ? Colors.red : const Color(0xFF4ECDC4)
      ..strokeWidth = 3.0
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
      ..color = isEmergency ? Colors.red.withOpacity(0.7) : Colors.red.withOpacity(0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double alertY = size.height * (1 - 0.7); // 70% desde abajo
    canvas.drawLine(
      Offset(0, alertY),
      Offset(size.width, alertY),
      alertLinePaint,
    );

    // Dibujar la línea de datos
    final Path linePath = Path();
    final Path fillPath = Path();

    // Iniciar los paths
    linePath.moveTo(0, size.height - (data.first / 100) * size.height);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height - (data.first / 100) * size.height);

    // Calcular el espacio entre puntos
    double xStep = size.width / (data.length - 1);

    // Dibujar los puntos y conectarlos
    for (int i = 1; i < data.length; i++) {
      final double x = i * xStep;
      final double y = size.height - (data[i] / 100) * size.height;

      // Suavizar la curva
      if (i > 1) {
        final double prevX = (i - 1) * xStep;
        final double prevY = size.height - (data[i - 1] / 100) * size.height;
        
        final double controlX1 = prevX + (x - prevX) / 2;
        final double controlY1 = prevY;
        final double controlX2 = prevX + (x - prevX) / 2;
        final double controlY2 = y;
        
        linePath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
        fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Completar el path de relleno
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Dibujar el gráfico
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
    
    // Dibuja puntos en los datos para destacarlos
    final Paint dotPaint = Paint()
      ..color = isEmergency ? Colors.red : const Color(0xFF4ECDC4)
      ..style = PaintingStyle.fill;

    final double lastX = (data.length - 1) * xStep;
    final double lastY = size.height - (data.last / 100) * size.height;
    canvas.drawCircle(Offset(lastX, lastY), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant GasLevelChartPainter oldDelegate) {
    return oldDelegate.isEmergency != isEmergency || oldDelegate.data != data;
  }
}