import 'package:flutter/material.dart';
import 'tokens.dart';

/// Shared state resolution for Material menus and Ianvs option panels.
abstract final class IanvsMenuStyle {
  static ButtonStyle item(IanvsTokens t, {bool selected = false}) {
    bool isSelected(Set<WidgetState> states) =>
        selected || states.contains(WidgetState.selected);
    final foreground = WidgetStateProperty.resolveWith<Color>(
      (states) => states.contains(WidgetState.disabled)
          ? t.subtle
          : isSelected(states)
          ? t.onSelected
          : t.text,
    );
    return ButtonStyle(
      alignment: AlignmentDirectional.centerStart,
      minimumSize: WidgetStatePropertyAll(Size(48, t.rowHeight)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(t.controlRadius),
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.transparent;
        if (isSelected(states)) return t.selected;
        if (states.contains(WidgetState.pressed)) {
          return t.text.withValues(alpha: .10);
        }
        // SubmenuButton also gains focus when the mouse opens it. Resolve
        // hover first so that this combined state keeps the softer feedback.
        if (states.contains(WidgetState.hovered)) {
          return t.text.withValues(alpha: .05);
        }
        if (states.contains(WidgetState.focused)) {
          return t.text.withValues(alpha: .08);
        }
        return Colors.transparent;
      }),
      foregroundColor: foreground,
      iconColor: foreground,
      iconSize: const WidgetStatePropertyAll(16),
      // The background owns feedback; never stack a second grey ink overlay.
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      side: const WidgetStatePropertyAll(BorderSide.none),
      elevation: const WidgetStatePropertyAll(0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      animationDuration: const Duration(milliseconds: 100),
    );
  }
}
