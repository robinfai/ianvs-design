import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/tokens.dart';
import 'button.dart';

/// A controlled integer input, inspired by the TDesign stepper interaction.
/// Enter/blur commits a bounded draft; Escape restores [value]. Parents must
/// accept a request by rebuilding with the new value. Arrow keys also step.
class IanvsNumberStepper extends StatefulWidget {
  const IanvsNumberStepper({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.increaseLabel = '增加',
    this.decreaseLabel = '减少',
  }) : assert(min <= max),
       assert(value >= min && value <= max),
       assert(step > 0);
  final int value, min, max, step;
  final String label, increaseLabel, decreaseLabel;
  final ValueChanged<int>? onChanged;
  @override
  State<IanvsNumberStepper> createState() => _IanvsNumberStepperState();
}

class _IanvsNumberStepperState extends State<IanvsNumberStepper> {
  late final TextEditingController _text;
  final _focus = FocusNode();
  bool _editing = false;
  bool get _enabled => widget.onChanged != null;
  int get _draft => int.tryParse(_text.text) ?? widget.value;
  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: '${widget.value}');
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(covariant IanvsNumberStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.onChanged != widget.onChanged && !_enabled) {
      _restore();
    }
  }

  void _onFocus() {
    if (!_focus.hasFocus && _editing) _commit();
  }

  void _restore() {
    _editing = false;
    _text.value = TextEditingValue(
      text: '${widget.value}',
      selection: TextSelection.collapsed(offset: '${widget.value}'.length),
    );
  }

  void _request(int requested) {
    if (!_enabled) return;
    _editing = false;
    final bounded = requested.clamp(widget.min, widget.max);
    if (bounded != widget.value) widget.onChanged!(bounded);
    setState(() {});
    // Restore a rejected request as well as an accepted, parent-owned value.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_editing) setState(_restore);
    });
  }

  void _commit() {
    final parsed = int.tryParse(_text.text);
    if (parsed == null) {
      setState(_restore);
    } else {
      _request(parsed);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ianvs;
    final iconStyle = IconButton.styleFrom(
      backgroundColor: t.field,
      side: BorderSide(color: t.border),
    );
    final down = _enabled && _draft > widget.min;
    final up = _enabled && _draft < widget.max;
    final digits = [
      widget.min.toString().length,
      widget.max.toString().length,
    ].reduce((a, b) => a > b ? a : b);
    final fieldWidth = (MediaQuery.textScalerOf(context).scale(9) * digits + 24)
        .clamp(48.0, 200.0);
    final buttonWidth = t.isCompactTouch
        ? kMinInteractiveDimension
        : t.controlHeight;
    return SizedBox(
      width: buttonWidth * 2 + fieldWidth + 8,
      child: TextFieldTapRegion(
        child: Row(
          children: [
            IanvsIconButton(
              style: iconStyle,
              icon: Icons.remove,
              tooltip: '${widget.decreaseLabel} ${widget.label}',
              onPressed: down ? () => _request(_draft - widget.step) : null,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: CallbackShortcuts(
                bindings: {
                  const SingleActivator(LogicalKeyboardKey.arrowUp): () {
                    if (up) _request(_draft + widget.step);
                  },
                  const SingleActivator(LogicalKeyboardKey.arrowDown): () {
                    if (down) _request(_draft - widget.step);
                  },
                  const SingleActivator(LogicalKeyboardKey.escape): () =>
                      setState(_restore),
                },
                child: Semantics(
                  label: widget.label,
                  child: TextField(
                    controller: _text,
                    focusNode: _focus,
                    enabled: _enabled,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                    ),
                    inputFormatters: [
                      TextInputFormatter.withFunction(
                        (old, next) =>
                            RegExp(r'^-?\d*$').hasMatch(next.text) ? next : old,
                      ),
                    ],
                    onChanged: (_) => setState(() => _editing = true),
                    onSubmitted: (_) {
                      _commit();
                      _focus.unfocus();
                    },
                    onTapOutside: (_) {
                      _commit();
                      _focus.unfocus();
                    },
                    decoration: InputDecoration(
                      constraints: t.isCompactTouch
                          ? const BoxConstraints(minHeight: 44)
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 6,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IanvsIconButton(
              style: iconStyle,
              icon: Icons.add,
              tooltip: '${widget.increaseLabel} ${widget.label}',
              onPressed: up ? () => _request(_draft + widget.step) : null,
            ),
          ],
        ),
      ),
    );
  }
}
