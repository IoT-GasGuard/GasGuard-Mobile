class HouseholdMember {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final bool isEmergencyContact;
  final bool gasLeakAlerts;
  final bool notificationsEnabled;

  HouseholdMember({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.isEmergencyContact = false,
    this.gasLeakAlerts = true,
    this.notificationsEnabled = true,
  });

  HouseholdMember copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    bool? isEmergencyContact,
    bool? gasLeakAlerts,
    bool? notificationsEnabled,
  }) {
    return HouseholdMember(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
      gasLeakAlerts: gasLeakAlerts ?? this.gasLeakAlerts,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'isEmergencyContact': isEmergencyContact,
      'gasLeakAlerts': gasLeakAlerts,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      id: json['id'],
      fullName: json['fullName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      isEmergencyContact: json['isEmergencyContact'] ?? false,
      gasLeakAlerts: json['gasLeakAlerts'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }
}