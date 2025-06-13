import 'gas_reading.dart';
import 'system_status.dart';

class Device {
  final String id;
  String name;
  bool isOnline;
  DateTime lastSeen;
  String location;

  // Relación con otros modelos
  GasReading? lastReading;
  SystemStatus systemStatus;
  List<GasReading> readings;

  Device({
    required this.id,
    required this.name,
    this.isOnline = true,
    required this.lastSeen,
    required this.location,
    this.lastReading,
    SystemStatus? systemStatus,
    List<GasReading>? readings,
  }) :
        this.systemStatus = systemStatus ?? SystemStatus(),
        this.readings = readings ?? [];

  // Método para obtener tiempo desde última comunicación
  String getTimeSinceLastSeen() {
    final difference = DateTime.now().difference(lastSeen);
    if (difference.inSeconds < 60) return '${difference.inSeconds} seg';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min';
    if (difference.inHours < 24) return '${difference.inHours} hrs';
    return '${difference.inDays} días';
  }

  // Método para añadir una nueva lectura
  void addReading(GasReading reading) {
    readings.add(reading);
    lastReading = reading;
    lastSeen = reading.timestamp;

    // Activar protocolos de emergencia si es necesario
    if (reading.isEmergency || reading.value > 70) {
      systemStatus.activateEmergencyProtocol();
    }
    // Restaurar operación normal si volvió a niveles seguros
    else if (reading.value < 30 && readings.length > 1 &&
        readings[readings.length - 2].value > 70) {
      systemStatus.restoreNormalOperation();
    }
  }

  // Método para obtener lecturas recientes (para la gráfica)
  List<GasReading> getRecentReadings(int count) {
    if (readings.length <= count) return List.from(readings);
    return readings.sublist(readings.length - count);
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isOnline': isOnline,
    'lastSeen': lastSeen.toIso8601String(),
    'location': location,
    'lastReading': lastReading?.toJson(),
    'systemStatus': systemStatus.toJson(),
    'readings': readings.map((reading) => reading.toJson()).toList(),
  };

  // Constructor desde JSON
  factory Device.fromJson(Map<String, dynamic> json) {
    List<GasReading> readingsList = [];
    if (json['readings'] != null) {
      final List readingsJson = json['readings'] as List;
      readingsList = readingsJson
          .map((readingJson) => GasReading.fromJson(readingJson))
          .toList();
    }

    return Device(
      id: json['id'],
      name: json['name'],
      isOnline: json['isOnline'] ?? true,
      lastSeen: DateTime.parse(json['lastSeen']),
      location: json['location'],
      lastReading: json['lastReading'] != null ?
      GasReading.fromJson(json['lastReading']) : null,
      systemStatus: json['systemStatus'] != null ?
      SystemStatus.fromJson(json['systemStatus']) : null,
      readings: readingsList,
    );
  }
}