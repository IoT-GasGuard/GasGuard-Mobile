class User {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String profileId;
  final List<String> deviceIds;

  User({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    required this.profileId,
    this.deviceIds = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id']?.toString() ?? '',
    email: json['email'] ?? '',
    name: json['name'],
    phoneNumber: json['phoneNumber'],
    profileId: json['profileId']?.toString() ?? '',
    deviceIds: List<String>.from(json['deviceIds'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'phoneNumber': phoneNumber,
    'profileId': profileId, // <-- SOLO camelCase
    'deviceIds': deviceIds,
  };
}