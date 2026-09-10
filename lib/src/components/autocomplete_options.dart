import 'package:flutter/material.dart';
import '../foundation/tokens.dart';
import '../foundation/menu_style.dart';

/// A compact options panel for Material [Autocomplete.optionsViewBuilder].
/// Autocomplete retains ownership of filtering, focus and keyboard selection.
class IanvsAutocompleteOptions<T extends Object> extends StatefulWidget {
  const IanvsAutocompleteOptions({
    super.key,
    required this.options,
    required this.onSelected,
    this.displayStringForOption = RawAutocomplete.defaultStringForOption,
    this.maxWidth = 360,
    this.maxHeight = 280,
  });

  final Iterable<T> options;
  final AutocompleteOnSelected<T> onSelected;
  final AutocompleteOptionToString<T> displayStringForOption;
  final double maxWidth, maxHeight;

  @override
  State<IanvsAutocompleteOptions<T>> createState() => _OptionsState<T>();
}

class _OptionsState<T extends Object>
    extends State<IanvsAutocompleteOptions<T>> {
  final _scroll = ScrollController();
  final _keys = <T, GlobalKey>{};
  int _highlight = -1;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ianvs;
    final options = widget.options.toList();
    _keys.removeWhere((option, _) => !options.contains(option));
    final highlighted = AutocompleteHighlightedOption.of(context);
    if (_highlight != highlighted) {
      _highlight = highlighted;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || highlighted >= options.length) return;
        final target = _keys[options[highlighted]]?.currentContext;
        if (target != null) {
          Scrollable.ensureVisible(target, alignment: .5);
        }
      });
    }
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: widget.maxWidth,
            maxHeight: widget.maxHeight,
          ),
          child: Material(
            color: t.raised,
            elevation: 4,
            surfaceTintColor: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(t.controlRadius),
              side: BorderSide(color: t.border),
            ),
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(4),
              shrinkWrap: true,
              children: [
                for (var index = 0; index < options.length; index++)
                  Semantics(
                    key: _keys.putIfAbsent(options[index], GlobalKey.new),
                    selected: index == highlighted,
                    child: ExcludeFocus(
                      child: MenuItemButton(
                        requestFocusOnHover: false,
                        closeOnActivate: false,
                        style: IanvsMenuStyle.item(
                          t,
                          selected: index == highlighted,
                        ),
                        onPressed: () => widget.onSelected(options[index]),
                        child: Text(
                          widget.displayStringForOption(options[index]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
