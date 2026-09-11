import 'package:ianvs_design/ianvs_design.dart';
import 'panel_story.dart';

class MaterialStories extends StatefulWidget {
  const MaterialStories({super.key, required this.page});
  final String page;
  @override
  State<MaterialStories> createState() => _MaterialStoriesState();
}

class _MaterialStoriesState extends State<MaterialStories> {
  int count = 0, navigation = 0;
  bool flag = true, disabled = false, password = true, ascending = true;
  bool? mixed;
  String radio = '本地', choice = '紧凑', select = 'shell', result = '尚未执行操作';
  String scenario = '通用';
  double slider = 32;
  RangeValues range = const RangeValues(8, 24);
  Set<String> filters = {'本地'};
  Set<int> segments = {0};
  final selectedRows = <String>{};
  bool inputChip = true;
  bool inputChipSelected = false;
  DateTime date = DateTime(2026, 9, 10);
  DateTimeRange dates = DateTimeRange(
    start: DateTime(2026, 9, 10),
    end: DateTime(2026, 9, 14),
  );
  TimeOfDay time = const TimeOfDay(hour: 9, minute: 30);
  final form = GlobalKey<FormState>();
  final textController = TextEditingController();
  final menu = MenuController();
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void notice(String value) {
    setState(() {
      result = value;
      count++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value), duration: const Duration(seconds: 2)),
    );
  }

  Widget datePickerLayout(BuildContext context, Widget? child) {
    final media = MediaQuery.of(context);
    if (media.textScaler.scale(14) <= 21 ||
        media.orientation == Orientation.portrait) {
      return child!;
    }
    // Give large-text pickers a portrait panel whose local
    // MediaQuery matches its actual constrained viewport.
    // Material's landscape range header is only 152px wide.
    final width = (media.size.height - 48).clamp(280.0, 640.0);
    return Center(
      child: SizedBox(
        width: width,
        child: MediaQuery(
          data: media.copyWith(size: Size(width, media.size.height)),
          child: Theme(
            data: Theme.of(context).copyWith(
              dialogTheme: Theme.of(context).dialogTheme.copyWith(
                constraints: BoxConstraints(minWidth: width - 32),
              ),
            ),
            child: child!,
          ),
        ),
      ),
    );
  }

  Widget section(String title, String detail, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 32),
    child: IanvsFormSection(
      title: Text(title),
      description: detail,
      children: children,
    ),
  );
  Widget flow(List<Widget> children) => Wrap(
    spacing: 12,
    runSpacing: 12,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );
  Widget framed(Widget child) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );
  Widget outcome() => Semantics(
    liveRegion: true,
    child: Text(
      '$result · 操作 $count 次',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
  @override
  Widget build(BuildContext context) => switch (widget.page) {
    'actions' => actions(),
    'inputs' => inputs(),
    'navigation' => navigations(),
    'feedback' => feedback(),
    'workspace' => workspace(),
    'overlays' => overlays(),
    _ => foundations(),
  };

  Widget actions() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      section('常规按钮', '相同尺寸和焦点反馈，用样式表达操作层级。', [
        flow([
          FilledButton(
            onPressed: () => notice('FilledButton 已执行'),
            child: const Text('填充按钮'),
          ),
          FilledButton.tonal(
            onPressed: () => notice('TonalButton 已执行'),
            child: const Text('色调按钮'),
          ),
          ElevatedButton(
            onPressed: () => notice('ElevatedButton 已执行'),
            child: const Text('高亮按钮'),
          ),
          OutlinedButton(
            onPressed: () => notice('OutlinedButton 已执行'),
            child: const Text('描边按钮'),
          ),
          TextButton(
            onPressed: () => notice('TextButton 已执行'),
            child: const Text('文本按钮'),
          ),
        ]),
        flow([
          const FilledButton(onPressed: null, child: Text('禁用状态')),
          const IanvsButton(loading: true, child: Text('加载状态')),
          IanvsButton(
            icon: Icons.add,
            onPressed: () async {
              await Future<void>.delayed(const Duration(milliseconds: 700));
              if (mounted) notice('异步任务完成');
            },
            child: const Text('执行异步任务'),
          ),
          IanvsButton(
            variant: IanvsButtonVariant.danger,
            onPressed: () => notice('危险操作示例'),
            child: const Text('危险操作'),
          ),
        ]),
        outcome(),
      ]),
      section('图标按钮', '每个图标按钮都有可读名称，可通过键盘到达。', [
        flow([
          IanvsIconButton(
            icon: Icons.settings_outlined,
            tooltip: '打开设置示例',
            onPressed: () => notice('已打开设置示例'),
          ),
          IconButton.filled(
            tooltip: '收藏',
            isSelected: flag,
            onPressed: () => setState(() => flag = !flag),
            icon: const Icon(Icons.star_border),
            selectedIcon: const Icon(Icons.star),
          ),
          IconButton.filledTonal(
            tooltip: '更多操作',
            onPressed: () => notice('更多操作'),
            icon: const Icon(Icons.more_horiz),
          ),
          IconButton.outlined(
            tooltip: '复制项目',
            onPressed: () => notice('项目已复制'),
            icon: const Icon(Icons.content_copy),
          ),
          const IconButton(
            tooltip: '删除不可用',
            onPressed: null,
            icon: Icon(Icons.delete_outline),
          ),
        ]),
      ]),
      section('浮动操作', '保留 Material FAB API，适合需要持续可见的主操作。', [
        flow([
          FloatingActionButton.small(
            heroTag: 'small',
            tooltip: '小型新建',
            onPressed: () => notice('新建小型项目'),
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            heroTag: 'regular',
            tooltip: '新建',
            onPressed: () => notice('新建项目'),
            child: const Icon(Icons.add),
          ),
          FloatingActionButton.extended(
            heroTag: 'extended',
            onPressed: () => notice('新建项目'),
            icon: const Icon(Icons.add),
            label: const Text('新建项目'),
          ),
        ]),
      ]),
      section('分段选择', '支持单选与多选，方向键和焦点语义由 Material 提供。', [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: '紧凑', label: Text('紧凑')),
            ButtonSegment(value: '舒适', label: Text('舒适')),
            ButtonSegment(value: '触控', label: Text('触控')),
          ],
          selected: {choice},
          onSelectionChanged: (v) => setState(() => choice = v.first),
        ),
        SegmentedButton<int>(
          multiSelectionEnabled: true,
          emptySelectionAllowed: true,
          segments: const [
            ButtonSegment(
              value: 0,
              icon: Icon(Icons.format_bold),
              label: Text('加粗'),
            ),
            ButtonSegment(
              value: 1,
              icon: Icon(Icons.format_italic),
              label: Text('斜体'),
            ),
            ButtonSegment(
              value: 2,
              icon: Icon(Icons.format_underlined),
              label: Text('下划线'),
            ),
          ],
          selected: segments,
          onSelectionChanged: (v) => setState(() => segments = v),
        ),
      ]),
    ],
  );

  Widget inputs() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      section('文本字段与校验', '标签、辅助信息、错误和文字缩放共享同一组规则。', [
        Form(
          key: form,
          child: Column(
            children: [
              IanvsFieldRow(
                label: '名称',
                child: IanvsTextField(
                  controller: textController,
                  hintText: '输入连接名称',
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? '请输入名称' : null,
                  onSaved: (v) => result = '已保存：$v',
                ),
              ),
              const SizedBox(height: 16),
              IanvsFieldRow(
                label: '密码',
                child: IanvsTextField(
                  initialValue: 'sample-password',
                  obscureText: password,
                  suffixIcon: IconButton(
                    tooltip: password ? '显示密码' : '隐藏密码',
                    onPressed: () => setState(() => password = !password),
                    icon: Icon(
                      password
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const IanvsFieldRow(
                label: '描述',
                child: IanvsTextField(
                  hintText: '输入多行描述',
                  minLines: 3,
                  maxLines: 5,
                ),
              ),
              const SizedBox(height: 16),
              const IanvsFieldRow(
                label: '禁用',
                child: IanvsTextField(initialValue: '只读配置', enabled: false),
              ),
              const SizedBox(height: 16),
              flow([
                IanvsButton(
                  onPressed: () {
                    if (form.currentState!.validate()) {
                      form.currentState!.save();
                      setState(() => count++);
                    }
                  },
                  child: const Text('校验并保存'),
                ),
                IanvsButton(
                  variant: IanvsButtonVariant.secondary,
                  onPressed: () {
                    form.currentState!.reset();
                    textController.clear();
                  },
                  child: const Text('重置表单'),
                ),
              ]),
            ],
          ),
        ),
        outcome(),
      ]),
      section('搜索与自动补全', '搜索建议和原生选项菜单保留完整的鼠标与键盘操作。', [
        IanvsSearchField<String>(
          hintText: '搜索连接',
          emptyText: '没有匹配的连接',
          optionIcon: Icons.terminal,
          options: const [
            IanvsOption('Local Shell', 'Local Shell'),
            IanvsOption('Local Server', 'Local Server'),
            IanvsOption('Codex', 'Codex'),
          ],
          onSelected: (value) => notice('已选择连接：$value'),
        ),
        Autocomplete<String>(
          optionsBuilder: (value) => [
            'Local Shell',
            'Local Server',
            'Location',
            'localhost',
          ].where((x) => x.toLowerCase().contains(value.text.toLowerCase())),
          onSelected: (v) => notice('补全：$v'),
          optionsViewBuilder: (context, onSelected, options) =>
              IanvsAutocompleteOptions<String>(
                options: options,
                onSelected: onSelected,
              ),
          fieldViewBuilder: (context, controller, focus, submit) =>
              TextFormField(
                controller: controller,
                focusNode: focus,
                onFieldSubmitted: (_) => submit(),
                decoration: const InputDecoration(
                  labelText: '自动补全',
                  hintText: '输入 loc',
                ),
              ),
        ),
        IanvsFieldRow(
          label: '连接类型',
          child: IanvsSelect<String>(
            value: select,
            options: const [
              IanvsOption('shell', '登录 Shell'),
              IanvsOption('ssh', 'SSH'),
              IanvsOption('disabled', '不可用连接', enabled: false),
            ],
            onChanged: (v) => setState(() => select = v!),
          ),
        ),
        IanvsFieldRow(
          label: '应用场景',
          child: Semantics(
            value: scenario,
            child: DropdownMenu<String>(
              initialSelection: '通用',
              expandedInsets: EdgeInsets.zero,
              requestFocusOnTap: false,
              alignmentOffset: const Offset(0, 4),
              trailingIcon: const Icon(Icons.arrow_drop_down, size: 18),
              selectedTrailingIcon: const Icon(Icons.arrow_drop_up, size: 18),
              onSelected: (v) {
                if (v == null) return;
                setState(() => scenario = v);
                notice('下拉菜单：$v');
              },
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: '通用', label: '通用'),
                DropdownMenuEntry(value: 'Terminal', label: 'Terminal'),
                DropdownMenuEntry(value: 'ACP', label: 'ACP'),
              ],
            ),
          ),
        ),
      ]),
      section('复选、单选与开关', '同时覆盖未选、选中、混合和禁用状态。', [
        flow([
          IanvsControlLabel(
            label: '复选框',
            onTap: () => setState(() => flag = !flag),
            controlBuilder: (focusNode) => Checkbox(
              focusNode: focusNode,
              value: flag,
              onChanged: (v) => setState(() => flag = v!),
            ),
          ),
          IanvsControlLabel(
            label: '三态选择',
            onTap: () => setState(
              () => mixed = switch (mixed) {
                false => true,
                true => null,
                null => false,
              },
            ),
            controlBuilder: (focusNode) => Checkbox(
              focusNode: focusNode,
              tristate: true,
              value: mixed,
              onChanged: (v) => setState(() => mixed = v),
            ),
          ),
          IanvsControlLabel(
            label: '禁用',
            onTap: null,
            controlBuilder: (focusNode) =>
                Checkbox(focusNode: focusNode, value: false, onChanged: null),
          ),
        ]),
        RadioGroup<String>(
          groupValue: radio,
          onChanged: (v) => setState(() => radio = v!),
          child: flow([
            for (final value in ['本地', '远程'])
              IanvsControlLabel(
                label: value,
                onTap: () => setState(() => radio = value),
                controlBuilder: (focusNode) =>
                    Radio<String>(focusNode: focusNode, value: value),
              ),
          ]),
        ),
        IanvsSettingsRow(
          title: '恢复工作区',
          description: '保存最近一次窗口布局。',
          value: flag,
          onChanged: (v) => setState(() => flag = v),
        ),
        flow([
          IanvsControlLabel(
            label: 'Material Switch',
            onTap: () => setState(() => flag = !flag),
            controlBuilder: (focusNode) => Switch(
              focusNode: focusNode,
              value: flag,
              onChanged: (v) => setState(() => flag = v),
            ),
          ),
          IanvsControlLabel(
            label: '禁用开关',
            onTap: null,
            controlBuilder: (focusNode) =>
                Switch(focusNode: focusNode, value: false, onChanged: null),
          ),
        ]),
      ]),
      section('滑块', '可通过拖动或键盘调整，显示当前值。', [
        Slider(
          value: slider,
          max: 100,
          divisions: 100,
          label: '${slider.round()}',
          semanticFormatterCallback: (v) => '${v.round()}%',
          onChanged: (v) => setState(() => slider = v),
        ),
        Text('当前值 ${slider.round()}'),
        RangeSlider(
          values: range,
          max: 40,
          divisions: 40,
          labels: RangeLabels('${range.start.round()}', '${range.end.round()}'),
          onChanged: (v) => setState(() => range = v),
        ),
        Text('范围 ${range.start.round()} – ${range.end.round()}'),
      ]),
      section('Chip', '操作、筛选、单选与可移除输入使用原生 Material 状态。', [
        flow([
          ActionChip(
            avatar: const Icon(Icons.play_arrow, size: 16),
            label: const Text('运行'),
            onPressed: () => notice('运行 Chip'),
          ),
          for (final item in ['本地', '远程'])
            FilterChip(
              label: Text(item),
              selected: filters.contains(item),
              onSelected: (v) => setState(() {
                v ? filters.add(item) : filters.remove(item);
              }),
            ),
          for (final item in ['紧凑', '舒适'])
            ChoiceChip(
              label: Text(item),
              selected: choice == item,
              onSelected: (_) => setState(() => choice = item),
            ),
          if (inputChip)
            InputChip(
              label: const Text('标签'),
              selected: inputChipSelected,
              onSelected: (selected) =>
                  setState(() => inputChipSelected = selected),
              onDeleted: () => setState(() => inputChip = false),
            )
          else
            TextButton(
              onPressed: () => setState(() => inputChip = true),
              child: const Text('恢复标签'),
            ),
        ]),
      ]),
      section('日期与时间', '日期、范围与时间选择器都继承当前主题。', [
        flow([
          OutlinedButton.icon(
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text('日期 ${date.month}/${date.day}'),
            onPressed: () async {
              final v = await showDatePicker(
                context: context,
                calendarDelegate: const IanvsGregorianCalendarDelegate(),
                builder: datePickerLayout,
                initialDate: date,
                currentDate: DateTime(2026, 9, 10),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (v != null && mounted) setState(() => date = v);
            },
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.date_range),
            label: Text(
              '范围 ${dates.start.month}/${dates.start.day} – ${dates.end.month}/${dates.end.day}',
            ),
            onPressed: () async {
              final v = await showDateRangePicker(
                context: context,
                calendarDelegate: const IanvsGregorianCalendarDelegate(),
                builder: datePickerLayout,
                initialDateRange: dates,
                currentDate: DateTime(2026, 9, 10),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (v != null && mounted) setState(() => dates = v);
            },
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.schedule),
            label: Text('时间 ${time.format(context)}'),
            onPressed: () async {
              final v = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (v != null && mounted) setState(() => time = v);
            },
          ),
        ]),
      ]),
    ],
  );

  Widget navigations() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      section('App bar 与工具栏', '紧凑工具栏承载标题、导航与上下文操作。', [
        AppBar(
          primary: false,
          title: const Text('项目管理'),
          leading: IconButton(
            tooltip: '返回示例',
            onPressed: () => notice('返回'),
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              tooltip: '搜索项目',
              onPressed: () => notice('搜索项目'),
              icon: const Icon(Icons.search),
            ),
          ],
        ),
        BottomAppBar(
          child: Row(
            children: [
              IconButton(
                tooltip: '菜单',
                onPressed: () => notice('菜单'),
                icon: const Icon(Icons.menu),
              ),
              const Spacer(),
              IconButton(
                tooltip: '新建项目',
                onPressed: () => notice('新建项目'),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ]),
      section('Navigation bar / rail / drawer', '三个主要目的地共享受控选择状态。', [
        NavigationBar(
          selectedIndex: navigation,
          onDestinationSelected: (v) => setState(() => navigation = v),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), label: '主页'),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              label: '项目',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              label: '设置',
            ),
          ],
        ),
        SizedBox(
          height: 250 + (MediaQuery.textScalerOf(context).scale(13) - 13) * 6,
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: navigation,
                onDestinationSelected: (v) => setState(() => navigation = v),
                labelType: NavigationRailLabelType.all,
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    label: Text('主页'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.folder_outlined),
                    label: Text('项目'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.settings_outlined),
                    label: Text('设置'),
                  ),
                ],
              ),
              const VerticalDivider(),
              Expanded(
                child: Center(
                  child: Text(['主页内容', '项目列表', '设置内容'][navigation]),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: NavigationDrawer(
            selectedIndex: navigation,
            onDestinationSelected: (v) => setState(() => navigation = v),
            children: const [
              Padding(padding: EdgeInsets.all(16), child: Text('ianvs design')),
              NavigationDrawerDestination(
                icon: Icon(Icons.home_outlined),
                label: Text('主页'),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.folder_outlined),
                label: Text('项目'),
              ),
              NavigationDrawerDestination(
                icon: Icon(Icons.settings_outlined),
                label: Text('设置'),
              ),
            ],
          ),
        ),
      ]),
      section('标签页', '保留原生选中指示与键盘可达性。', [
        DefaultTabController(
          length: 3,
          child: SizedBox(
            height: 160,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: '预览'),
                    Tab(text: '规范'),
                    Tab(text: '代码'),
                  ],
                ),
                const Expanded(
                  child: TabBarView(
                    children: [
                      Center(child: Text('可交互组件预览')),
                      Center(child: Text('尺寸、颜色与状态规则')),
                      Center(child: Text('可复用 Dart 示例')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
      section('菜单', '锚定菜单、菜单栏与快捷菜单均支持关闭与返回焦点。', [
        flow([
          MenuAnchor(
            controller: menu,
            alignmentOffset: const Offset(0, 4),
            style: const MenuStyle(alignment: AlignmentDirectional.bottomStart),
            menuChildren: [
              MenuItemButton(
                onPressed: () {
                  menu.close();
                  notice('新建菜单项');
                },
                leadingIcon: const Icon(Icons.add),
                child: const Text('新建项目'),
              ),
              MenuItemButton(
                onPressed: () {
                  menu.close();
                  notice('已复制路径');
                },
                leadingIcon: const Icon(Icons.copy),
                child: const Text('复制路径'),
              ),
              const MenuItemButton(onPressed: null, child: Text('不可用操作')),
            ],
            builder: (context, controller, child) => OutlinedButton(
              onPressed: () =>
                  controller.isOpen ? controller.close() : controller.open(),
              child: const Text('打开锚定菜单'),
            ),
          ),
          IanvsMenuButton<String>(
            tooltip: '快捷菜单',
            onSelected: notice,
            options: const [IanvsOption('重命名', '重命名'), IanvsOption('归档', '归档')],
            child: const Text('快捷菜单'),
          ),
        ]),
        MenuBar(
          children: [
            SubmenuButton(
              menuChildren: [
                MenuItemButton(
                  onPressed: () => notice('新建项目'),
                  child: const Text('新建项目'),
                ),
                MenuItemButton(
                  onPressed: () => notice('打开项目'),
                  child: const Text('打开…'),
                ),
              ],
              child: const Text('文件'),
            ),
            SubmenuButton(
              menuChildren: [
                MenuItemButton(
                  onPressed: () => notice('撤销'),
                  child: const Text('撤销'),
                ),
                MenuItemButton(
                  onPressed: () => notice('复制'),
                  child: const Text('复制'),
                ),
              ],
              child: const Text('编辑'),
            ),
            SubmenuButton(
              menuChildren: [
                CheckboxMenuButton(
                  value: flag,
                  onChanged: (v) => setState(() => flag = v!),
                  child: const Text('显示隐藏文件'),
                ),
              ],
              child: const Text('视图'),
            ),
          ],
        ),
        outcome(),
      ]),
    ],
  );

  Widget feedback() {
    final rows = ['ianvs-acp', 'ianvs-design', 'ianvs-terminal']
      ..sort((a, b) => ascending ? a.compareTo(b) : b.compareTo(a));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        section('状态与提示', '适当选择轻提示、持续通知和操作反馈。', [
          flow([
            Badge.count(
              count: count + 3,
              child: IconButton(
                tooltip: '通知',
                onPressed: () => notice('已阅读通知'),
                icon: const Icon(Icons.notifications_none),
              ),
            ),
            Tooltip(
              message: '控件说明会随键盘焦点或悬停出现',
              child: OutlinedButton(
                onPressed: () => notice('提示按钮'),
                child: const Text('悬停查看提示'),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                final before = count;
                setState(() => count++);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('设置已保存'),
                    action: SnackBarAction(
                      label: '撤销',
                      onPressed: () => setState(() => count = before),
                    ),
                  ),
                );
              },
              child: const Text('显示 Snackbar'),
            ),
            OutlinedButton(
              onPressed: () => ScaffoldMessenger.of(context).showMaterialBanner(
                MaterialBanner(
                  content: const Text('MaterialBanner：有一项配置待确认'),
                  actions: [
                    TextButton(
                      onPressed: () => ScaffoldMessenger.of(
                        context,
                      ).hideCurrentMaterialBanner(),
                      child: const Text('知道了'),
                    ),
                  ],
                ),
              ),
              child: const Text('显示 MaterialBanner'),
            ),
          ]),
          IanvsBanner(
            tone: IanvsTone.danger,
            message: '连接不可用，请检查启动配置。',
            actions: [
              TextButton(
                onPressed: () => notice('正在重试连接'),
                child: const Text('重试'),
              ),
            ],
          ),
          const IanvsBanner(tone: IanvsTone.success, message: '设置已保存'),
          const IanvsBanner(tone: IanvsTone.warning, message: '更改将在下次启动时生效'),
        ]),
        section('进度', '不确定状态与可度量的进度使用相同语义色。', [
          flow([
            const SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(semanticsLabel: '正在加载'),
            ),
            const SizedBox(width: 8),
            const SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(
                value: .68,
                semanticsLabel: '完成 68%',
              ),
            ),
            const Text('68%'),
          ]),
          const LinearProgressIndicator(semanticsLabel: '正在同步'),
          LinearProgressIndicator(value: slider / 100, semanticsLabel: '任务进度'),
          Slider(
            value: slider,
            max: 100,
            divisions: 100,
            label: '${slider.round()}%',
            onChanged: (v) => setState(() => slider = v),
          ),
        ]),
        section('卡片与列表', '优先用分组和分隔线组织内容。', [
          framed(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('项目概览', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                const Text('管理项目、成员与资源。'),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => notice('项目详情'),
                  child: const Text('查看项目'),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.folder_outlined),
            title: const Text('设计文件'),
            subtitle: const Text('12 个文件 · 本地工作区'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => notice('打开设计文件'),
          ),
          const Divider(),
          CheckboxListTile(
            value: flag,
            onChanged: (v) => setState(() => flag = v!),
            title: const Text('同步项目'),
            subtitle: const Text('将该项目加入同步列表'),
          ),
          SwitchListTile(
            value: flag,
            onChanged: (v) => setState(() => flag = v),
            title: const Text('显示项目预览'),
          ),
          RadioGroup<String>(
            groupValue: radio,
            onChanged: (v) => setState(() => radio = v!),
            child: const Column(
              children: [
                IanvsChoiceTile<String>(
                  value: '本地',
                  title: Text('本地存储'),
                  subtitle: Text('将文件保存在此设备上'),
                ),
                IanvsChoiceTile<String>(
                  value: '远程',
                  title: Text('远程存储'),
                  subtitle: Text('在关联设备间同步文件'),
                ),
                IanvsChoiceTile<String>(
                  value: '归档',
                  title: Text('归档存储'),
                  subtitle: Text('此工作区暂不可用'),
                  enabled: false,
                ),
              ],
            ),
          ),
          ExpansionTile(
            title: const Text('高级设置'),
            leading: const Icon(Icons.settings_outlined),
            children: [
              ListTile(title: const Text('构建配置'), onTap: () => notice('构建配置')),
              ListTile(title: const Text('环境变量'), onTap: () => notice('环境变量')),
            ],
          ),
        ]),
        section('数据表格', '可排序、可选择的数据行，窄窗口内横向滚动。', [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: 0,
              sortAscending: ascending,
              columns: [
                DataColumn(
                  label: const Text('名称'),
                  onSort: (_, value) => setState(() => ascending = value),
                ),
                const DataColumn(label: Text('类型')),
                const DataColumn(label: Text('状态')),
              ],
              rows: rows
                  .map(
                    (name) => DataRow(
                      selected: selectedRows.contains(name),
                      onSelectChanged: (v) => setState(() {
                        v! ? selectedRows.add(name) : selectedRows.remove(name);
                      }),
                      cells: [
                        DataCell(Text(name)),
                        const DataCell(Text('Flutter 应用')),
                        const DataCell(Text('开发中')),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ]),
        section('空状态', '说明当前状态并提供可执行的下一步。', [
          IanvsEmptyState(
            title: '暂无项目',
            description: '创建第一个项目，开始使用工作区。',
            action: IanvsButton(
              onPressed: () => notice('已创建示例项目'),
              child: const Text('新建项目'),
            ),
          ),
          outcome(),
        ]),
      ],
    );
  }

  Widget workspace() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      section('工作区组合', '侧栏、工具栏与正文通过普通 Widget 插槽组合。', [
        framed(
          Column(
            children: [
              IanvsToolbar(
                title: const Text('项目工作区'),
                actions: [
                  IanvsIconButton(
                    icon: Icons.add,
                    tooltip: '添加文档',
                    onPressed: () => notice('已添加文档'),
                  ),
                ],
              ),
              SizedBox(
                height: 320,
                child: LayoutBuilder(
                  builder: (context, c) => Row(
                    children: [
                      if (c.maxWidth > 500)
                        SizedBox(
                          width: 180,
                          child: IanvsSidebar(
                            items: const [
                              IanvsSidebarItem(
                                id: '0',
                                label: '概览',
                                icon: Icons.home_outlined,
                              ),
                              IanvsSidebarItem(
                                id: '1',
                                label: '文件',
                                icon: Icons.folder_outlined,
                              ),
                              IanvsSidebarItem(
                                id: '2',
                                label: '设置',
                                icon: Icons.settings_outlined,
                              ),
                            ],
                            selectedId: '$navigation',
                            onSelected: (id) =>
                                setState(() => navigation = int.parse(id)),
                          ),
                        ),
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                ['项目概览', '设计文件', '项目设置'][navigation],
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              const Text('通过导航切换工作内容。'),
                              if (c.maxWidth <= 500)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: IanvsMenuButton<int>(
                                    tooltip: '选择工作区内容',
                                    value: navigation,
                                    onSelected: (value) =>
                                        setState(() => navigation = value),
                                    options: const [
                                      IanvsOption(0, '概览'),
                                      IanvsOption(1, '文件'),
                                      IanvsOption(2, '设置'),
                                    ],
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(['概览', '文件', '设置'][navigation]),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.arrow_drop_down,
                                          size: 18,
                                        ),
                                      ],
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
              ),
            ],
          ),
        ),
        outcome(),
      ]),
      const IanvsBanner(message: '缩小应用窗口即可查看侧栏切换为抽屉的实际效果。'),
      const SizedBox(height: 24),
      section('可调整面板', '拖动分隔线调整尺寸，双击重置；Tab 聚焦后可使用方向键。', [
        framed(const PanelStory()),
      ]),
    ],
  );

  Widget overlays() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      section('确认与退出', '取消是默认安全焦点；Escape 或点击外部视为取消。', [
        IanvsTextField(
          controller: textController,
          labelText: '草稿名称',
          hintText: '输入未保存的修改',
        ),
        flow([
          IanvsButton(
            variant: IanvsButtonVariant.danger,
            onPressed: () async {
              final confirmed = await showIanvsConfirmDialog(
                context: context,
                title: '放弃更改？',
                message: '尚未保存的修改将丢失。',
                confirmLabel: '放弃更改',
                cancelLabel: '继续编辑',
                destructive: true,
              );
              if (!mounted) return;
              if (confirmed) textController.clear();
              notice(confirmed ? '已放弃草稿' : '继续编辑，草稿已保留');
            },
            child: const Text('尝试退出'),
          ),
          OutlinedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('关于 Ianvs Design'),
                content: const Text('Material 3 组件基础与 macOS 桌面规范。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('关闭'),
                  ),
                ],
              ),
            ),
            child: const Text('AlertDialog'),
          ),
          OutlinedButton(
            onPressed: () async {
              final v = await showDialog<String>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('选择启动方式'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () => Navigator.of(context).pop('Shell'),
                      child: const Text('Shell'),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.of(context).pop('ACP'),
                      child: const Text('ACP'),
                    ),
                  ],
                ),
              );
              if (mounted && v != null) notice('已选择 $v');
            },
            child: const Text('SimpleDialog'),
          ),
        ]),
        outcome(),
      ]),
      section('底部面板', '使用真实模态路由，内容独立滚动并正确返回结果。', [
        OutlinedButton(
          onPressed: () async {
            final v = await showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '创建新项目',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    for (final label in ['从模板创建', '导入现有项目', '空白项目'])
                      ListTile(
                        title: Text(label),
                        leading: const Icon(Icons.folder_outlined),
                        onTap: () => Navigator.of(context).pop(label),
                      ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('取消'),
                    ),
                  ],
                ),
              ),
            );
            if (mounted && v != null) notice(v);
          },
          child: const Text('打开底部面板'),
        ),
      ]),
    ],
  );

  Widget foundations() {
    final t = context.ianvs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        section('色彩与表面', '颜色来自 ColorScheme 与 IanvsTokens，切换明暗模式会更新全部控件。', [
          flow([
            for (final e in [
              ('Canvas', t.canvas),
              ('Chrome', t.chrome),
              ('Field', t.field),
              ('Selected', t.selected),
              ('Accent', t.accent),
              ('Focus', t.focus),
              ('Success', t.success),
              ('Warning', t.warning),
              ('Danger', t.danger),
            ])
              SizedBox(
                width: 116,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: e.$2,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: t.border),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(e.$1),
                    Text(
                      '#${e.$2.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ]),
        ]),
        section('字体层级', 'macOS 使用系统字体；正文与控件保持清晰、紧凑的层级。', [
          Text(
            '页面标题 · Ianvs design',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            '区块标题 · Material 与 macOS',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Text('正文与标签 · 同一套组件用于每个应用。'),
          Text(
            '辅助信息 · 用语义和布局表达关联。',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ]),
        section('尺寸、动效与交互', '尺寸是最小值；较大文字会让控件自然增长。', [
          Text(
            '当前密度：${t.density.name}；控件 ${t.controlHeight.toInt()}；行高 ${t.rowHeight.toInt()}；圆角 ${t.controlRadius.toInt()}。',
          ),
          const Text(
            '间距：4 / 8 / 12 / 16 / 24 / 32 / 40。\n动效：120 / 180 ms；尊重减少动画设置。\n键盘：Tab / Shift+Tab 遍历，Enter / Space 激活，Esc 关闭覆盖层。\n原生窗口控制、菜单栏和应用数据由宿主提供。',
          ),
        ]),
      ],
    );
  }
}
