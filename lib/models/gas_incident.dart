
class GasIncident {
  final String id;
  final String deviceName;
  final String location;
  final double gasLevel;
  final DateTime detectedAt;
  final Duration duration;
  final bool isResolved;
  final List<String> actionsPerformed;
  
  GasIncident({
    required this.id,
    required this.deviceName,
    required this.location,
    required this.gasLevel,
    required this.detectedAt, 
    required this.duration,
    this.isResolved = false,
    this.actionsPerformed = const [],
  });
  
  // Método para obtener una representación textual de la duración
  String get durationText {
    if (duration.inHours > 0) {
      return '${duration.inHours} horas ${duration.inMinutes % 60} minutos';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minutos';
    } else {
      return '${duration.inSeconds} segundos';
    }
  }
  
  // Método para obtener una fecha formateada
  String getFormattedDate() {
    return '${detectedAt.day}-${detectedAt.month}-${detectedAt.year} ${detectedAt.hour}:${detectedAt.minute.toString().padLeft(2, '0')}';
  }
}