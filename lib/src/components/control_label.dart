import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A selectable label linked to a native choice control.
///
/// Give [controlBuilder]'s focus node to the control. [onTap] must perform the
/// same state change as that control, or be null when the control is disabled.
/// A label click waits for the double-click window; selecting text never acts.
class IanvsControlLabel extends StatefulWidget {
  const IanvsControlLabel({
    super.key,
    required this.label,
    required this.controlBuilder,
    required this.onTap,
    this.description,
    this.trailing = false,
  });

  final String label;
  final String? description;
  final Widget Function(FocusNode focusNode) controlBuilder;
  final VoidCallback? onTap;
  final bool trailing;

  @override
  State<IanvsControlLabel> createState() => _IanvsControlLabelState();
}

class _IanvsControlLabelState extends State<IanvsControlLabel> {
  final _controlFocus = FocusNode();
  final _labelFocus = FocusNode(skipTraversal: true);
  TextSelection _selection = const TextSelection.collapsed(offset: -1);
  Timer? _pendingTap;

  void _cancelTap() {
    _pendingTap?.cancel();
    _pendingTap = null;
  }

  void _tapLabel() {
    _cancelTap();
    if (widget.onTap == null || !_selection.isCollapsed) return;
    // SelectableText recognizes the first click before a possible double-click.
    // Wait so double-click selection can cancel the action without side effects.
    _pendingTap = Timer(kDoubleTapTimeout, () {
      _pendingTap = null;
      if (!mounted || widget.onTap == null || !_selection.isCollapsed) return;
      _controlFocus.requestFocus();
      widget.onTap!();
    });
  }

  @override
  void didUpdateWidget(covariant IanvsControlLabel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.onTap == null ||
        widget.label != oldWidget.label ||
        widget.description != oldWidget.description) {
      _cancelTap();
    }
  }

  @override
  void dispose() {
    _cancelTap();
    _controlFocus.dispose();
    _labelFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabledColor = widget.onTap == null ? theme.disabledColor : null;
    final label = Semantics(
      label: [widget.label, ?widget.description].join('\n'),
      // Keep one native checkbox/radio/switch semantics node. The selectable
      // label must not add a second, read-only text-field accessibility target.
      child: ExcludeSemantics(
        child: Listener(
          onPointerDown: (_) => _cancelTap(),
          child: SelectableText.rich(
            TextSpan(
              children: [
                TextSpan(text: widget.label),
                if (widget.description != null)
                  TextSpan(
                    text: '\n${widget.description}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: disabledColor,
                    ),
                  ),
              ],
            ),
            style: TextStyle(color: disabledColor),
            focusNode: _labelFocus,
            onTap: _tapLabel,
            onSelectionChanged: (selection, cause) {
              _selection = selection;
              if (!selection.isCollapsed) _cancelTap();
            },
          ),
        ),
      ),
    );
    final control = Listener(
      onPointerDown: (_) => _cancelTap(),
      child: widget.controlBuilder(_controlFocus),
    );
    return MergeSemantics(
      child: Row(
        mainAxisSize: widget.trailing ? MainAxisSize.max : MainAxisSize.min,
        children: widget.trailing
            ? [Expanded(child: label), const SizedBox(width: 16), control]
            : [control, const SizedBox(width: 8), Flexible(child: label)],
      ),
    );
  }
}
