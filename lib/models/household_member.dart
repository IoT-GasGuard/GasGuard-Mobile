class HouseholdMember {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final bool isEmergencyContact;
  final bool gasLeakAlerts;
  final bool notificationsEnabled;
  final String? profileId;

  HouseholdMember({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.isEmergencyContact = false,
    this.gasLeakAlerts = true,
    this.notificationsEnabled = true,
    this.profileId,
  });

  HouseholdMember copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    bool? isEmergencyContact,
    bool? gasLeakAlerts,
    bool? notificationsEnabled,
    String? profileId,
  }) {
    return HouseholdMember(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isEmergencyContact: isEmergencyContact ?? this.isEmergencyContact,
      gasLeakAlerts: gasLeakAlerts ?? this.gasLeakAlerts,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      profileId: profileId ?? this.profileId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': fullName,
      'email': email,
      'phone': phoneNumber,
      'emergencyContact': isEmergencyContact,
      'gasAlerts': gasLeakAlerts,
      'profileId': profileId,
    };
  }

  factory HouseholdMember.fromJson(Map<String, dynamic> json) {
    return HouseholdMember(
      id: json['id']?.toString() ?? '',
      fullName: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone'] ?? '',
      isEmergencyContact: json['emergencyContact'] ?? false,
      gasLeakAlerts: json['gasAlerts'] ?? true,
      notificationsEnabled: json['gasAlerts'] ?? true,
      profileId: json['profileId']?.toString(),
    );
  }
}