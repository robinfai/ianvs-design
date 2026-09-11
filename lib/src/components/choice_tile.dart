import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../foundation/tokens.dart';

/// A whole-row radio choice with a trailing check and neutral state feedback.
///
/// Place under a [RadioGroup] with the same value type. The group owns selection,
/// keyboard navigation and mutual exclusion. Values must be unique in the group.
/// [title] and [subtitle] are merged into one radio semantics node and should not
/// contain independent interactive controls. Long text wraps without a line cap.
class IanvsChoiceTile<T> extends StatefulWidget {
  const IanvsChoiceTile({
    super.key,
    required this.value,
    required this.title,
    this.subtitle,
    this.enabled = true,
    this.focusNode,
    this.autofocus = false,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 4,
    ),
  });

  final T value;
  final Widget title;
  final Widget? subtitle;
  final bool enabled;
  final FocusNode? focusNode;
  final bool autofocus;
  final EdgeInsetsGeometry contentPadding;

  @override
  State<IanvsChoiceTile<T>> createState() => _IanvsChoiceTileState<T>();
}

class _IanvsChoiceTileState<T> extends State<IanvsChoiceTile<T>> {
  FocusNode? _ownedFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownedFocus ??= FocusNode());

  @override
  void dispose() {
    _ownedFocus?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = RadioGroup.maybeOf<T>(context);
    assert(
      group != null,
      'IanvsChoiceTile<$T> requires a RadioGroup<$T> ancestor.',
    );
    final enabled = widget.enabled && group != null;
    final theme = Theme.of(context);
    final t = context.ianvs;
    return MergeSemantics(
      child: RawRadio<T>(
        value: widget.value,
        groupRegistry: group,
        enabled: enabled,
        toggleable: false,
        focusNode: _focus,
        autofocus: widget.autofocus,
        mouseCursor: WidgetStateMouseCursor.clickable,
        builder: (context, state) {
          final selected = state.value == true;
          final focused = enabled && state.states.contains(WidgetState.focused);
          final hovered = enabled && state.states.contains(WidgetState.hovered);
          final pressed = enabled && state.downPosition != null;
          return AnimatedContainer(
            duration: IanvsMotion.resolve(context),
            constraints: BoxConstraints(
              minWidth: 44,
              minHeight: t.density == IanvsDensity.touch
                  ? math.max(44, t.rowHeight)
                  : t.controlHeight,
            ),
            padding: widget.contentPadding,
            decoration: BoxDecoration(
              color: pressed
                  ? t.text.withValues(alpha: .10)
                  : hovered
                  ? t.text.withValues(alpha: .05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(t.controlRadius),
              border: Border.all(
                color: focused ? t.focus : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: enabled ? t.text : t.subtle,
                        ),
                        softWrap: true,
                        child: widget.title,
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        DefaultTextStyle(
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: enabled ? t.muted : t.subtle,
                          ),
                          softWrap: true,
                          child: widget.subtitle!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ExcludeSemantics(
                  child: SizedBox.square(
                    dimension: 20,
                    child: selected
                        ? Icon(
                            Icons.check,
                            size: 18,
                            color: enabled ? t.focus : t.subtle,
                          )
                        : null,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
