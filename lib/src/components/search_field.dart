import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/menu_style.dart';
import '../foundation/tokens.dart';
import 'fields.dart';

/// An in-place desktop search bar with an anchored suggestions menu.
/// The field never changes position, width or icon when suggestions open.
class IanvsSearchField<T> extends StatefulWidget {
  const IanvsSearchField({
    super.key,
    required this.options,
    required this.onSelected,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.hintText = '搜索',
    this.emptyText = '没有匹配结果',
    this.optionIcon,
    this.enabled = true,
    this.maxMenuWidth = 360,
  }) : assert(maxMenuWidth > 0);

  final List<IanvsOption<T>> options;
  final ValueChanged<T> onSelected;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged, onSubmitted;
  final String hintText, emptyText;
  final IconData? optionIcon;
  final bool enabled;
  final double maxMenuWidth;

  @override
  State<IanvsSearchField<T>> createState() => _IanvsSearchFieldState<T>();
}

class _IanvsSearchFieldState<T> extends State<IanvsSearchField<T>> {
  final _menu = MenuController();
  late TextEditingController _text;
  late FocusNode _focus;
  late String _lastText;
  bool _selecting = false;
  int _highlight = 0;
  final _rowKeys = <T, GlobalKey>{};

  List<IanvsOption<T>> get _matches {
    final query = _text.text.trim().toLowerCase();
    return widget.options
        .where((o) => o.label.toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _text = widget.controller ?? TextEditingController();
    _lastText = _text.text;
    _text.addListener(_textChanged);
    _focus = widget.focusNode ?? FocusNode();
    _focus.addListener(_focusChanged);
  }

  @override
  void didUpdateWidget(covariant IanvsSearchField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _text.removeListener(_textChanged);
      if (oldWidget.controller == null) _text.dispose();
      _text = widget.controller ?? TextEditingController();
      _lastText = _text.text;
      _text.addListener(_textChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focus.removeListener(_focusChanged);
      if (oldWidget.focusNode == null) _focus.dispose();
      _focus = widget.focusNode ?? FocusNode();
      _focus.addListener(_focusChanged);
    }
    if (!widget.enabled) _menu.close();
  }

  void _focusChanged() {
    // MenuAnchor may restore the field's focus while dismissing. Opening from
    // that notification would immediately reopen a menu closed by an outside tap.
    // Click, typing and Down explicitly open suggestions instead.
    if (!_focus.hasFocus) _menu.close();
  }

  void _textChanged() {
    // Cursor and selection changes must not reopen a dismissed menu.
    if (_lastText == _text.text) return;
    _lastText = _text.text;
    setState(() => _highlight = _matches.indexWhere((o) => o.enabled));
    if (!_selecting && _focus.hasFocus) _open();
  }

  void _open() {
    if (!widget.enabled) return;
    if (!_menu.isOpen) {
      setState(() => _highlight = _matches.indexWhere((o) => o.enabled));
      _menu.open();
    }
  }

  void _move(int step) {
    if (!widget.enabled) return;
    if (!_menu.isOpen) {
      _open();
      return;
    }
    final matches = _matches;
    var next = _highlight + step;
    while (next >= 0 && next < matches.length && !matches[next].enabled) {
      next += step;
    }
    if (next < 0 || next >= matches.length) return;
    setState(() => _highlight = next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final row = _rowKeys[matches[next].value]?.currentContext;
      if (row != null) Scrollable.ensureVisible(row, alignment: .5);
    });
  }

  void _select(IanvsOption<T> option) {
    if (!widget.enabled || !option.enabled) return;
    _selecting = true;
    _text.value = TextEditingValue(
      text: option.label,
      selection: TextSelection.collapsed(offset: option.label.length),
    );
    _selecting = false;
    _menu.close();
    widget.onSelected(option.value);
  }

  void _submit(String query) {
    final matches = _matches;
    if (_menu.isOpen && _highlight >= 0 && _highlight < matches.length) {
      _select(matches[_highlight]);
    } else {
      _menu.close();
      widget.onSubmitted?.call(query);
    }
  }

  @override
  void dispose() {
    _text.removeListener(_textChanged);
    _focus.removeListener(_focusChanged);
    if (widget.controller == null) _text.dispose();
    if (widget.focusNode == null) _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ianvs;
    final matches = _matches;
    _rowKeys.removeWhere(
      (value, _) => !widget.options.any((o) => o.value == value),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.clamp(0.0, widget.maxMenuWidth);
        return TextFieldTapRegion(
          child: MenuAnchor(
            controller: _menu,
            childFocusNode: _focus,
            crossAxisUnconstrained: false,
            alignmentOffset: const Offset(0, 4),
            style: MenuStyle(
              alignment: AlignmentDirectional.bottomStart,
              minimumSize: WidgetStatePropertyAll(Size(width, 0)),
              maximumSize: WidgetStatePropertyAll(Size(width, 280)),
            ),
            menuChildren: [
              if (matches.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      widget.emptyText,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: t.muted),
                    ),
                  ),
                ),
              for (var i = 0; i < matches.length; i++)
                TextFieldTapRegion(
                  child: ExcludeFocus(
                    child: Semantics(
                      selected: i == _highlight,
                      child: MenuItemButton(
                        key: _rowKeys.putIfAbsent(
                          matches[i].value,
                          GlobalKey.new,
                        ),
                        closeOnActivate: false,
                        requestFocusOnHover: false,
                        style: IanvsMenuStyle.item(
                          t,
                          selected: i == _highlight,
                        ),
                        leadingIcon: widget.optionIcon == null
                            ? null
                            : Icon(widget.optionIcon),
                        onPressed: matches[i].enabled
                            ? () => _select(matches[i])
                            : null,
                        child: Text(matches[i].label),
                      ),
                    ),
                  ),
                ),
            ],
            builder: (context, controller, child) => CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                    _move(1),
                const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                    _move(-1),
                const SingleActivator(LogicalKeyboardKey.escape): _menu.close,
              },
              child: SearchBar(
                controller: _text,
                focusNode: _focus,
                enabled: widget.enabled,
                hintText: widget.hintText,
                leading: const Icon(Icons.search, size: 18),
                onTap: _open,
                onChanged: widget.onChanged,
                onSubmitted: _submit,
                side: WidgetStateProperty.resolveWith(
                  (states) => BorderSide(
                    color: states.contains(WidgetState.focused)
                        ? t.focus
                        : t.border,
                    width: states.contains(WidgetState.focused) ? 2 : 1,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
