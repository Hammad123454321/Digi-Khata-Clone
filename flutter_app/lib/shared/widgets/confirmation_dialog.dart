import 'package:flutter/material.dart';

/// Utility widget for showing confirmation dialogs
class ConfirmationDialog {
  /// Show a confirmation dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
    bool isDestructive = false,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive
                  ? (confirmColor ?? Colors.red)
                  : (confirmColor ?? Theme.of(context).colorScheme.primary),
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show a delete confirmation dialog
  static Future<bool?> showDelete({
    required BuildContext context,
    required String itemName,
    String? additionalMessage,
  }) async {
    return show(
      context: context,
      title: 'Delete $itemName?',
      message: additionalMessage ??
          'Are you sure you want to delete this $itemName? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );
  }
}
