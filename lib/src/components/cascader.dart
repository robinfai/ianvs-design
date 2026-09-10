import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/tokens.dart';

/// Immutable tree data. Values must be unique among siblings.
@immutable
class IanvsCascadeOption<T> {
  const IanvsCascadeOption({
    required this.value,
    required this.label,
    this.children = const [],
    this.enabled = true,
  });
  final T value;
  final String label;
  final List<IanvsCascadeOption<T>> children;
  final bool enabled;
}

/// Controlled, inline hierarchical selection. Branches emit partial paths;
/// changing a parent drops its descendants. Breadcrumb navigation does not
/// change the value. Place in a dialog when a transactional picker is needed.
class IanvsCascader<T> extends StatefulWidget {
  const IanvsCascader({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.rootLabel = '全部',
    this.emptyLabel = '没有可选项',
    this.listHeight = 200,
  });
  final List<IanvsCascadeOption<T>> options;
  final List<T> value;
  final ValueChanged<List<T>>? onChanged;
  final String rootLabel, emptyLabel;
  final double listHeight;
  @override
  State<IanvsCascader<T>> createState() => _IanvsCascaderState<T>();
}

class _IanvsCascaderState<T> extends State<IanvsCascader<T>> {
  int _level = 0;
  List<IanvsCascadeOption<T>> get _path {
    var options = widget.options;
    final path = <IanvsCascadeOption<T>>[];
    for (final value in widget.value) {
      final matches = options.where((o) => o.value == value);
      if (matches.isEmpty || !matches.first.enabled) break;
      final selected = matches.first;
      path.add(selected);
      options = selected.children;
    }
    return path;
  }

  int _lastLevel(List<IanvsCascadeOption<T>> path) => path.isEmpty
      ? 0
      : path.last.children.isEmpty
      ? path.length - 1
      : path.length;
  @override
  void initState() {
    super.initState();
    _level = _lastLevel(_path);
  }

  @override
  void didUpdateWidget(covariant IanvsCascader<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.value, widget.value) ||
        oldWidget.options != widget.options) {
      _level = _lastLevel(_path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ianvs;
    final path = _path;
    final level = _level.clamp(0, _lastLevel(path));
    final items = level == 0 ? widget.options : path[level - 1].children;
    final enabled = widget.onChanged != null;
    Widget crumb(String label, int target) => TextButton(
      onPressed: enabled ? () => setState(() => _level = target) : null,
      style: TextButton.styleFrom(
        backgroundColor: level == target ? t.selected : null,
        foregroundColor: level == target ? t.onSelected : t.muted,
      ),
      child: Text(label),
    );
    return Material(
      color: t.field,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(t.controlRadius),
        side: BorderSide(color: t.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: FocusTraversalGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                runSpacing: 4,
                children: [
                  crumb(widget.rootLabel, 0),
                  for (
                    var i = 0;
                    i < path.length && path[i].children.isNotEmpty;
                    i++
                  ) ...[
                    ExcludeSemantics(
                      child: Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: t.muted,
                      ),
                    ),
                    crumb(path[i].label, i + 1),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            SizedBox(
              height: widget.listHeight,
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        widget.emptyLabel,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    )
                  : Shortcuts(
                      shortcuts: const {
                        SingleActivator(LogicalKeyboardKey.arrowDown):
                            NextFocusIntent(),
                        SingleActivator(LogicalKeyboardKey.arrowUp):
                            PreviousFocusIntent(),
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(8),
                        children: [
                          for (final option in items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Semantics(
                                selected:
                                    level < path.length &&
                                    path[level].value == option.value,
                                child: TextButton(
                                  onPressed: enabled && option.enabled
                                      ? () => widget.onChanged!(
                                          List<T>.unmodifiable([
                                            ...path
                                                .take(level)
                                                .map((o) => o.value),
                                            option.value,
                                          ]),
                                        )
                                      : null,
                                  style: TextButton.styleFrom(
                                    alignment: AlignmentDirectional.centerStart,
                                    minimumSize: Size(0, t.rowHeight),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    foregroundColor: t.text,
                                    backgroundColor:
                                        level < path.length &&
                                            path[level].value == option.value
                                        ? t.selected
                                        : Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(option.label)),
                                      if (option.children.isNotEmpty)
                                        const Icon(
                                          Icons.chevron_right,
                                          size: 18,
                                        )
                                      else if (level < path.length &&
                                          path[level].value == option.value)
                                        Icon(
                                          Icons.check,
                                          size: 18,
                                          color: t.focus,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
