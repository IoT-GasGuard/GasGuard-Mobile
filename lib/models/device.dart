import 'gas_reading.dart';
import 'system_status.dart';

class Device {
  final String id;
  String deviceId;
  String name;
  bool isOnline;
  DateTime lastSeen;
  String location;
  String status; // "ONLINE", "OFFLINE", "ALERT"
  final String profileId;

  GasReading? lastReading;
  SystemStatus systemStatus;
  List<GasReading> readings;

  Device({
    required this.id,
    required this.deviceId,
    required this.name,
    this.isOnline = true,
    required this.lastSeen,
    required this.location,
    required this.status,
    required this.profileId,
    this.lastReading,
    SystemStatus? systemStatus,
    List<GasReading>? readings,
  }) :
        this.systemStatus = systemStatus ?? SystemStatus(),
        this.readings = readings ?? [];

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id']?.toString() ?? '',
      deviceId: json['deviceId'] ?? json['device_id'] ?? '',
      name: json['name'] ?? 'Dispositivo sin nombre',
      location: json['location'] ?? 'Sin ubicación',
      status: json['status'] ?? 'OFFLINE',
      profileId: json['profileId']?.toString() ?? json['profile_id']?.toString() ?? '',
      isOnline: (json['status'] ?? 'OFFLINE') == 'ONLINE',
      lastSeen: json['lastReading'] != null ? 
        DateTime.tryParse(json['lastReading']) ?? DateTime.now() : 
        DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'name': name,
    'location': location,
    'status': status,
    'profileId': profileId,
  };

  String getTimeSinceLastSeen() {
    final difference = DateTime.now().difference(lastSeen);
    if (difference.inSeconds < 60) return '${difference.inSeconds} seg';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min';
    if (difference.inHours < 24) return '${difference.inHours} hrs';
    return '${difference.inDays} días';
  }

  void addReading(GasReading reading) {
    readings.add(reading);
    lastReading = reading;
    lastSeen = reading.timestamp;
    isOnline = true;
    
    if (reading.isEmergency) {
      status = 'ALERT';
    } else {
      status = 'ONLINE';
    }
    if (readings.length > 50) {
      readings.removeAt(0);
    }
  }
}