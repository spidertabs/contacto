// lib/data/models/contact.dart
class Contact {
  final int? id;
  final String name;
  final String? phone;
  final String? email;
  final String? notes;
  final String? createdAt;

  Contact({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.notes,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone ?? '',
      'email': email ?? '',
      'notes': notes ?? '',
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  Contact copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? notes,
    String? createdAt,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns initials (up to 2 chars) for use in avatar widgets
  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }
}