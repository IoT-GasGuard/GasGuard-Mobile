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
          isEmergency ? Colors.red.withOpacity(0.3) : const Color(0xFF4ECDC4).withOpacity(0.3),
          isEmergency ? Colors.red.withOpacity(0.0) : const Color(0xFF4ECDC4).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // 🔥 LÍNEA HORIZONTAL PARA EL NIVEL DE ALERTA (70%)
    final Paint alertLinePaint = Paint()
      ..color = Colors.red.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double alertY = size.height * (1 - 0.7); // 70% desde abajo
    
    // Línea discontinua para el nivel de alerta
    _drawDashedLine(canvas, Offset(0, alertY), Offset(size.width, alertY), alertLinePaint);

    // 🔥 CREAR PATHS PARA LÍNEA Y RELLENO
    final Path linePath = Path();
    final Path fillPath = Path();

    if (data.length == 1) {
      // Solo un punto - dibujar línea horizontal
      final double y = size.height - (data.first.clamp(0.0, 100.0) / 100) * size.height;
      linePath.moveTo(0, y);
      linePath.lineTo(size.width, y);
      
      fillPath.moveTo(0, size.height);
      fillPath.lineTo(0, y);
      fillPath.lineTo(size.width, y);
      fillPath.lineTo(size.width, size.height);
      fillPath.close();
    } else {
      // Múltiples puntos - crear curva suave
      double stepX = size.width / (data.length - 1);
      
      // Primer punto
      double firstY = size.height - (data.first.clamp(0.0, 100.0) / 100) * size.height;
      linePath.moveTo(0, firstY);
      fillPath.moveTo(0, size.height);
      fillPath.lineTo(0, firstY);
      
      // 🔥 USAR CURVAS CUADRÁTICAS SIMPLES
      for (int i = 1; i < data.length; i++) {
        double currentX = i * stepX;
        double currentY = size.height - (data[i].clamp(0.0, 100.0) / 100) * size.height;
        
        if (i == 1) {
          // Primer segmento - línea directa
          linePath.lineTo(currentX, currentY);
          fillPath.lineTo(currentX, currentY);
        } else {
          // Segmentos siguientes - curva suave
          double prevX = (i - 1) * stepX;
          double prevY = size.height - (data[i - 1].clamp(0.0, 100.0) / 100) * size.height;
          
          // Punto de control para curva suave
          double controlX = prevX + (currentX - prevX) * 0.5;
          double controlY = prevY;
          
          linePath.quadraticBezierTo(controlX, controlY, currentX, currentY);
          fillPath.quadraticBezierTo(controlX, controlY, currentX, currentY);
        }
      }
      
      // Completar el área de relleno
      fillPath.lineTo(size.width, size.height);
      fillPath.close();
    }

    // 🔥 DIBUJAR PRIMERO EL RELLENO, LUEGO LA LÍNEA
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
    
    // 🔥 DIBUJAR PUNTOS EN LOS DATOS IMPORTANTES
    final Paint dotPaint = Paint()
      ..color = isEmergency ? Colors.red : const Color(0xFF4ECDC4)
      ..style = PaintingStyle.fill;

    final Paint dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Dibujar punto en el último valor (más prominente)
    if (data.isNotEmpty) {
      double lastX = data.length == 1 ? size.width / 2 : size.width;
      double lastY = size.height - (data.last.clamp(0.0, 100.0) / 100) * size.height;
      
      canvas.drawCircle(Offset(lastX, lastY), 6, dotBorderPaint);
      canvas.drawCircle(Offset(lastX, lastY), 4, dotPaint);
    }

    // Dibujar puntos en valores altos (>70%)
    if (data.length > 1) {
      double stepX = size.width / (data.length - 1);
      for (int i = 0; i < data.length; i++) {
        if (data[i] > 70) {
          double x = i * stepX;
          double y = size.height - (data[i].clamp(0.0, 100.0) / 100) * size.height;
          canvas.drawCircle(Offset(x, y), 3, Paint()..color = Colors.red);
        }
      }
    }
  }

  // 🔥 MÉTODO PARA DIBUJAR LÍNEA DISCONTINUA
  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const double dashWidth = 5;
    const double dashSpace = 3;
    double distance = (end - start).distance;
    double drawn = 0;
    
    while (drawn < distance) {
      double dashEnd = drawn + dashWidth;
      if (dashEnd > distance) dashEnd = distance;
      
      Offset dashStart = Offset.lerp(start, end, drawn / distance)!;
      Offset dashEndPoint = Offset.lerp(start, end, dashEnd / distance)!;
      
      canvas.drawLine(dashStart, dashEndPoint, paint);
      drawn += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant GasLevelChartPainter oldDelegate) {
    return oldDelegate.isEmergency != isEmergency || 
           oldDelegate.data.length != data.length ||
           !_listsEqual(oldDelegate.data, data);
  }
  
  // 🔥 MÉTODO AUXILIAR PARA COMPARAR LISTAS
  bool _listsEqual(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() > 0.1) return false; // Tolerancia de 0.1
    }
    return true;
  }
}