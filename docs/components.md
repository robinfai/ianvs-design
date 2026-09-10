# 组件 API 与交互契约

所有尺寸均为 Flutter 逻辑像素。Material 控件沿用官方 API；这里列出 Ianvs 的补充 API 与组合方式。

| API | 用途 | 状态所有权与约定 |
| --- | --- | --- |
| `IanvsTheme.light/dark/build` | Material 3 + Ianvs 主题 | build 支持 density、accent、platform、base 与字体；ThemeExtension 支持 copyWith / lerp |
| `IanvsTypography` | 代码、路径与工具输出排版 | `of(context).code` / `context.ianvsTypography.code`；build 可传 `monoFontFamily`、`monoFontFamilyFallback`、`codeTextStyle` |
| `IanvsResizeHandle` | 受控面板尺寸调整 | value/min/max/onChanged；axis 表示尺寸方向，reverse 用于右/下侧面板；宿主持有布局和可见性 |
| `IanvsButton` | 主、色调、高亮、描边、文字、危险操作 | onPressed 支持 Future；内部忙碌状态阻止重复触发；loading 可由外部控制；onError 接收失败，否则上报 FlutterError |
| `IanvsIconButton` | 图标操作 | 必填 tooltip，同时作为无障碍名称；支持 focusNode、selected、禁用 |
| `IanvsTextField` | 统一 TextFormField | controller 与 initialValue 互斥；validator / onSaved / autovalidateMode 遵循 Form；外部 controller / FocusNode 由宿主销毁 |
| `IanvsSelect<T>` / `IanvsOption<T>` | 类型安全选择 | value 随父更新同步，onChanged 返回值；支持 disabled option、Form 保存/校验/重置；重置为当前父组件传入的初始值 |
| `IanvsSearchField<T>` | 原位搜索与锚定建议 | 保持 SearchBar 位置、宽度和搜索图标；支持过滤、空结果、方向键、Escape与外部点击；controller / focusNode由调用方持有 |
| `IanvsMenuButton<T>` | 外观、密度与快捷菜单 | value / onSelected 受控；文字或图标触发器、禁用选项、方向键、关闭后返回焦点 |
| `IanvsAutocompleteOptions<T>` | 自动补全的主题选项面板 | 配合标准 Autocomplete.optionsViewBuilder；保留输入焦点和方向键选择，默认最大宽360 / 高280，内容按行高增长 |
| `IanvsFieldRow` | 对齐的表单标签与字段 | 默认标签宽170；内容小于480或字号大于1.5倍时纵向排列；helper 可换行 |
| `IanvsFormSection` | 标题、说明与成组字段 | 不创建业务 Form；内部提供焦点遍历分组 |
| `IanvsControlLabel` | 复选、单选、开关的可选择文字标签 | 单击执行与控件相同的操作；拖选、双击选词、长按和复制不触发；onTap 为 null 时禁用；controlBuilder 接收原生控件的 FocusNode |
| `IanvsSettingsRow` | 设置说明与开关 | value/onChanged 受控；标题和说明遵循 ControlLabel 的点击/文字选择规则；窄窗与放大字号自适应 |
| `IanvsSidebar` / `IanvsSidebarItem` | 分组导航 | selectedId/onSelected；支持 header/footer/badge；选择与焦点状态分开 |
| `IanvsToolbar` | 工具栏 | 最小52，供 Workspace 按文字缩放增长；title、leading、actions |
| `IanvsWorkspace` | 桌面窗口内容框架 | 默认侧栏262，宽度小于880切换真实 Drawer；不绘制伪装的系统窗口按钮 |
| `IanvsBanner` / `IanvsTone` | info/success/warning/danger | 文字、图标、actions 与 liveRegion；状态不能只靠颜色表达 |
| `IanvsEmptyState` | 空态与下一步操作 | 使用真实 IconData 与说明；不伪造图片 |
| `IanvsDialog` | 统一 AlertDialog | 可滚动内容与 actions；由 Navigator 管理 |
| `showIanvsConfirmDialog` | 确认流程 | 取消默认焦点；Escape/点击外部返回 false；危险确认单独样式；支持自定义文案 |
| `IanvsCascader<T>` / `IanvsCascadeOption<T>` | 多层级路径 | value 为受控路径，分支请求包含部分路径；新父级替换后代；面包屑只切换浏览层级；每组兄弟值须唯一，树数据按不可变数据使用 |
| `IanvsNumberStepper` | 整数数值设置 | min/max/step/value，onChanged 受控；输入或 ↑↓ 调整；Enter/失焦提交并限制范围；Esc/非法空草稿还原；父拒绝请求时还原 |
| `IanvsSkeleton` | 内容加载骨架 | loading/child；默认延迟200ms显示，保留 child 的布局尺寸，隐藏其交互和语义；尊重 MediaQuery.disableAnimations；lines/animate/label 可配置 |

## 扩展控件示例

`IanvsTypography.code` 是独立于普通 TextTheme 的等宽 TextStyle。默认13px/1.5（touch 16px），颜色取主题前景；macOS/iOS 默认 Menlo，Windows 默认 Consolas，Linux 默认 DejaVu Sans Mono，Android/Fuchsia 默认 monospace。平台字体只是请求的字体族与回退链，不保证该字体已安装；确定字体效果需要宿主打包字体并配置。`codeTextStyle` 最后按 `TextStyle.merge` 规则覆盖默认样式。IanvsTheme 重建自身的 Tokens/Typography 扩展，保留其他类型的宿主扩展。仅用 Material 主题时 `IanvsTypography.of` 也提供主题感知默认值。

`IanvsResizeHandle` 的 `axis: Axis.horizontal` 调整宽度、`Axis.vertical` 调整高度；`reverse: true` 将物理拖动方向反转，适用于右/下侧面板，与文字方向无关。`semanticLabel` 必填，可用 `semanticValueFormatter` 本地化尺寸读法。`step` 默认20，`hitExtent` 默认8（触控场景应由宿主提供更大命中区）。父容器必须为手柄的长度方向提供有限约束。

- `onChanged: null` 或 min=max 时禁用；所有请求限制在 min/max 内，父组件应用新 value 后才改变实际尺寸。
- 外部传入范围外的 value 会在手柄显示和操作中被限制，不自动修改宿主尺寸；宿主负责布局预算和窗口缩小时的尺寸修正。
- 方向键按物理方向移动分隔线；Home/End 请求最小/最大尺寸，语义 increase/decrease 始终表示尺寸增加/减少。
- 传入 `resetValue` 后双击或 Enter 重置，重置值也限制在范围内。带修饰键的快捷键交给宿主。
- FocusNode 可由宿主传入和销毁。隐藏面板时的焦点迁移、状态保持和持久化由宿主处理。

```dart
IanvsCascader<String>(
  options: const [
    IanvsCascadeOption(value: 'local', label: '本地', children: [
      IanvsCascadeOption(value: 'shell', label: 'Shell'),
    ]),
  ],
  value: selectedPath,
  onChanged: (path) => setState(() => selectedPath = path),
);

IanvsNumberStepper(
  label: '终端字号', value: fontSize, min: 8, max: 32,
  onChanged: (size) => setState(() => fontSize = size),
);

IanvsSkeleton(
  loading: isLoading,
  child: SizedBox(height: 144, child: projectSummary),
);
```

需要确定/取消的级联选择，可以在 `IanvsDialog` 内维护临时路径，确认后再提交给应用。级联控件本身不关闭路由、不加载远程树数据，也不会在父组件未接受路径时擅自推进层级。数字步进面向整数设置；小数范围可使用标准 Slider 或业务侧数值字段。

骨架屏以 child 的尺寸为布局依据；尚无内容时也需要为 child 提供稳定约束。库中的几何骨架是加载状态，不是头像或业务图片替代品。

## 无障碍与键盘

`IanvsControlLabel` 将标签和原生控件合并为一个无障碍目标。单击文字等待系统双击识别窗口结束后执行一次操作，避免双击选词时误切换；控件本体保持原生响应。文字仍可拖选、长按选择及复制，禁用标签也可选中文字。Tab 只停留在原生控件上，点击标签后将焦点交给控件，继续支持 Space 和单选组方向键。

```dart
IanvsControlLabel(
  label: '复选框',
  onTap: enabled ? () => setState(() => checked = !checked) : null,
  controlBuilder: (focusNode) => Checkbox(
    focusNode: focusNode,
    value: checked,
    onChanged: enabled ? (value) => setState(() => checked = value!) : null,
  ),
)
```

标签的 `onTap` 与原生 `onChanged` 必须更新同一份受控状态，并保持禁用条件一致；三态复选沿用 `false → true → null → false` 的循环。

- 通过 Flutter 的 Focus、Semantics 和 Material 控件实现 Tab / Shift+Tab、Enter / Space、菜单与弹窗的 Escape。
- Select 在键盘聚焦时显示2px轮廓。纯图标按钮提供名称；错误与忙碌状态保留文字和语义。
- Select 使用 MenuAnchor，在字段下方间隔4打开，菜单宽度为字段宽与360的较小值；紧凑选项行40，菜单圆角6、内边距4，选中项带勾，禁用项弱化且不可选择。
- SearchBar / SearchAnchor 的文字由自身布局居中；宿主不要给全局 InputDecorationTheme 设置固定最小高度，否则会影响其内部 TextField。IanvsTextField 自己持有最小高度约束。

标准 Autocomplete 的默认浮层没有独立 ThemeData 覆盖入口。需要 Ianvs 的浮层样式时显式提供选项视图（以下使用默认向下展开）：

```dart
Autocomplete<String>(
  optionsBuilder: (value) => connections.where(
    (name) => name.toLowerCase().contains(value.text.toLowerCase()),
  ),
  optionsViewBuilder: (context, onSelected, options) =>
      IanvsAutocompleteOptions<String>(
        options: options,
        onSelected: onSelected,
      ),
);
```
- Cascader 可用 Tab / Enter 逐级选择，↑↓ 在选项间遍历；面包屑可回溯。禁用分支不可进入。
- IanvsMotion.resolve(context) 提供减少动画时的零时长；宿主自定义动画应使用它。标准 Material 动效仍遵循 Flutter 与平台行为。
- 触控界面显式使用 touch 密度；桌面紧凑32px是有意的桌面规范，不代表移动端命中目标。

## 标准 Material 的集成边界

使用 IanvsTheme 后，控件状态仍由 Material 管理，例如 DatePicker 返回 DateTime、MenuAnchor 保留键盘菜单、DataTable 的排序与选中由应用回调处理。库没有为这些控件增加业务状态层。

可通过组件自身 `style` / `decoration` 做局部覆盖。主题额外令牌只影响读取该令牌的组合组件；改变标准 Material 尺寸应调整对应组件主题，避免只更改扩展令牌而形成两套样式。

## 下拉与菜单的统一规则

- 表单选择用 `IanvsSelect`；外观、密度和快捷操作用 `IanvsMenuButton`；可编辑的 Material 下拉使用标准 `DropdownMenu`；过滤建议使用 `IanvsAutocompleteOptions`。
- 菜单面板统一圆角6、边框1、内边距4、elevation4。选项最小行高依密度为40 / 48 / 56，正文14 / 14 / 17；选中、悬停和键盘高亮采用同一组选中前景 / 背景，键盘焦点额外显示2像素轮廓。禁用项不高亮。
- Select 的 hover 由 InputDecorator 在轮廓内部绘制，外层 InkWell 不叠加墨水色。输入内边距继承主题，避免与 DropdownMenu 高度不同。
- Select、DropdownMenu 采用最大360宽、最大320高的菜单。触发器自身宽度独立：表单中使用同样的 `IanvsFieldRow`，标准 DropdownMenu 设置 `expandedInsets: EdgeInsets.zero`，不使用默认的内容固有宽度；外部标签存在时省略浮动标签。
- 自动补全保持输入框焦点；选中行和悬停行通过共用菜单样式绘制。列表过长时键盘高亮会滚动进入视口。
- 旧版 PopupMenu 的表面主题已同步；原生 PopupMenuItem 的默认48行高不受主题控制。新代码推荐 IanvsMenuButton，避免混用旧默认列表和紧凑菜单。

```dart
IanvsMenuButton<ThemeMode>(
  tooltip: '外观模式',
  value: themeMode,
  onSelected: setThemeMode,
  icon: const Icon(Icons.light_mode_outlined),
  options: const [
    IanvsOption(ThemeMode.light, '浅色'),
    IanvsOption(ThemeMode.dark, '深色'),
    IanvsOption(ThemeMode.system, '跟随系统'),
  ],
)
```

传入 `child` 可使用带边框的文字触发器，`icon` 与 `child` 二选一；无 `value` 时作为操作菜单，不显示勾选列。禁用选项由 `IanvsOption.enabled` 控制。Down 打开、方向键遍历、Enter执行、Escape关闭并返回触发器焦点。

## 原位搜索

桌面表单使用 `IanvsSearchField<T>`，点击、输入或按 Down 后在原框下方4像素展开建议菜单。输入框保持当前宽度，建议菜单默认最大宽360、高280；窄窗口按可用宽度收缩。建议菜单可正常覆盖后续内容，但不会替换原框、切换返回箭头或推移其他字段。

```dart
IanvsSearchField<String>(
  hintText: '搜索连接',
  emptyText: '没有匹配的连接',
  optionIcon: Icons.terminal,
  options: const [
    IanvsOption('shell', 'Local Shell'),
    IanvsOption('server', 'Local Server'),
  ],
  onSelected: (connectionId) => openConnection(connectionId),
)
```

过滤按 label 忽略大小写进行子串匹配。Down / Up 跳过禁用项；Enter 选中当前高亮项并回填 label，onSelected 返回类型化 value。无高亮项时可通过 onSubmitted 提交自由查询。Escape 只收起建议并保留输入与焦点；再次点击或按 Down 可重开。点击其他字段关闭菜单并正常转移焦点。选择建议的鼠标事件属于输入的 TextFieldTapRegion，避免先失焦再回填。

Material `SearchAnchor` 仍由库导出并保留主题，适合需要独立搜索视图的流程；展厅中的“搜索连接”采用原位搜索，不再使用 SearchAnchor 的视图切换。
