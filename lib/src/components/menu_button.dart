import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/menu_style.dart';
import '../foundation/tokens.dart';
import 'fields.dart';

/// A compact action/choice menu. Uses Material's focus, dismissal and traversal.
/// Supply either [child] for a field-style trigger or [icon] for an icon button.
class IanvsMenuButton<T> extends StatefulWidget {
  const IanvsMenuButton({
    super.key,
    required this.options,
    required this.onSelected,
    required this.tooltip,
    this.value,
    this.child,
    this.icon,
  }) : assert((child == null) != (icon == null));

  final List<IanvsOption<T>> options;
  final ValueChanged<T>? onSelected;
  final T? value;
  final String tooltip;
  final Widget? child, icon;

  @override
  State<IanvsMenuButton<T>> createState() => _IanvsMenuButtonState<T>();
}

class _IanvsMenuButtonState<T> extends State<IanvsMenuButton<T>> {
  final _focus = FocusNode();
  final _menu = MenuController();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ianvs;
    final selected = widget.options
        .where((o) => o.value == widget.value)
        .firstOrNull;
    final first = widget.options.where((o) => o.enabled).firstOrNull;
    void toggle() => _menu.isOpen ? _menu.close() : _menu.open();
    return MenuAnchor(
      controller: _menu,
      childFocusNode: _focus,
      consumeOutsideTap: true,
      crossAxisUnconstrained: false,
      alignmentOffset: const Offset(0, 4),
      style: const MenuStyle(
        alignment: AlignmentDirectional.bottomStart,
        minimumSize: WidgetStatePropertyAll(Size(160, 0)),
        maximumSize: WidgetStatePropertyAll(Size(360, 320)),
      ),
      menuChildren: [
        for (final option in widget.options)
          MenuItemButton(
            autofocus:
                option.enabled &&
                (selected?.enabled == true
                    ? option == selected
                    : option == first),
            style: IanvsMenuStyle.item(t, selected: option == selected),
            leadingIcon: widget.value == null
                ? null
                : option == selected
                ? const Icon(Icons.check)
                : const SizedBox(width: 16),
            onPressed: !option.enabled || widget.onSelected == null
                ? null
                : () => widget.onSelected!(option.value),
            child: Text(option.label),
          ),
      ],
      builder: (context, controller, child) => CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowDown): () {
            if (widget.onSelected != null) _menu.open();
          },
        },
        child: widget.icon != null
            ? IconButton(
                tooltip: widget.tooltip,
                focusNode: _focus,
                onPressed: widget.onSelected == null ? null : toggle,
                icon: widget.icon!,
              )
            : Tooltip(
                message: widget.tooltip,
                child: OutlinedButton(
                  focusNode: _focus,
                  onPressed: widget.onSelected == null ? null : toggle,
                  style: OutlinedButton.styleFrom(backgroundColor: t.field),
                  child: widget.child,
                ),
              ),
      ),
    );
  }
}
