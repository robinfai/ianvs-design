import 'package:ianvs_design/ianvs_design.dart';

class CatalogEntry {
  const CatalogEntry(
    this.id,
    this.title,
    this.description,
    this.icon,
    this.group,
    this.keywords,
    this.code,
  );
  final String id, title, description, group, keywords, code;
  final IconData icon;
  IanvsSidebarItem get item =>
      IanvsSidebarItem(id: id, label: title, icon: icon, group: group);
}

const entries = [
  CatalogEntry(
    'actions',
    '按钮',
    '清晰区分主次操作，覆盖所有 Material 按钮类型。',
    Icons.smart_button_outlined,
    '组件',
    'button filled tonal elevated outlined text icon fab segmented 操作 按钮 分段',
    '''IanvsButton(
  icon: Icons.add,
  onPressed: () async {
    await createProject();
  },
  child: const Text('新建项目'),
);
// FilledButton、IconButton 等也直接继承 IanvsTheme。''',
  ),
  CatalogEntry(
    'inputs',
    '输入与选择',
    '从输入到校验，让每一种选择都有明确反馈。',
    Icons.keyboard_outlined,
    '组件',
    'textfield form search dropdown select autocomplete checkbox radio switch slider range chip date time picker 输入 表单 复选 单选 日期 时间 芯片',
    '''Form(
  key: formKey,
  child: IanvsTextField(
    labelText: '名称',
    controller: nameController,
    validator: (value) => value!.trim().isEmpty ? '请输入名称' : null,
  ),
);
// RadioGroup、Slider、Chip、DatePicker 保留 Material API。''',
  ),
  CatalogEntry(
    'navigation',
    '导航',
    '侧栏、菜单和标签页，构成一致的桌面路径。',
    Icons.account_tree_outlined,
    '组件',
    'appbar navigation bar rail drawer tabs menu popup 导航 侧栏 菜单 标签',
    '''IanvsWorkspace(
  title: const Text('Ianvs App'),
  sidebar: IanvsSidebar(
    items: destinations,
    selectedId: selected,
    onSelected: selectDestination,
  ),
  body: currentPage,
);''',
  ),
  CatalogEntry(
    'feedback',
    '反馈',
    '用适当的容器和状态，表达进度、结果与下一步。',
    Icons.accessibility_new_outlined,
    '组件',
    'badge tooltip snackbar banner progress card divider list tile expansion data table 容器 卡片 列表 表格 反馈 提示 进度',
    '''IanvsBanner(
  tone: IanvsTone.success,
  message: '设置已保存',
  liveRegion: true,
);
// Card、DataTable、SnackBar、ProgressIndicator 自动应用主题。''',
  ),
  CatalogEntry(
    'supplements',
    '扩展组件',
    '级联选择、数字步进与骨架屏，补充桌面应用的常用交互。',
    Icons.widgets_outlined,
    '组件',
    'tdesign cascader number stepper skeleton 级联 步进 数字 骨架 扩展',
    '''IanvsNumberStepper(
  label: '终端字号',
  value: fontSize,
  min: 8,
  max: 32,
  onChanged: (value) => setState(() => fontSize = value),
);
// IanvsCascader 用受控路径表示层级；IanvsSkeleton 保留内容尺寸。''',
  ),
  CatalogEntry(
    'connection',
    '连接设置',
    '同一套组件，适用于 Terminal 与 ACP。',
    Icons.link,
    '应用模式',
    'form terminal acp shell settings 连接 设置 表单',
    '''IanvsFormSection(
  title: const Text('连接设置'),
  children: [
    IanvsFieldRow(
      label: '名称',
      child: IanvsTextField(
        controller: nameController,
      ),
    ),
  ],
);''',
  ),
  CatalogEntry(
    'workspace',
    '工作区',
    '组合导航、工具栏与内容，适应不同窗口大小。',
    Icons.folder_outlined,
    '应用模式',
    'workspace toolbar sidebar adaptive 工作区 工具栏 自适应',
    '''IanvsWorkspace(
  title: const Text('项目工作区'),
  sidebar: navigation,
  body: document,
  collapseAt: 880,
);
// 窄窗口中侧栏自动切换为可打开的 Drawer。''',
  ),
  CatalogEntry(
    'overlays',
    '确认与退出',
    '保留上下文，让保存、取消和退出都可预期。',
    Icons.logout_outlined,
    '应用模式',
    'dialog alert simple sheet confirm modal 弹窗 对话 确认 底部 面板',
    '''final discard = await showIanvsConfirmDialog(
  context: context,
  title: '放弃更改？',
  message: '尚未保存的修改将丢失。',
  confirmLabel: '放弃更改',
  cancelLabel: '继续编辑',
  destructive: true,
);''',
  ),
  CatalogEntry(
    'foundations',
    '设计规范',
    '可组合、可访问、可适配的设计基础。',
    Icons.tune_outlined,
    '规范',
    'theme token color typography spacing density motion 明暗 颜色 字体 间距 密度 规范',
    '''MaterialApp(
  theme: IanvsTheme.light(),
  darkTheme: IanvsTheme.dark(),
  themeMode: ThemeMode.system,
  home: const MyApp(),
);
final tokens = IanvsTokens.of(context);''',
  ),
];
