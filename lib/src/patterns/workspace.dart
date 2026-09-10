import 'package:flutter/material.dart';
import '../foundation/tokens.dart';

@immutable
class IanvsSidebarItem {
  const IanvsSidebarItem({
    required this.id,
    required this.label,
    required this.icon,
    this.group,
    this.badge,
  });
  final String id, label;
  final IconData icon;
  final String? group;
  final Widget? badge;
}

class IanvsSidebar extends StatelessWidget {
  const IanvsSidebar({
    super.key,
    required this.items,
    required this.selectedId,
    required this.onSelected,
    this.header,
    this.footer,
    this.emptyState,
  });
  final List<IanvsSidebarItem> items;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final Widget? header, footer;

  /// Content shown at the start of the results area when [items] is empty.
  final Widget? emptyState;
  @override
  Widget build(BuildContext context) {
    final t = context.ianvs;
    String? group;
    final children = <Widget>[];
    for (final item in items) {
      if (item.group != group) {
        group = item.group;
        if (group != null) {
          children.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
              child: Text(group, style: Theme.of(context).textTheme.bodySmall),
            ),
          );
        }
      }
      final selected = item.id == selectedId;
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Semantics(
            selected: selected,
            child: Material(
              color: selected ? t.selected : Colors.transparent,
              borderRadius: BorderRadius.circular(t.controlRadius),
              child: InkWell(
                borderRadius: BorderRadius.circular(t.controlRadius),
                onTap: () => onSelected(item.id),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: t.rowHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          item.icon,
                          size: 20,
                          color: selected ? t.focus : t.text,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: selected ? t.text : t.text,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        ?item.badge,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return ColoredBox(
      color: t.chrome,
      child: Column(
        children: [
          if (header != null)
            Semantics(
              container: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
                child: header,
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(10, 8, 12, 16),
              children: items.isEmpty && emptyState != null
                  ? [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: emptyState,
                      ),
                    ]
                  : children,
            ),
          ),
          if (footer != null)
            Semantics(
              container: true,
              child: Padding(padding: const EdgeInsets.all(12), child: footer),
            ),
        ],
      ),
    );
  }
}

/// A desktop toolbar with a minimum height that grows with accessible text.
class IanvsToolbar extends StatelessWidget implements PreferredSizeWidget {
  const IanvsToolbar({
    super.key,
    required this.title,
    this.leading,
    this.actions = const [],
    this.height = 52,
  });
  final Widget title;
  final Widget? leading;
  final List<Widget> actions;
  final double height;
  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Container(
      constraints: BoxConstraints(minHeight: height),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: context.ianvs.chrome,
        border: Border(bottom: BorderSide(color: context.ianvs.separator)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 12)],
            Expanded(
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.titleMedium!,
                child: title,
              ),
            ),
            ...actions,
          ],
        ),
      ),
    ),
  );
}

/// Constraint-driven shell. The sidebar becomes a real modal drawer below 880px.
class IanvsWorkspace extends StatelessWidget {
  const IanvsWorkspace({
    super.key,
    required this.sidebar,
    required this.body,
    required this.title,
    this.actions = const [],
    this.sidebarWidth = 262,
    this.collapseAt = 880,
    this.scaffoldKey,
  });
  final Widget sidebar, body, title;
  final List<Widget> actions;
  final double sidebarWidth, collapseAt;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final collapsed = constraints.maxWidth < collapseAt;
      final scaledHeight = MediaQuery.textScalerOf(context).scale(16) + 30;
      return Scaffold(
        key: scaffoldKey,
        appBar: IanvsToolbar(
          height: scaledHeight > 52 ? scaledHeight : 52,
          title: title,
          leading: collapsed
              ? Builder(
                  builder: (context) => IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).openAppDrawerTooltip,
                    onPressed: () => Scaffold.of(context).openDrawer(),
                    icon: const Icon(Icons.menu),
                  ),
                )
              : null,
          actions: actions,
        ),
        drawer: collapsed ? Drawer(width: sidebarWidth, child: sidebar) : null,
        body: Row(
          children: [
            if (!collapsed) ...[
              SizedBox(width: sidebarWidth, child: sidebar),
              const VerticalDivider(width: 1),
            ],
            Expanded(child: body),
          ],
        ),
      );
    },
  );
}
