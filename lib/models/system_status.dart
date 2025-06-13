class SystemStatus {
  bool gasValveActive;
  bool ventilationActive;
  bool doorSystemActive;
  bool lightingSystemActive;

  SystemStatus({
    this.gasValveActive = true,
    this.ventilationActive = true,
    this.doorSystemActive = true,
    this.lightingSystemActive = true,
  });

  // Método para activar protocolo de emergencia
  void activateEmergencyProtocol() {
    gasValveActive = false;
    ventilationActive = true;
    doorSystemActive = true;
    lightingSystemActive = true;
  }

  // Método para restaurar operación normal
  void restoreNormalOperation() {
    gasValveActive = true;
    ventilationActive = false;
    doorSystemActive = true;
    lightingSystemActive = true;
  }

  // Conversión a JSON
  Map<String, dynamic> toJson() => {
    'gasValveActive': gasValveActive,
    'ventilationActive': ventilationActive,
    'doorSystemActive': doorSystemActive,
    'lightingSystemActive': lightingSystemActive,
  };

  // Constructor desde JSON
  factory SystemStatus.fromJson(Map<String, dynamic> json) {
    return SystemStatus(
      gasValveActive: json['gasValveActive'] ?? true,
      ventilationActive: json['ventilationActive'] ?? true,
      doorSystemActive: json['doorSystemActive'] ?? true,
      lightingSystemActive: json['lightingSystemActive'] ?? true,
    );
  }
}