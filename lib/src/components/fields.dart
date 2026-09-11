import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/tokens.dart';
import '../foundation/menu_style.dart';

/// TextFormField with shared decoration, supporting normal Flutter form contracts.
class IanvsTextField extends StatelessWidget {
  const IanvsTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onFieldSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.decoration,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.autofillHints,
    this.style,
    this.maxLength,
  }) : assert(controller == null || initialValue == null);
  final TextEditingController? controller;
  final String? initialValue, labelText, hintText, helperText, errorText;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged, onFieldSubmitted;
  final bool enabled, readOnly, obscureText, autofocus;
  final int? maxLines, minLines, maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon, suffixIcon;
  final InputDecoration? decoration;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;
  final Iterable<String>? autofillHints;
  final TextStyle? style;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    initialValue: initialValue,
    focusNode: focusNode,
    validator: validator,
    onSaved: onSaved,
    onChanged: onChanged,
    onFieldSubmitted: onFieldSubmitted,
    enabled: enabled,
    readOnly: readOnly,
    obscureText: obscureText,
    autofocus: autofocus,
    maxLines: maxLines,
    minLines: minLines,
    maxLength: maxLength,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    inputFormatters: inputFormatters,
    autovalidateMode: autovalidateMode,
    autofillHints: autofillHints,
    style:
        style ??
        Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: enabled ? context.ianvs.text : context.ianvs.subtle,
        ),
    decoration: (decoration ?? const InputDecoration()).copyWith(
      constraints:
          decoration?.constraints ??
          Theme.of(context).inputDecorationTheme.constraints ??
          BoxConstraints(minHeight: context.ianvs.controlHeight),
      labelText: labelText ?? decoration?.labelText,
      hintText: hintText ?? decoration?.hintText,
      helperText: helperText ?? decoration?.helperText,
      errorText: errorText ?? decoration?.errorText,
      prefixIcon: prefixIcon ?? decoration?.prefixIcon,
      suffixIcon: suffixIcon ?? decoration?.suffixIcon,
    ),
  );
}

/// Select options preserve typed values and disabled-item behavior.
@immutable
class IanvsOption<T> {
  const IanvsOption(this.value, this.label, {this.enabled = true});
  final T value;
  final String label;
  final bool enabled;
}

/// A typed select with validation, reset/save, keyboard menu and value sync.
/// [value] updates from the parent are respected; user changes call [onChanged].
class IanvsSelect<T> extends FormField<T> {
  IanvsSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    bool enabled = true,
    super.onReset,
  }) : super(
         initialValue: value,
         enabled: enabled && onChanged != null,
         builder: (state) => (state as _IanvsSelectState<T>)._build(),
       );
  final List<IanvsOption<T>> options;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final FocusNode? focusNode;
  final String? labelText, hintText, helperText;
  @override
  FormFieldState<T> createState() => _IanvsSelectState<T>();
}

class _IanvsSelectState<T> extends FormFieldState<T> {
  IanvsSelect<T> get config => widget as IanvsSelect<T>;
  bool _focused = false;
  bool _hovered = false;
  @override
  void didUpdateWidget(covariant IanvsSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != config.value) setValue(config.value);
  }

  @override
  void reset() {
    super.reset();
    config.onChanged?.call(value);
  }

  final MenuController _menu = MenuController();
  FocusNode? _ownedFocus;
  FocusNode get _focus => config.focusNode ?? (_ownedFocus ??= FocusNode());

  @override
  void dispose() {
    _ownedFocus?.dispose();
    super.dispose();
  }

  Widget _build() {
    final t = context.ianvs;
    final selected = config.options
        .where((item) => item.value == value)
        .firstOrNull;
    final firstEnabled = config.options
        .where((item) => item.enabled)
        .firstOrNull;
    void toggle() => _menu.isOpen ? _menu.close() : _menu.open();
    return LayoutBuilder(
      builder: (context, constraints) => MenuAnchor(
        controller: _menu,
        childFocusNode: _focus,
        consumeOutsideTap: true,
        crossAxisUnconstrained: false,
        style: MenuStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(constraints.maxWidth.clamp(0, 360), 0),
          ),
          maximumSize: WidgetStatePropertyAll(
            Size(constraints.maxWidth.clamp(0, 360), 320),
          ),
          alignment: AlignmentDirectional.bottomStart,
        ),
        alignmentOffset: const Offset(0, 4),
        menuChildren: config.options.map((option) {
          final isSelected = option.value == value;
          return MenuItemButton(
            autofocus:
                option.enabled &&
                (selected?.enabled == true
                    ? isSelected
                    : identical(option, firstEnabled)),
            onPressed: !widget.enabled || !option.enabled
                ? null
                : () {
                    didChange(option.value);
                    config.onChanged?.call(option.value);
                  },
            style: IanvsMenuStyle.item(t, selected: isSelected),
            leadingIcon: isSelected
                ? const Icon(Icons.check, size: 16)
                : const SizedBox(width: 16),
            child: Text(option.label),
          );
        }).toList(),
        builder: (context, controller, child) => CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowDown): () {
              if (widget.enabled) _menu.open();
            },
          },
          child: Semantics(
            button: true,
            enabled: widget.enabled,
            child: InkWell(
              focusNode: _focus,
              onFocusChange: (focused) => setState(() => _focused = focused),
              onHover: (hovered) => setState(() => _hovered = hovered),
              // InputDecorator paints hover within its outline. Ink painted on
              // the ancestor Material leaks below the field and behind helpers.
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              onTap: widget.enabled ? toggle : null,
              borderRadius: BorderRadius.circular(t.controlRadius),
              child: InputDecorator(
                isFocused: _focused,
                isHovering: widget.enabled && _hovered,
                isEmpty: value == null,
                decoration: InputDecoration(
                  constraints:
                      Theme.of(context).inputDecorationTheme.constraints ??
                      BoxConstraints(minHeight: t.controlHeight),
                  labelText: config.labelText,
                  helperText: config.helperText,
                  errorText: errorText,
                  enabled: widget.enabled,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected?.label ?? config.hintText ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: !widget.enabled || selected == null
                              ? t.subtle
                              : t.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_drop_down,
                      color: widget.enabled ? t.muted : t.subtle,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
