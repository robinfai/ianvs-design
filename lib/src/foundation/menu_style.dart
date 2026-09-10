import 'package:flutter/material.dart';
import 'tokens.dart';

/// Shared state resolution for Material menus and Ianvs option panels.
abstract final class IanvsMenuStyle {
  static ButtonStyle item(IanvsTokens t, {bool selected = false}) {
    bool active(Set<WidgetState> states) =>
        !states.contains(WidgetState.disabled) &&
        (selected ||
            states.contains(WidgetState.selected) ||
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused));
    final foreground = WidgetStateProperty.resolveWith<Color>(
      (states) => states.contains(WidgetState.disabled)
          ? t.subtle
          : active(states)
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
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => active(states) ? t.selected : Colors.transparent,
      ),
      foregroundColor: foreground,
      iconColor: foreground,
      iconSize: const WidgetStatePropertyAll(16),
      // The background owns feedback; never stack a second grey ink overlay.
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      side: WidgetStateProperty.resolveWith(
        (states) =>
            !states.contains(WidgetState.disabled) &&
                states.contains(WidgetState.focused)
            ? BorderSide(color: t.focus, width: 2)
            : BorderSide.none,
      ),
      elevation: const WidgetStatePropertyAll(0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      animationDuration: const Duration(milliseconds: 100),
    );
  }
}
