import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Accessibility utilities for WCAG AA compliance
class AccessibilityUtils {
  /// Minimum touch target size (48x48 dp as per WCAG guidelines)
  static const double minTouchTargetSize = 48.0;

  /// Minimum font size for body text
  static const double minBodyFontSize = 14.0;

  /// Minimum font size for headings
  static const double minHeadingFontSize = 18.0;

  /// Check if widget meets minimum touch target size
  static bool meetsTouchTargetRequirement(Size size) {
    return size.height >= minTouchTargetSize && size.width >= minTouchTargetSize;
  }

  /// Create semantic label for screen reader
  static String createSemanticLabel({
    required String widgetType,
    String? action,
    String? state,
    String? value,
  }) {
    final parts = <String>[widgetType];
    if (action != null) parts.add(action);
    if (state != null) parts.add(state);
    if (value != null) parts.add(value);
    return parts.join(' ');
  }

  /// Announce message for screen reader
  static void announceForAccessibility(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Create tooltip with accessibility support
  static Tooltip createAccessibleTooltip({
    required Widget child,
    required String tooltip,
    String? semanticsLabel,
  }) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        label: semanticsLabel ?? tooltip,
        child: child,
      ),
    );
  }

  /// Verify color contrast meets WCAG AA standards
  /// Returns true if contrast ratio is at least 4.5:1 for normal text
  static bool meetsContrastRequirements(Color foreground, Color background) {
    final contrastRatio = _calculateContrastRatio(foreground, background);
    return contrastRatio >= 4.5;
  }

  /// Calculate contrast ratio between two colors
  static double _calculateContrastRatio(Color foreground, Color background) {
    final l1 = _getLuminance(foreground);
    final l2 = _getLuminance(background);
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Get relative luminance of a color
  static double _getLuminance(Color color) {
    final r = _linearize(color.r / 255.0);
    final g = _linearize(color.g / 255.0);
    final b = _linearize(color.b / 255.0);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double value) {
    return value <= 0.03928
        ? value / 12.92
        : ((value + 0.055) / 1.055).abs();
  }
}

/// Semantic text span for accessibility
class SemanticTextSpan {
  final String text;
  final String? label;
  final bool isHeading;

  const SemanticTextSpan({
    required this.text,
    this.label,
    this.isHeading = false,
  });

  TextSpan toTextSpan() {
    return TextSpan(
      text: text,
      semanticsLabel: label ?? (isHeading ? 'Heading: $text' : text),
    );
  }
}

/// Accessibility-focused button builder
class AccessibleButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;

  const AccessibleButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          )
        : Text(label);

    return Semantics(
      button: true,
      label: label,
      enabled: onPressed != null,
      child: isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
              child: buttonChild,
            )
          : TextButton(
              onPressed: onPressed,
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 48),
              ),
              child: buttonChild,
            ),
    );
  }
}

/// Accessible form field wrapper
class AccessibleFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? errorText;
  final Widget child;

  const AccessibleFormField({
    super.key,
    required this.label,
    this.hint,
    this.errorText,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          child,
          if (errorText != null) ...[
            const SizedBox(height: 4),
            Text(
              errorText!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}