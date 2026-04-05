// lib/shared/widgets/contact_avatar.dart
import 'package:flutter/material.dart';

/// Displays a coloured circle avatar with the contact's initials.
class ContactAvatar extends StatelessWidget {
  final String name;
  final double radius;

  const ContactAvatar({super.key, required this.name, this.radius = 24});

  /// Deterministically picks a colour based on the contact's name.
  Color _avatarColor() {
    const colors = [
      Color(0xFF4F6EF7),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF8B5CF6),
      Color(0xFF06B6D4),
      Color(0xFFEC4899),
      Color(0xFF14B8A6),
    ];
    if (name.isEmpty) return colors[0];
    final index = name.codeUnitAt(0) % colors.length;
    return colors[index];
  }

  String get _initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _avatarColor(),
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}