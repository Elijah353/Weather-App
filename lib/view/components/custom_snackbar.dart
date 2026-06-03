import 'package:flutter/material.dart';

enum SnackType { success, info, error }

class CustomSnackBar {
  const CustomSnackBar._();

  static void show(
    BuildContext context, {
    required SnackType type,
    required String message,
    String? title,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final _SnackStyle style = _styles[type]!;

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: const Duration(seconds: 2),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: style.background.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(style.icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title ?? style.defaultTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}

class _SnackStyle {
  const _SnackStyle({
    required this.background,
    required this.icon,
    required this.defaultTitle,
  });

  final Color background;
  final IconData icon;
  final String defaultTitle;
}

const Map<SnackType, _SnackStyle> _styles = {
  SnackType.success: _SnackStyle(
    background: Color(0xFF2E7D32),
    icon: Icons.check_circle_rounded,
    defaultTitle: 'Success',
  ),
  SnackType.info: _SnackStyle(
    background: Color(0xFF2962FF),
    icon: Icons.info_rounded,
    defaultTitle: 'Info',
  ),
  SnackType.error: _SnackStyle(
    background: Color(0xFFD32F2F),
    icon: Icons.error_rounded,
    defaultTitle: 'Error',
  ),
};
