// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated fingerprint button with a subtle pulse effect.
class FingerprintButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String label;

  const FingerprintButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.label = 'Scan Fingerprint',
  });

  @override
  State<FingerprintButton> createState() => _FingerprintButtonState();
}

class _FingerprintButtonState extends State<FingerprintButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: widget.isLoading ? null : widget.onPressed,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (_, child) {
              return Transform.scale(
                scale: widget.isLoading ? 1.0 : _pulseAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ContactoTheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: ContactoTheme.primary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: widget.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(28),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.fingerprint,
                      size: 50,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          widget.isLoading ? 'Scanning…' : widget.label,
          style: const TextStyle(
            fontSize: 14,
            color: ContactoTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
