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
    required this.isResolved,
    required this.actionsPerformed,
  });

  // Constructor desde JSON del API
  factory GasIncident.fromApiJson(Map<String, dynamic> json) {
    return GasIncident(
      id: json['id'].toString(),
      deviceName: json['device'] ?? 'Unknown Device',
      location: json['location'] ?? 'Unknown Location',
      gasLevel: (json['gasLevel'] as num).toDouble(),
      detectedAt: _parseDateTime(json['date'], json['time']),
      duration: _parseDuration(json['duration']),
      isResolved: json['resolved'] ?? false,
      actionsPerformed: List<String>.from(json['actionsTaken'] ?? []),
    );
  }

  // Método auxiliar para parsear fecha y hora
  static DateTime _parseDateTime(String? date, String? time) {
    try {
      if (date != null && time != null) {
        return DateTime.parse('${date}T$time');
      }
      return DateTime.now();
    } catch (e) {
      return DateTime.now();
    }
  }

  // Método auxiliar para parsear duración
  static Duration _parseDuration(String? durationStr) {
    if (durationStr == null) return Duration.zero;

    try {
      // Asumiendo formato "HH:MM:SS" o "MM:SS"
      final parts = durationStr.split(':');
      if (parts.length == 3) {
        return Duration(
          hours: int.parse(parts[0]),
          minutes: int.parse(parts[1]),
          seconds: int.parse(parts[2]),
        );
      } else if (parts.length == 2) {
        return Duration(
          minutes: int.parse(parts[0]),
          seconds: int.parse(parts[1]),
        );
      }
    } catch (e) {
      print('Error parsing duration: $e');
    }

    return Duration.zero;
  }

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