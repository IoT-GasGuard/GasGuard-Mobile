class GasReading {
  final double value;
  final DateTime timestamp;
  final bool isEmergency;

  const GasReading({
    required this.value,
    required this.timestamp,
    this.isEmergency = false,
  });

  String get status {
    if (value > 70) return 'danger';
    if (value > 30) return 'warning';
    return 'safe';
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    'isEmergency': isEmergency,
  };

  factory GasReading.fromJson(Map<String, dynamic> json) {
    return GasReading(
      value: json['value'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      isEmergency: json['isEmergency'] ?? false,
    );
  }
}