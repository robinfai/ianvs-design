# Ianvs Design 页面与组件状态设计评审

2026-09-10 · 基于当前工作区重新构建的 Flutter Web Gallery。

已采集 **133 张截图，验收 126 张**；7 张重复、状态未成功触发或错误标签页的截图保留在清单中，但不用于结论。有效截图分为 **12 组提交 ImageGen**。全部 9 个 Gallery 页面均包含桌面深浅主题和 480px 窄屏证据；另对输入、连接、扩展组件和确认弹窗采集 200% 文字缩放。

入口：[截图与评审图索引](index.html) · [逐张截图清单](manifest.json) · [ImageGen 输入分组](review-groups.json) · [完整提交提示词及生成记录](review-jobs.json)

整体判断：基础视觉语言、输入反馈和弹窗取消流程已经较完整。优先修复导航选中背景错位、切换连接场景后的陈旧错误提示，再处理日期换行和搜索空结果的位置。此次没有修改产品代码。

## 页面步骤与健康度

| 步骤 | 页面与已观察流程 | 健康度 | 原始证据 |
|---|---|---|---|
| 1 | 按钮：常规/图标/FAB、加载与异步完成、分段和多选、深浅主题、窄屏 | 基本良好；主次层级可继续精简 | [默认13](screenshots/13-actions-light-default.png)、[加载14](screenshots/14-actions-async-busy.png)、[结果16](screenshots/16-actions-selection.png)、[窄屏112](screenshots/112-actions-narrow.png) |
| 2 | 输入与选择：校验、密码显隐、搜索/自动补全、菜单、复选/单选/开关、滑块、Chip、日期时间 | 需改进；日期换行和时间选中色不统一 | [错误19](screenshots/19-inputs-error-password.png)、[保存20b](screenshots/20b-inputs-save-confirmed.png)、[选择30](screenshots/30-inputs-selection-changed.png)、[日期36](screenshots/36-inputs-date-entry.png) |
| 3 | 导航：AppBar、工具栏、导航栏/侧栏/抽屉、标签页、三类菜单 | 需优先修复；抽屉选中背景偏移 | [选中47](screenshots/47-navigation-selected.png)、[错位48](screenshots/48-navigation-lower-default.png)、[菜单50](screenshots/50-navigation-anchor-menu.png)、[复选菜单57](screenshots/57-navigation-checkbox-menu.png) |
| 4 | 反馈：徽标、Snackbar/撤销、Banner、进度、卡片/列表、展开、表格排序和选择、空状态 | 基本良好；深色文字操作的辨识度需量化检查 | [撤销60](screenshots/60-feedback-snackbar.png)、[展开66](screenshots/66-feedback-list-expanded.png)、[混合68](screenshots/68-feedback-table-sorted-selected.png)、[全选69](screenshots/69-feedback-table-select-all.png) |
| 5 | 扩展组件：级联选择/清空/父子路径、数字编辑/越界/撤销/禁用、骨架加载 | 基本良好；自动纠正数值可补解释 | [路径74](screenshots/74-cascader-empty.png)、[越界76](screenshots/76-stepper-edit-out-of-range.png)、[纠正77](screenshots/77-stepper-clamped.png)、[加载81](screenshots/81-skeleton-reloading.png) |
| 6 | 连接设置：启动菜单、保存中/已保存、错误、ACP、主题和密度、窄屏 | 需优先修复；错误残留和初始未保存状态误导 | [保存04](screenshots/04-connection-saving.png)、[错误06](screenshots/06-connection-validation.png)、[ACP07](screenshots/07-connection-acp.png)、[操作区111](screenshots/111-connection-narrow-save.png) |
| 7 | 工作区：概览/文件/设置、添加反馈、窄屏内容切换 | 基本良好；窄屏目的地提示可更明确 | [桌面85](screenshots/85-workspace-dark-default.png)、[设置87](screenshots/87-workspace-settings-new.png)、[窄屏107](screenshots/107-workspace-narrow.png)、[切换108](screenshots/108-workspace-narrow-switched.png) |
| 8 | 确认与退出：草稿、确认/取消/放弃、AlertDialog、SimpleDialog、底部面板及返回 | 良好；默认安全焦点和取消保留清楚 | [确认90](screenshots/90-confirm-light-open.png)、[取消91](screenshots/91-confirm-cancel-retains.png)、[放弃92](screenshots/92-confirm-discarded.png)、[大字131](screenshots/131-confirm-scale-200.png) |
| 9 | 设计规范及公共框架：色板/排版/尺寸、代码标签/复制、目录搜索/抽屉 | 规范页良好；搜索空结果位置需调整 | [规范104](screenshots/104-foundations-light-top.png)、[代码84](screenshots/84-code-tokens-copy.png)、[搜索106](screenshots/106-global-search-empty.png)、[抽屉109](screenshots/109-global-drawer-open.png) |

## 优先修复项

P1 表示会直接混淆当前状态，建议先处理；P2 表示明显的可用性或一致性问题；P3 为进一步优化。

### F01 · P1 · 导航抽屉选中背景与选中项分离

[截图48](screenshots/48-navigation-lower-default.png)、[截图55](screenshots/55-navigation-dark-lower.png)中，项目的图标和文字在左侧，蓝色选中矩形却位于容器中间。用户需要凭文字颜色猜当前目的地，选中区域也失去清晰归属。窄屏[115](screenshots/115-navigation-narrow-lower.png)偏移减小，背景仍未完整覆盖图标。

建议让图标、标签和选中背景使用同一行布局；若此示例用于展示真实 Drawer，应约束示例容器为合理抽屉宽度，再检查全宽容器下的表现。复测三个目的地、深浅主题和窄屏。

实现入口：[NavigationDrawer 示例](../../../example/lib/gallery/stories.dart:604)、[导航抽屉主题](../../../lib/src/foundation/theme.dart:381)。这里只定位调查入口，不将默认框架行为直接归因于自定义主题。

### F02 · P1 · 连接场景切换后保留过时的必填错误

启动命令为空并提交后，[06](screenshots/06-connection-validation.png)显示必填错误。切换 ACP 自动填入 `npx` 后，[07](screenshots/07-connection-acp.png)仍显示红框和“请输入启动命令”。有效值与错误提示矛盾，会让用户以为配置无效。

建议在程序填充场景字段后重新验证已显示错误的字段，或清除对应旧校验状态；同时保留其他真实错误。复测通用、Terminal、ACP 相互切换。

实现入口：[chooseScenario](../../../example/lib/gallery/connection.dart:81)。它更新控制器，但当前分支没有刷新表单校验状态。

### F03 · P2 · 日期输入模式拆开中文语义单位

[36](screenshots/36-inputs-date-entry.png)、[37](screenshots/37-inputs-date-invalid.png)将“周四”拆成两行；[40](screenshots/40-inputs-range-entry.png)将结束日期的“9月14日”从“9”后断开。应按完整日期、星期或起止日期分行；不要仅靠把字号压小解决。

建议调整输入模式的标题宽度和文本样式，明确允许的分行点，并用长日期与200%文字复测。月历模式[34](screenshots/34-inputs-date-picker.png)将完整“周四”放到下一行本身是合理的，不能和输入模式的拆字混为一谈。

### F04 · P2 · 目录搜索空结果远离输入框

搜索无匹配时，[106](screenshots/106-global-search-empty.png)的“没有匹配的组件”出现在侧栏底端，输入框下方留下整片空白。反馈与触发动作相隔很远，容易误认为仍在加载。

建议把空结果放在结果列表起始位置，并提供就近的清空操作。实现入口：[将空提示放入 footer 的位置](../../../example/lib/gallery/gallery.dart:132)。

### F05 · P2 · 连接页保存操作不易在首屏发现

桌面[02](screenshots/02-connection-dark-default.png)中，固定代码区压缩表单可视高度；舒适/触控密度[11](screenshots/11-connection-comfortable.png)、[12](screenshots/12-connection-touch.png)进一步增加滚动需求。窄屏[110](screenshots/110-connection-narrow.png)需滚动后才能看见[111](screenshots/111-connection-narrow-save.png)中的保存和取消。

操作可以通过滚动访问，问题是发现成本，不是按钮永久消失。建议折叠或允许调整代码区高度，或将表单操作固定在所属表单底部；避免固定栏再遮挡字段与错误提示。

### F06 · P2 · 初始连接表单显示未保存更改

重新进入连接页后，尚未修改的默认数据在[111](screenshots/111-connection-narrow-save.png)中显示“有未保存的更改”。[源代码](../../../example/lib/gallery/connection.dart:26)将 `dirty` 初始化为 true，而初始字段与 `saved` 相同。

建议从草稿与已保存值比较得出初始状态。若有意演示待保存场景，应在示例说明中直接写明。

### F07 · P2 · 时间选择器的上午选中色脱离主要选中体系

[41](screenshots/41-inputs-time-clock.png)、[42](screenshots/42-inputs-time-entry.png)中，时钟和小时使用蓝色，但“上午”使用紫色。建议为时段明确设置与其他选中控件一致的背景/前景规则，或在设计规范里解释这种语义区分。实现入口：[TimePickerTheme](../../../lib/src/foundation/theme.dart:583)。

## 可进一步优化与待验证

| 项目 | 观察与建议 | 依据/限制 |
|---|---|---|
| P3 首屏工具层级 | 窄屏“复制示例”以强蓝色按钮独占一行，密度控件又占一行。可整合成工具行，让组件内容更早出现。 | [112](screenshots/112-actions-narrow.png)、[113](screenshots/113-inputs-narrow.png)、[117](screenshots/117-supplements-narrow.png)；这是组件库工具层级建议，不是业务转化结论。 |
| P3 数值纠正说明 | 输入99提交后自动变为32；可增加“范围8–32”或轻量纠正说明，解释变化。 | [76](screenshots/76-stepper-edit-out-of-range.png)→[77](screenshots/77-stepper-clamped.png)；Esc恢复已提交值在78中可见。 |
| P3 工作区窄屏目的地 | “切换内容”能完成切换，但不预告下一目的地，也不提供直接选择。可使用带当前值的目的地菜单。 | [107](screenshots/107-workspace-narrow.png)→[108](screenshots/108-workspace-narrow-switched.png)；此处为插槽示例，空白正文不当作生产缺陷。 |
| 待量化：深色文字操作 | 重试、撤销、底部面板取消等蓝字在深色背景上视觉偏弱。应按真实前景/背景与字号测量，再确定色值。 | [59](screenshots/59-feedback-dark-top.png)、[60](screenshots/60-feedback-snackbar.png)、[100](screenshots/100-bottom-sheet-dark.png)。未测WCAG比值，不宣称合规或不合规。 |
| 待复现：菜单互斥 | 52中快捷菜单与文件菜单同时存在。需用连续鼠标/键盘交互重现并确认关闭和焦点策略。 | [52](screenshots/52-navigation-menubar-file.png)。自动化焦点可能影响操作顺序，本次不将它作为已确认功能缺陷。 |
| 待观察：大字弹窗留白 | 200%标题与弹窗顶边距离很小，但文字和按钮完整。可增加内容留白并检查更长文案。 | [131](screenshots/131-confirm-scale-200.png)，不报告文字被裁切。 |

## 组件状态覆盖表

以下编号均对应索引中的原始截图。相同视觉实现按组件族记录，不把每个按钮的相同点击反馈重复截图。

| 组件族 | 已捕获状态 | 证据编号 |
|---|---|---|
| Filled / Tonal / Elevated / Outlined / TextButton | 常规、禁用、加载示例、深浅主题 | 13、14、17、112 |
| IanvsButton 异步与危险操作 | 执行前、执行中、完成反馈；危险按钮打开确认 | 13、14、16、90、99 |
| IconButton / FAB | 普通、填充、色调、禁用示例、选中切换；三种FAB尺寸 | 13、16、17、112 |
| SegmentedButton / ToggleButtons | 单选切换、多项选中 | 16、17；连接03、07 |
| IanvsTextField / Form / FieldRow | 空白、填入、焦点、必填错误、提交成功、禁用、多行 | 18、19、20b、45、113、124 |
| 密码输入 | 隐藏、显示 | 18、19 |
| SearchField | 默认、展开、无结果、键盘高亮、选中结果 | 21b、22、23、24 |
| Autocomplete | 输入与候选展开 | 25；候选确认未单独截图 |
| IanvsSelect / Dropdown | 当前值、展开、焦点、禁用选项 | 03、26、27 |
| Checkbox / 三态 | 选中、未选、混合、禁用 | 29、30 |
| Radio / Switch | 选中/未选、开/关、禁用开关 | 29、30、44 |
| Slider / RangeSlider | 初值、改变、范围端点、拖动值提示 | 28、29、30、31 |
| Action / Filter / Choice / InputChip | 默认、单选、多选、InputChip选中与删除后恢复入口 | 31、32、33、38、43 |
| DatePicker | 月历、年份、输入、格式错误 | 34、35、36、37 |
| DateRangePicker | 范围月历、输入模式 | 39、40 |
| TimePicker | 表盘、输入模式、上午选中 | 41、42 |
| AppBar / BottomAppBar | 标题、返回、搜索、菜单、添加等可见入口 | 46、56、114；各入口的同类提示反馈未重复采集 |
| NavigationBar / Rail / Drawer | 初值、切换项目、关联内容、深浅主题、窄屏 | 46–49、55、56、114、115 |
| Tabs | 默认预览、切换规范；文档三标签 | 48、49、80、83、84 |
| MenuAnchor / PopupMenu / MenuBar | 展开、选中焦点、禁用项、选择结果、复选菜单展开 | 50–53、57、58；58仅证明关闭，不证明重开后的未勾选外观 |
| Badge / Snackbar | 计数变化、操作提示、撤销及结果 | 59、60、61、63 |
| Tooltip | 触发按钮可见和点击反馈 | 63；悬停气泡未成功捕获，64已排除 |
| MaterialBanner / IanvsBanner | 持续提示、关闭入口；信息/成功/警告/错误样式 | 59、62、72、85、116 |
| ProgressIndicator | 圆形/线形、确定与不确定进度 | 59、72、116；静态帧不用于评价动画流畅度 |
| Card / ListTile / Divider | 容器、说明、操作入口、分组线 | 65、66 |
| CheckboxListTile / SwitchListTile / RadioListTile | 开关及选择前后 | 65、66 |
| ExpansionTile | 收起、展开 | 65、66 |
| DataTable | 初值、名称倒序、单行选择、表头混合、全选 | 67、68、69、71 |
| EmptyState | 空内容、主操作、示例操作反馈 | 67、70；示例未创建真实项目数据 |
| Cascader | 三级路径、清空、父级、叶级选中、禁用叶级 | 73–76、79、117、127、128 |
| NumberStepper | 默认/上下界/禁用、编辑99、提交32、Esc恢复 | 73、76–79、117、128 |
| Skeleton | 加载示意、真实重载期间、恢复内容、响应式排列 | 80、81、84、118、129 |
| Workspace / Toolbar / Sidebar | 概览、文件、设置、添加反馈、窄屏切换 | 85–88、107、108 |
| ConfirmDialog | 打开、安全焦点、Esc取消保留、确认清空、深浅/窄屏/大字 | 90–92、99、120、131 |
| AlertDialog / SimpleDialog | 打开、选项、选择后返回 | 93–95 |
| BottomSheet | 深浅打开、窄屏、选择结果 | 96、97、100、121 |
| Theme / Density / Tokens | 深浅、跟随系统菜单项、紧凑/舒适/触控 | 08–12、101–104；未模拟操作系统主题变化 |
| 全局目录搜索 / Drawer | 快捷键聚焦、匹配、无匹配、清除入口、窄屏抽屉 | 105、106、109 |
| CodePanel | 使用示例、交互约定、设计变量、复制反馈、窄屏折叠入口 | 80、83、84、110；折叠入口展开未单独截图 |

## ImageGen 输出复核

ImageGen 收到了全部126张有效截图对应的拼版输入。拼版仅在截图外增加编号与间隔，原始截图未裁剪、缩放或修饰。生成的评审图是视觉意见，可能重绘局部、混用编号或产生不受证据支持的描述；**产品现状以 screenshots 原图为准，采纳结论以本报告为准**。

生成图中需要纠正的内容：

- 按钮图把空闲异步按钮当成缺少加载提示：不采纳；14已显示执行中状态，16有完成反馈。
- 连接图把 `npx` 旁仍存在的必填错误当作校验清晰：不采纳；应作为F02修复。
- 输入选择图把InputChip删除后描述为仍有“×”状态：不采纳；38实际显示“恢复标签”。
- 日期图将34/35的正常完整星期换行也当作“周四拆字”，并把居中模态描述为锚点弹层：不采纳；F03只依据36/37/40。
- 导航图的部分箭头指向全局左侧栏：定位不准确；F01发生在主内容中的NavigationDrawer示例。52展示的是文件菜单与快捷菜单同时存在，不是两个导航目的地同时选中。
- 反馈图重绘了68的表格选择数量；原图实际为单行选中、表头混合状态。浮层图将97画成仍打开的面板；原图实际为选择后返回结果。
- 工作区图把“切换内容”描述为图标控件：不采纳；实际是文字按钮，当前内容标题也已可见，改进点仅是目的地预告和直接选择。
- 响应式图中的“全部通过”不能作为验收结论；大字检查只包含本报告列出的四类样本，不能外推到所有页面或完整无障碍合规。
- “浅深主题颜色不同”本身不构成不一致；应检查语义、层级和状态辨识是否保持，而不是要求两个主题使用相同色值。

各组原始生成图保留在 `reviews/`，完整提示词保留在 `prompts/`。索引将原图、状态说明和生成建议放在一起，方便复核。

## 范围与证据限制

- 范围是当前 `example` Gallery 的全部9页及其可见组件；不是宿主App、原生macOS窗口控制或未展示的所有API组合。
- 桌面主视口1440×1000；窄屏480×900；初始窗口836×942；200%文字使用1280×720。大字检查是应用提供的 `scale=2`，不是浏览器页面缩放。
- 覆盖组件族的主要静态和操作前后状态；没有穷举“每个实例 × 每个主题 × 每种密度 × 所有输入值”的组合。缺少Tooltip悬停气泡、逐个组件的hover/按住瞬间、完整键盘遍历、所有日期/时间提交分支与操作系统主题/减少动画变化。
- 已观察搜索方向键选择、焦点边框、确认弹窗默认焦点、Esc取消与草稿保留；没有屏幕阅读器朗读、完整焦点陷阱、对比度数值或所有触控目标尺寸的验证，不能据此宣称完整无障碍合规。
- 加载截图用于检查可见状态，不证明性能或动画时序达标；部分截图保留了上一操作尚未消失的Snackbar，清单按实际页面状态解释。
- 本次完成了Web release构建和浏览器交互检查，没有执行或声称通过完整自动化测试套件。
