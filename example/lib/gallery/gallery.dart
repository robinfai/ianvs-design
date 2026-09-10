import 'package:flutter/services.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'catalog.dart';
import 'connection.dart';
import 'stories.dart';
import 'supplement_story.dart';

class GalleryHome extends StatefulWidget {
  const GalleryHome({
    super.key,
    required this.initialPage,
    required this.themeMode,
    required this.density,
    required this.onThemeChanged,
    required this.onDensityChanged,
  });
  final String initialPage;
  final ThemeMode themeMode;
  final IanvsDensity density;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<IanvsDensity> onDensityChanged;
  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> {
  late String selected;
  final search = TextEditingController();
  final searchFocus = FocusNode();
  final scaffold = GlobalKey<ScaffoldState>();
  String query = '';
  @override
  void initState() {
    super.initState();
    selected = entries.any((e) => e.id == widget.initialPage)
        ? widget.initialPage
        : 'connection';
  }

  @override
  void dispose() {
    search.dispose();
    searchFocus.dispose();
    super.dispose();
  }

  Future<void> copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('示例代码已复制'), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = entries.firstWhere((e) => e.id == selected);
    final filtered = entries
        .where(
          (e) => '${e.title} ${e.keywords}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
          scaffold.currentState?.openDrawer();
          searchFocus.requestFocus();
        },
        const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
          scaffold.currentState?.openDrawer();
          searchFocus.requestFocus();
        },
      },
      child: Focus(
        autofocus: true,
        child: IanvsWorkspace(
          scaffoldKey: scaffold,
          title: const Text('ianvs design'),
          actions: [
            IanvsMenuButton<ThemeMode>(
              tooltip: '外观模式',
              value: widget.themeMode,
              onSelected: widget.onThemeChanged,
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 20,
              ),
              options: const [
                IanvsOption(ThemeMode.light, '浅色'),
                IanvsOption(ThemeMode.dark, '深色'),
                IanvsOption(ThemeMode.system, '跟随系统'),
              ],
            ),
            const SizedBox(width: 20),
            const Text('0.1', style: TextStyle(fontSize: 14)),
          ],
          sidebar: Column(
            children: [
              Expanded(
                child: IanvsSidebar(
                  header: IanvsTextField(
                    controller: search,
                    focusNode: searchFocus,
                    hintText: '搜索组件',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            tooltip: '清除搜索',
                            onPressed: () {
                              search.clear();
                              setState(() => query = '');
                            },
                            icon: const Icon(Icons.close, size: 16),
                          )
                        : const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Text('⌘ K', style: TextStyle(fontSize: 12)),
                          ),
                    onChanged: (value) => setState(() => query = value),
                  ),
                  items: filtered.map((e) => e.item).toList(),
                  selectedId: selected,
                  onSelected: (id) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).removeCurrentSnackBar();
                    setState(() => selected = id);
                    if (scaffold.currentState?.isDrawerOpen ?? false) {
                      Navigator.of(context).pop();
                    }
                  },
                  emptyState: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('没有匹配的组件'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          search.clear();
                          setState(() => query = '');
                          searchFocus.requestFocus();
                        },
                        child: const Text('清空搜索'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final large =
                  constraints.maxWidth >= 990 &&
                  constraints.maxHeight >= 760 &&
                  MediaQuery.textScalerOf(context).scale(13) < 20;
              final code = CodePanel(
                code: entry.code,
                onCopy: () => copy(entry.code),
              );
              final header = StoryHeader(
                entry: entry,
                onCopy: () => copy(entry.code),
                density: widget.density,
                onDensityChanged: widget.onDensityChanged,
              );
              if (selected == 'connection') {
                return Column(
                  children: [
                    Expanded(
                      child: ConnectionStory(
                        density: widget.density,
                        onDensityChanged: widget.onDensityChanged,
                        wide: large,
                        onCopy: () => copy(entry.code),
                      ),
                    ),
                    ExpansionTile(
                      title: const Text('示例与设计说明'),
                      children: [
                        SizedBox(
                          height: (constraints.maxHeight * .32).clamp(140, 260),
                          child: code,
                        ),
                      ],
                    ),
                    const GalleryFooter(),
                  ],
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      key: ValueKey(selected),
                      padding: EdgeInsets.all(
                        constraints.maxWidth < 600 ? 20 : 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          header,
                          const SizedBox(height: 28),
                          if (selected == 'supplements')
                            const SupplementStory()
                          else
                            MaterialStories(
                              key: ValueKey(selected),
                              page: selected,
                            ),
                          const SizedBox(height: 32),
                          SizedBox(height: 300, child: code),
                        ],
                      ),
                    ),
                  ),
                  const GalleryFooter(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class StoryHeader extends StatelessWidget {
  const StoryHeader({
    super.key,
    required this.entry,
    required this.onCopy,
    required this.density,
    required this.onDensityChanged,
  });
  final CatalogEntry entry;
  final VoidCallback onCopy;
  final IanvsDensity density;
  final ValueChanged<IanvsDensity> onDensityChanged;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 12,
      children: [
        SizedBox(
          width: constraints.maxWidth > 740
              ? constraints.maxWidth - 280
              : constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                entry.description,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: context.ianvs.muted),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DensityPicker(value: density, onChanged: onDensityChanged),
            TextButton.icon(
              icon: const Icon(Icons.content_copy, size: 18),
              onPressed: onCopy,
              label: const Text('复制示例'),
            ),
          ],
        ),
      ],
    ),
  );
}

class DensityPicker extends StatelessWidget {
  const DensityPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final IanvsDensity value;
  final ValueChanged<IanvsDensity> onChanged;
  static String label(IanvsDensity value) => switch (value) {
    IanvsDensity.compact => '紧凑',
    IanvsDensity.comfortable => '舒适',
    IanvsDensity.touch => '触控',
  };
  @override
  Widget build(BuildContext context) => IanvsMenuButton<IanvsDensity>(
    tooltip: '控件密度',
    value: value,
    onSelected: onChanged,
    options: [for (final d in IanvsDensity.values) IanvsOption(d, label(d))],
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label(value)),
        const SizedBox(width: 20),
        const Icon(Icons.arrow_drop_down, size: 18),
      ],
    ),
  );
}

class CodePanel extends StatefulWidget {
  const CodePanel({super.key, required this.code, required this.onCopy});
  final String code;
  final VoidCallback onCopy;
  @override
  State<CodePanel> createState() => _CodePanelState();
}

class _CodePanelState extends State<CodePanel> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final t = context.ianvs;
    final lines = widget.code.split('\n');
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: t.separator)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 52,
            child: Row(
              children: [
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: TabBar(
                      isScrollable: true,
                      tabAlignment: TabAlignment.start,
                      padding: const EdgeInsets.only(left: 24),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelStyle: Theme.of(context).textTheme.bodyLarge,
                      unselectedLabelStyle: Theme.of(
                        context,
                      ).textTheme.bodyLarge,
                      onTap: (value) => setState(() => tab = value),
                      tabs: const [
                        Tab(text: '使用示例'),
                        Tab(text: '交互约定'),
                        Tab(text: '设计变量'),
                      ],
                    ),
                  ),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: t.muted),
                  onPressed: widget.onCopy,
                  icon: const Icon(Icons.content_copy, size: 16),
                  label: const Text('复制代码'),
                ),
                const SizedBox(width: 18),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(40, 18, 24, 18),
              child: Align(
                alignment: AlignmentDirectional.topStart,
                child: switch (tab) {
                  1 => const Text(
                    'Tab 按阅读顺序移动焦点；Enter / Space 激活控件。\nEscape 关闭菜单和对话框；取消保留原有状态。\n错误与加载状态同时提供文字和语义；纯图标按钮必须有说明。\n按内容与文字缩放增长，窄窗口改为纵向布局。',
                  ),
                  2 => Text(
                    '控件高度  ${t.controlHeight.toInt()}\n圆角  ${t.controlRadius.toInt()}\n标签字号  ${Theme.of(context).textTheme.labelLarge!.fontSize!.toInt()}\n间距  4 / 8 / 12 / 16 / 24 / 32\n动效  120 / 180 ms，尊重减少动画\n主题  ColorScheme + IanvsTokens',
                  ),
                  _ => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExcludeSemantics(
                        child: Text(
                          List.generate(
                            lines.length,
                            (i) => '${i + 1}',
                          ).join('\n'),
                          style: TextStyle(
                            fontFamily: 'GalleryMono',
                            fontFamilyFallback: ['GallerySans'],
                            color: t.subtle,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: SelectableText.rich(
                          TextSpan(
                            children: [
                              for (final line in lines)
                                TextSpan(
                                  text: '$line\n',
                                  style: TextStyle(
                                    color: line.contains('Ianvs')
                                        ? t.focus
                                        : line.trim().startsWith('//')
                                        ? t.subtle
                                        : t.text,
                                  ),
                                ),
                            ],
                          ),
                          style: const TextStyle(
                            fontFamily: 'GalleryMono',
                            fontFamilyFallback: ['GallerySans'],
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GalleryFooter extends StatelessWidget {
  const GalleryFooter({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: context.ianvs.separator)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: context.ianvs.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tab 切换焦点 · Enter 执行操作 · Esc 关闭弹窗',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    ),
  );
}
