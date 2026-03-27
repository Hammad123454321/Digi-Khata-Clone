import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for better app accessibility
class AccessibilityUtils {
  /// Set semantic labels for better screen reader support
  static void setSemanticLabel(Widget widget, String label) {
    Semantics(
      label: label,
      child: widget,
    );
  }

  /// Create accessible button
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String semanticLabel,
    String? hint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: true,
      enabled: onPressed != null,
      child: child,
    );
  }

  /// Create accessible text field
  static Widget accessibleTextField({
    required Widget child,
    required String label,
    String? hint,
    String? value,
    bool isRequired = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      textField: true,
      child: child,
    );
  }

  /// Announce message to screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Check if accessibility features are enabled
  static bool isAccessibilityEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.boldText || mediaQuery.textScaleFactor > 1.0;
  }
}
