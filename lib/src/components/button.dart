import 'dart:async';
import 'package:flutter/material.dart';
import '../foundation/theme.dart';
import '../foundation/tokens.dart';

enum IanvsButtonVariant { primary, tonal, elevated, secondary, ghost, danger }

/// A themed action with automatic async busy state and duplicate-click protection.
class IanvsButton extends StatefulWidget {
  const IanvsButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = IanvsButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.focusNode,
    this.autofocus = false,
    this.tooltip,
    this.style,
    this.onError,
    this.loadingLabel = '正在处理',
  });
  final Widget child;
  final FutureOr<void> Function()? onPressed;
  final IanvsButtonVariant variant;
  final IconData? icon;
  final bool loading;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? tooltip;
  final ButtonStyle? style;
  final void Function(Object error, StackTrace stackTrace)? onError;
  final String loadingLabel;
  @override
  State<IanvsButton> createState() => _IanvsButtonState();
}

class _IanvsButtonState extends State<IanvsButton> {
  bool _pending = false;
  bool get _busy => _pending || widget.loading;
  Future<void> _activate() async {
    if (_busy || widget.onPressed == null) return;
    setState(() => _pending = true);
    try {
      await widget.onPressed!();
    } catch (error, stack) {
      if (widget.onError != null) {
        widget.onError!(error, stack);
      } else {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stack,
            library: 'ianvs_design',
            context: ErrorDescription('while performing an IanvsButton action'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _pending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ianvs;
    final onPressed = _busy || widget.onPressed == null ? null : _activate;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_busy) ...[
          const ExcludeSemantics(
            child: SizedBox.square(
              dimension: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          ExcludeSemantics(child: Icon(widget.icon, size: 16)),
          const SizedBox(width: 8),
        ],
        Flexible(child: widget.child),
      ],
    );
    final dangerStyle = FilledButton.styleFrom(
      backgroundColor: t.danger,
      foregroundColor: IanvsTheme.foregroundFor(t.danger),
    );
    Widget button = switch (widget.variant) {
      IanvsButtonVariant.primary || IanvsButtonVariant.danger => FilledButton(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onPressed: onPressed,
        style: widget.variant == IanvsButtonVariant.danger
            ? dangerStyle.merge(widget.style)
            : widget.style,
        child: content,
      ),
      IanvsButtonVariant.tonal => FilledButton.tonal(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onPressed: onPressed,
        style: widget.style,
        child: content,
      ),
      IanvsButtonVariant.elevated => ElevatedButton(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onPressed: onPressed,
        style: widget.style,
        child: content,
      ),
      IanvsButtonVariant.secondary => OutlinedButton(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onPressed: onPressed,
        style: widget.style,
        child: content,
      ),
      IanvsButtonVariant.ghost => TextButton(
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onPressed: onPressed,
        style: widget.style,
        child: content,
      ),
    };
    button = Semantics(
      liveRegion: _busy,
      value: _busy ? widget.loadingLabel : null,
      child: button,
    );
    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    return button;
  }
}

/// Icon-only controls always require an accessible tooltip.
class IanvsIconButton extends StatelessWidget {
  const IanvsIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.focusNode,
    this.selected = false,
    this.style,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final FocusNode? focusNode;
  final bool selected;
  final ButtonStyle? style;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    excludeFromSemantics: true,
    child: MergeSemantics(
      child: Semantics(
        label: tooltip,
        child: IconButton(
          icon: Icon(icon),
          onPressed: onPressed,
          focusNode: focusNode,
          isSelected: selected,
          style: style,
        ),
      ),
    ),
  );
}
