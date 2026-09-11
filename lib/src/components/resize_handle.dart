import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/tokens.dart';

/// A controlled divider for resizing a host-owned panel.
///
/// [axis] describes the dimension being changed: horizontal resizes width,
/// vertical resizes height. Set [reverse] for a panel to the right or below the
/// handle. These are physical directions, independent of text direction.
/// The parent must apply [onChanged] values and provide bounded cross-axis space
/// (for example, a finite-height Row for a horizontal handle).
class IanvsResizeHandle extends StatefulWidget {
  const IanvsResizeHandle({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.semanticLabel,
    this.axis = Axis.horizontal,
    this.reverse = false,
    this.step = 20,
    this.resetValue,
    this.focusNode,
    this.hitExtent = 8,
    this.semanticValueFormatter,
  }) : assert(value > double.negativeInfinity && value < double.infinity),
       assert(min >= 0 && min < double.infinity),
       assert(max >= min && max < double.infinity),
       assert(step > 0 && step < double.infinity),
       assert(hitExtent > 0 && hitExtent < double.infinity),
       assert(
         resetValue == null ||
             (resetValue > double.negativeInfinity &&
                 resetValue < double.infinity),
       );

  final double value, min, max, step, hitExtent;
  final double? resetValue;
  final ValueChanged<double>? onChanged;
  final String semanticLabel;
  final String Function(double)? semanticValueFormatter;
  final Axis axis;
  final bool reverse;
  final FocusNode? focusNode;

  @override
  State<IanvsResizeHandle> createState() => _IanvsResizeHandleState();
}

class _IanvsResizeHandleState extends State<IanvsResizeHandle> {
  FocusNode? _ownedFocus;
  FocusNode get _focus => widget.focusNode ?? (_ownedFocus ??= FocusNode());
  bool _focused = false, _hovered = false, _focusFromPointer = false;
  double? _dragValue, _lastRequested;
  bool get _enabled => widget.onChanged != null && widget.min < widget.max;
  double get _value => widget.value.clamp(widget.min, widget.max);
  double get _sign => widget.reverse ? -1 : 1;

  @override
  void didUpdateWidget(covariant IanvsResizeHandle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_enabled ||
        widget.axis != oldWidget.axis ||
        widget.reverse != oldWidget.reverse) {
      _dragValue = null;
    } else if (widget.min != oldWidget.min ||
        widget.max != oldWidget.max ||
        (widget.value != oldWidget.value && widget.value != _lastRequested)) {
      // Respect host corrections during a gesture, including changed bounds.
      if (_dragValue != null) _dragValue = _value;
    }
  }

  @override
  void dispose() {
    _ownedFocus?.dispose();
    super.dispose();
  }

  void _request(double value) {
    if (!_enabled) return;
    final bounded = value.clamp(widget.min, widget.max);
    _lastRequested = bounded;
    if (bounded != _value) widget.onChanged!(bounded);
  }

  void _reset() {
    _focus.requestFocus();
    _request(widget.resetValue!);
  }

  void _start(DragStartDetails details) {
    _focus.requestFocus();
    setState(() => _dragValue = _value);
  }

  void _end() {
    if (_dragValue != null) setState(() => _dragValue = null);
  }

  void _drag(DragUpdateDetails details) {
    if (_dragValue == null) return;
    final delta = widget.axis == Axis.horizontal
        ? details.delta.dx
        : details.delta.dy;
    _dragValue = (_dragValue! + delta * _sign).clamp(widget.min, widget.max);
    _request(_dragValue!);
  }

  KeyEventResult _key(FocusNode node, KeyEvent event) {
    if (!_enabled || event is KeyUpEvent) return KeyEventResult.ignored;
    if (_focusFromPointer) setState(() => _focusFromPointer = false);
    // Leave application shortcuts that use modifiers to the host.
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isControlPressed ||
        keyboard.isMetaPressed ||
        keyboard.isAltPressed ||
        keyboard.isShiftPressed) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final forward = widget.axis == Axis.horizontal
        ? LogicalKeyboardKey.arrowRight
        : LogicalKeyboardKey.arrowDown;
    final backward = widget.axis == Axis.horizontal
        ? LogicalKeyboardKey.arrowLeft
        : LogicalKeyboardKey.arrowUp;
    if (key == forward || key == backward) {
      _request(_value + (key == forward ? 1 : -1) * _sign * widget.step);
    } else if (key == LogicalKeyboardKey.home) {
      _request(widget.min);
    } else if (key == LogicalKeyboardKey.end) {
      _request(widget.max);
    } else if ((key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter) &&
        widget.resetValue != null) {
      _reset();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  String _format(double value) =>
      widget.semanticValueFormatter?.call(value) ?? '${value.round()} px';

  @override
  Widget build(BuildContext context) {
    final t = context.ianvs;
    final horizontal = widget.axis == Axis.horizontal;
    final increase = (_value + widget.step).clamp(widget.min, widget.max);
    final decrease = (_value - widget.step).clamp(widget.min, widget.max);
    final highlighted =
        _enabled && (_dragValue != null || (_focused && !_focusFromPointer));
    final color = highlighted
        ? t.focus
        : _enabled && _hovered
        ? t.border
        : t.separator;
    return Semantics(
      container: true,
      slider: true,
      enabled: _enabled,
      label: widget.semanticLabel,
      value: _format(_value),
      increasedValue: _enabled && increase > _value ? _format(increase) : null,
      decreasedValue: _enabled && decrease < _value ? _format(decrease) : null,
      onIncrease: _enabled && increase > _value
          ? () => _request(increase)
          : null,
      onDecrease: _enabled && decrease < _value
          ? () => _request(decrease)
          : null,
      child: Focus(
        focusNode: _focus,
        canRequestFocus: _enabled,
        onFocusChange: (value) => setState(() {
          _focused = value;
          if (!value) _focusFromPointer = false;
        }),
        onKeyEvent: _key,
        child: MouseRegion(
          cursor: !_enabled
              ? SystemMouseCursors.basic
              : horizontal
              ? SystemMouseCursors.resizeColumn
              : SystemMouseCursors.resizeRow,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: Listener(
            // Desktop mouse events leave Flutter's focus highlight mode in
            // traditional mode. Track pointer focus locally, without removing
            // the actual focus needed by keyboard and accessibility actions.
            onPointerDown: _enabled
                ? (_) => setState(() => _focusFromPointer = true)
                : null,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTap: _enabled ? () => _focus.requestFocus() : null,
              onDoubleTap: _enabled && widget.resetValue != null
                  ? _reset
                  : null,
              onHorizontalDragStart: _enabled && horizontal ? _start : null,
              onHorizontalDragUpdate: _enabled && horizontal ? _drag : null,
              onHorizontalDragEnd: _enabled && horizontal
                  ? (_) => _end()
                  : null,
              onHorizontalDragCancel: _enabled && horizontal ? _end : null,
              onVerticalDragStart: _enabled && !horizontal ? _start : null,
              onVerticalDragUpdate: _enabled && !horizontal ? _drag : null,
              onVerticalDragEnd: _enabled && !horizontal ? (_) => _end() : null,
              onVerticalDragCancel: _enabled && !horizontal ? _end : null,
              child: SizedBox(
                width: horizontal ? widget.hitExtent : double.infinity,
                height: horizontal ? double.infinity : widget.hitExtent,
                child: Center(
                  child: ColoredBox(
                    color: color,
                    child: SizedBox(
                      width: horizontal
                          ? (highlighted ? 2 : 1)
                          : double.infinity,
                      height: horizontal
                          ? double.infinity
                          : (highlighted ? 2 : 1),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
