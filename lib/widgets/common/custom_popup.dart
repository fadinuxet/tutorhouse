import 'package:flutter/material.dart';
import '../../config/constants.dart';

enum PopupType {
  success,
  error,
  warning,
  info,
}

class CustomPopup extends StatelessWidget {
  final String title;
  final String message;
  final PopupType type;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final String? confirmText;
  final String? cancelText;

  const CustomPopup({
    super.key,
    required this.title,
    required this.message,
    required this.type,
    this.onConfirm,
    this.onCancel,
    this.confirmText,
    this.cancelText,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppConstants.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppConstants.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          color: AppConstants.textPrimary,
          fontSize: 16,
        ),
      ),
      actions: [
        if (onCancel != null)
          TextButton(
            onPressed: onCancel,
            child: Text(
              cancelText ?? 'Cancel',
              style: const TextStyle(
                color: AppConstants.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
        if (onConfirm != null)
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getButtonColor(),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText ?? 'OK',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  IconData _getIcon() {
    switch (type) {
      case PopupType.success:
        return Icons.check_circle;
      case PopupType.error:
        return Icons.error;
      case PopupType.warning:
        return Icons.warning;
      case PopupType.info:
        return Icons.info;
    }
  }

  Color _getIconColor() {
    switch (type) {
      case PopupType.success:
        return Colors.green;
      case PopupType.error:
        return Colors.red;
      case PopupType.warning:
        return Colors.orange;
      case PopupType.info:
        return Colors.blue;
    }
  }

  Color _getButtonColor() {
    switch (type) {
      case PopupType.success:
        return Colors.green;
      case PopupType.error:
        return Colors.red;
      case PopupType.warning:
        return Colors.orange;
      case PopupType.info:
        return AppConstants.primaryColor;
    }
  }
}
