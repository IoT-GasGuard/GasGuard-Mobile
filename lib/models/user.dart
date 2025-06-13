class User {
  final String id;
  final String email;
  final String name;
  final List<String> deviceIds; // IDs de dispositivos vinculados
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.deviceIds = const [],
  });
  
  // Conversión a JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'deviceIds': deviceIds,
  };
  
  // Constructor desde JSON
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    name: json['name'],
    deviceIds: List<String>.from(json['deviceIds'] ?? []),
  );
}