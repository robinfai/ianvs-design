import 'package:ianvs_design/ianvs_design.dart';

/// The host owns layout and state; the handle only requests new extents.
class PanelStory extends StatefulWidget {
  const PanelStory({super.key});

  @override
  State<PanelStory> createState() => _PanelStoryState();
}

class _PanelStoryState extends State<PanelStory> {
  double sidebarWidth = 160, terminalHeight = 90;
  bool sidebarVisible = true;
  final draft = TextEditingController();

  @override
  void dispose() {
    draft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: () => setState(() => sidebarVisible = !sidebarVisible),
          icon: const Icon(Icons.view_sidebar_outlined),
          label: Text(sidebarVisible ? '隐藏示例侧栏' : '显示示例侧栏'),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        height: 320,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showSidebar = sidebarVisible && constraints.maxWidth >= 540;
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (showSidebar) ...[
                        SizedBox(
                          key: const Key('resizable-sidebar'),
                          width: sidebarWidth,
                          child: ColoredBox(
                            color: context.ianvs.chrome,
                            child: ListView(
                              padding: const EdgeInsets.all(12),
                              children: [
                                const Text('文件'),
                                const SizedBox(height: 12),
                                Text(
                                  'lib/main.dart',
                                  style: context.ianvsTypography.code,
                                ),
                              ],
                            ),
                          ),
                        ),
                        IanvsResizeHandle(
                          key: const Key('example-sidebar-handle'),
                          value: sidebarWidth,
                          min: 120,
                          max: 240,
                          resetValue: 160,
                          semanticLabel: '示例侧栏宽度',
                          onChanged: (value) =>
                              setState(() => sidebarWidth = value),
                        ),
                      ],
                      Expanded(
                        key: const Key('panel-editor'),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: IanvsTextField(
                            controller: draft,
                            labelText: '面板草稿',
                            maxLines: 3,
                            hintText: '调整尺寸或隐藏侧栏后仍保留。',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IanvsResizeHandle(
                  key: const Key('example-terminal-handle'),
                  value: terminalHeight,
                  min: 60,
                  max: 140,
                  resetValue: 90,
                  axis: Axis.vertical,
                  reverse: true,
                  semanticLabel: '示例终端高度',
                  onChanged: (value) => setState(() => terminalHeight = value),
                ),
                SizedBox(
                  key: const Key('resizable-terminal'),
                  height: terminalHeight,
                  width: double.infinity,
                  child: ColoredBox(
                    color: context.ianvs.field,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '> flutter analyze\nNo issues found.',
                        style: context.ianvsTypography.code,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ],
  );
}
