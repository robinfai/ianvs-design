# Ianvs Design · 设计与实现验收

final result: passed

验收日期：2026-09-10。范围为 `ianvs_design` 基础库及 macOS / Web 组件展厅。当前没有待处理的 P0 / P1 / P2 问题。结论来自设计对照、真实渲染、实际操作及测试；不表示逐像素复制，也不代表已完成下游应用迁移。

## 用户追加反馈：搜索展开交互

用户反馈：[关闭状态](docs/design/references/search-transition-before-closed.png)、[展开状态](docs/design/references/search-transition-before-open.png)。原先 SearchAnchor 会从通栏搜索框切换为较窄的独立搜索视图，并将放大镜替换为返回箭头，造成表单内搜索的视觉跳变。

本轮新增可复用 `IanvsSearchField<T>`，以 SearchBar + MenuAnchor 在原位输入、在字段下方展示筛选建议。输入框、图标和相邻字段不因展开或关闭而改变位置；建议浮层可以覆盖下方内容，不占用表单布局。菜单最大宽360、高280，与字段间隔4，沿用共享的6圆角、4内边距和紧凑40行高。

| 发现 | 修复与复验 |
| --- | --- |
| P2 · 展开导致输入框缩窄和图标变化 | 改为原位搜索；明暗×三档密度对比展开前后输入框及相邻字段矩形完全一致，始终保留搜索图标 |
| P2 · 桌面鼠标点击建议时输入失焦 | 建议项加入 TextFieldTapRegion，使用真实 mouse 指针事件验证选择、回填、关闭且输入保留焦点 |
| P2 · 点击空白区域关闭后又重新展开 | 焦点恢复通知只负责失焦关闭；由点击、文字变化或方向键显式展开，避免 MenuAnchor 还原焦点时循环打开。最终实测和回归验证外部空白点击关闭 |

将用户源图与实际明暗关闭 / 展开截图联合查看，比较字体、间距、色彩、图标、内容及形状。实际截图均为1280×900 / DPR1，同一滚动位置，搜索字段边界 x303–1239、y429–461，展开前后不变；菜单位于字段下方，边界 x303–663、y465–593。源图是不同尺寸的局部截屏，未提供逻辑视口，因此只比较交互前后的结构变化，不从源图推断逻辑尺寸。输入蓝框表示保留的焦点状态。此轮没有新增运行时图片；继续使用 Material 图标及已有字体。

实拍：[深色关闭](docs/screenshots/search-in-place-dark-closed.png)、[深色展开](docs/screenshots/search-in-place-dark-open.png)、[浅色关闭](docs/screenshots/search-in-place-light-closed.png)、[浅色展开](docs/screenshots/search-in-place-light-open.png)、[480×800浅色展开](docs/screenshots/search-in-place-light-narrow.png)。窄屏菜单保持在可见区域内，字段没有横向溢出。

实际 Web 验证了连续输入筛选、loc → Down + Enter 回填 Local Server、鼠标选择 Codex、Escape关闭、点击其他字段和空白区域关闭。新增10项回归覆盖布局稳定、文字居中、菜单边界、空结果、键盘与鼠标选择以及外部控制器 / 焦点所有权。总计119项测试（库62 + 展厅57）通过；最后的焦点关闭调整另行重跑10项受影响测试通过。静态分析无问题，Web和macOS Release均构建成功；本轮没有重复进行原生人工操作，原生交互结论仍限定于此前记录。最终[浏览器警告与错误日志](docs/verification/search-browser-console.json)为空。

[ImageGen 联合差异标注](docs/design/reviews/search-in-place.png)同时输入用户关闭 / 展开源图、实际深色关闭 / 展开和浅色展开截图。生成板重排并简化了界面，部分菜单宽度比例和选中底色并非实拍，仅用于说明交互变化；精确尺寸与状态判断采用上方原始截图和测试。实际截图比较后，本轮没有遗留P0 / P1 / P2。最终预览恢复浏览器原始视口，停留在深色输入与选择页。

## 用户追加反馈：悬停边界与下拉布局

本轮用户截图：[hover 与布局反馈](docs/design/references/select-hover-layout-reported.png)，1612×662。截图为局部高密度图，逻辑视口和 DPR 未提供；不能据此推算逻辑像素。最终 Web 截图为1280×900 / DPR1，明暗相同滚动位置。对比聚焦搜索区和两个下拉框，不比较侧栏与源截图外的部分。

| 问题 | 修复 | 验证 |
| --- | --- | --- |
| P2 · 连接类型 hover 底部露出色带 | 禁止外层 InkWell 绘制叠加色；将 hover 交给 InputDecorator 在轮廓内绘制 | 明暗×三档密度，鼠标移入前后对比原始 RGBA：轮廓内像素发生变化，轮廓外及辅助文字区变化为0 |
| P2 · 两类下拉标签和尺寸不一致 | 同用 IanvsFieldRow，外置单一标签；DropdownMenu 使用 expandedInsets 填满字段列；共享输入内边距，限制箭头占位宽度 | 明暗×三档密度测量可见高度、文字中心、箭头右间距；1487与480窗口字段左右边界及外部高度一致 |
| P2 · 菜单视觉状态分散 | 共用 IanvsMenuStyle：Select、Material DropdownMenu、自动补全及 IanvsMenuButton 采用同一选中背景、前景和焦点轮廓；外观、密度、快捷菜单迁移到统一触发器 | 比较实际渲染 Material 颜色、文字14及紧凑行高40；键盘跳过禁用项并返回触发器；实拍见下 |
| P2 · 走查中发现密度菜单最小宽度未生效 | MenuAnchor 关闭 crossAxisUnconstrained，落实最小宽160，避免菜单只按短文字收缩 | 菜单行宽至少152的回归检查；最终密度菜单截图复查 |

对比记录：用户反馈源与修复后关闭状态、展开菜单在同一视觉比较输入中查看；普通输入中移除多余浮动标签，连接类型与应用场景单独成行，两者横向对齐。深色背景、浅色背景、细边框、蓝色焦点环以及禁用色均按原有令牌。关闭截图的蓝框是 Escape 返回后的键盘焦点，不把它当作纯 hover 的实拍；纯 hover 边界由真实 Flutter 鼠标事件与像素差分验证。

- 字体 / 内容：字段正文14（触控17），菜单统一相同正文；中英文值保持原样，字段标签简化为连接类型 / 应用场景；辅助功能可读取应用场景当前值。
- 布局 / 色彩：两类字段等宽、等高、箭头对齐；菜单圆角6、内边距4、elevation4、紧凑行高40；选中蓝色与键盘轮廓统一，自动补全的焦点仍留在输入框，不人为增加菜单焦点环。
- 资产：本轮不新增运行时图像或图标，仍用 Material 图标；ImageGen 仅生成差异标注示意，像素、尺寸及测试结论以原始截图和回归测试为准。
- 功能：Web 标准下拉 Down + Enter 选择 Terminal 并更新当前值语义；自动补全 loc → Down + Enter 回填 Local Server；实际点击外观切换明暗；Select 与菜单 Escape、方向键、禁用项由新增及既有测试覆盖。

原始截图：[深色布局](docs/screenshots/menus-layout-dark-v2.png)、[浅色布局](docs/screenshots/menus-layout-light-v2.png)、[深色 Select](docs/screenshots/menus-select-dark-v2.png)、[浅色 Select](docs/screenshots/menus-select-light-v2.png)、[深色 Material 菜单](docs/screenshots/menus-material-dark-v2.png)、[浅色 Material 菜单](docs/screenshots/menus-material-light-v2.png)、[浅色自动补全](docs/screenshots/menus-autocomplete-light-v2.png)。浅色应用场景为键盘验证后的 Terminal，深色为通用，内容差异不是排版差异。

本轮新增17项回归测试，总计109项（库52 + 展厅57）。最后的箭头 / 菜单宽度调整另行重跑15项受影响测试通过；静态分析无问题。Web / macOS Release 构建同步更新。最终补充实拍：[深色密度](docs/screenshots/menus-density-dark-v2.png)、[浅色密度](docs/screenshots/menus-density-light-v2.png)、[深色外观](docs/screenshots/menus-appearance-dark-v2.png)、[浅色外观](docs/screenshots/menus-appearance-light-v2.png)。实际鼠标坐标点击密度菜单后，Escape 关闭并将焦点交还“紧凑”；辅助功能自动点击的焦点行为与坐标点击不同，未用其异常推断产品键盘故障。最终15项受影响库测试和11项展厅交互 / 布局测试通过。

[ImageGen 联合标注图](docs/design/reviews/menus-hover-layout-v2.png)同时输入用户截图、明暗关闭布局、深色Select展开与浅色Material展开图，集中标注源图色带和不等宽布局，以及修复后的标签、箭头和菜单边界。生成图会重排源图，不是像素真值。五项视觉表面复查后，本轮未发现遗留P0/P1/P2；旧版PopupMenuItem的默认48行高作为Material API边界已在组件文档说明，展厅中的选择与快捷菜单都已统一。

最终补充[480×800 浅色布局](docs/screenshots/menus-layout-narrow-v2.png)：两个标签均移至各自字段上方，字段等宽，值与箭头对齐，页面可滚动。最终浏览器 error / warn 日志为空。所有已发现的本轮 P2 问题已修复并重新比较；最终预览保留在输入与选择页，已恢复浏览器原始视口。

## 用户反馈复验：搜索对齐与下拉展开状态

用户提供的三张截图暴露了首轮验收对搜索及默认选项浮层检查不足。此次补充检查并修复如下问题；此前的通过结论不应被解释为这些展开状态当时没有问题。

| 发现 | 原因与修复 | 复验证据 |
| --- | --- | --- |
| P2 · 搜索提示 / 输入文字偏上 | 全局 InputDecorationTheme 的最小高度进入 SearchBar 内部 TextField；移除全局约束，由 IanvsTextField 自己持有最小高度，SearchBar 依自身布局居中 | [用户反馈](docs/design/references/search-alignment-reported.png)、[展开搜索修复后](docs/screenshots/search-expanded-dark-fixed.png)；明暗×三档密度的关闭 / 展开文字中心坐标检查 |
| P2 · 下拉样式未统一 | 旧 DropdownButton 展开路由沿用默认列表与阴影，禁用文本没有显著区分；Select 改用 MenuAnchor，圆角6、内边距4、行高40，宽度限制360，字段下方间隔4，选中勾与禁用色明确 | [用户反馈](docs/design/references/select-menu-reported.png)、[深色修复后](docs/screenshots/select-dark-fixed.png)、[浅色修复后](docs/screenshots/select-light-fixed.png) |
| P2 · 自动补全面板为通栏列表 | 标准 Autocomplete 默认 optionsView 没有独立主题入口；增加可复用 IanvsAutocompleteOptions，通过标准 optionsViewBuilder 对接，采用紧凑带边框浮层，保留过滤和键盘选择 | [用户反馈](docs/design/references/autocomplete-reported.png)、[深色修复后](docs/screenshots/autocomplete-dark-fixed.png)、[浅色修复后](docs/screenshots/autocomplete-light-fixed.png) |

实际截图使用1280×900 / DPR1；用户截图是不同尺寸的局部高密度截屏，未提供CSS视口和DPR，因此只比较相同控件状态的排版、边界、层级，不推断源图逻辑尺寸。ImageGen将用户反馈与实际修复截图共同输入，生成[联合对照](docs/design/reviews/search-menu-fix.png)；关闭搜索框、展开Select和自动补全使用对应状态比较，展开搜索额外作为修复后细节展示。生成图仅为标注插图，原始实拍和坐标测试为准。

实际Web操作确认：自动补全输入loc后，Down + Enter回填Local Server；Select方向键选择SSH后回填并归还焦点；Escape关闭菜单；明暗切换后浮层样式一致。[标准Material DropdownMenu](docs/screenshots/material-dropdown-dark-fixed.png)也继承统一的6圆角、菜单文字和行高。最终浏览器error / warn日志为空。该轮新增10项回归测试，当时总计92项通过。此次修改没有增加运行时图片资产，仍使用系统 / 展厅字体与Material图标。

## 视觉真值、状态与比较证据

| 项目 | 证据 |
| --- | --- |
| 用户选定深色稿 | [graphite-dark.png](docs/design/references/graphite-dark.png)，1487×1058 像素 |
| 对应浅色稿 | [graphite-light.png](docs/design/references/graphite-light.png)，1487×1058 像素 |
| 实际深色 | [browser-dark-final.png](docs/screenshots/browser-dark-final.png)，1487×1058 像素 |
| 实际浅色 | [browser-light-final.png](docs/screenshots/browser-light-final.png)，1487×1058 像素 |
| 第一轮联合比较 | [dark-pass-1.png](docs/design/reviews/dark-pass-1.png) |
| 修复后的明暗联合比较 | [light-dark-final.png](docs/design/reviews/light-dark-final.png) |
| 扩展组件联合比较 | [supplements-final.png](docs/design/reviews/supplements-final.png)；同时输入[设计板](docs/design/references/supplements-board.png)、[实际深色](docs/screenshots/supplements-dark.png)和[实际浅色](docs/screenshots/supplements-light.png) |

主对照状态：连接设置 → 通用 → 紧凑；名称 Local Shell、命令 /bin/zsh、目录 ~/Projects/ianvs、登录 Shell、恢复开关开启、未保存提示。浏览器 CSS 视口 1487×1058，DPR 1；源图与实际截图尺寸相同，无额外缩放或裁切。源图未提供逻辑密度元数据，因此按 1:1 画布比较整体布局，同时以规范中的逻辑尺寸验收控件。浅色实拍保留主题按钮的键盘焦点环，与静态稿无焦点的状态差异已单独识别。

ImageGen 每轮都同时收到设计源和实际截图，用于联合比较与标注。生成的对照图会重采样文字和图形，属于设计师标注插图；原始 PNG、Flutter 控件状态与测试是判定依据，不能从生成图推导精确色值、尺寸或测试结论。

重点区域比较包括：顶部场景分段与密度选择；名称标签和字段列；右侧默认 / 焦点 / 错误状态；保存操作与代码标签；扩展控件的路径、边界禁用和加载结构。原始 1487 像素截图中这些文字与边界可读，配合联合比较逐项检查；没有把不可读的缩略图作为精细验收依据。扩展比较板专门放大了三个组件区域。

## 发现、修复与复验历史

| 级别 / 位置 | 早期证据与影响 | 修复 | 修复后证据 |
| --- | --- | --- | --- |
| P1 · 字体与输入密度 | [最初浏览器截图](docs/screenshots/browser-dark-before.png)中字体回退与重复密度压缩导致字号、字段高度偏离桌面规范 | Web 展厅提供中文字体；主题使用标准 VisualDensity，32 为控件最小高度 | 最终明暗截图；包内密度 / 文字缩放测试 |
| P2 · 连接表单对齐 | 第一轮对照显示字段列、分段宽度、主操作尺寸、代码标签位置偏移，降低与选定稿的一致性 | 标签列170；字段起点 x474；普通字号场景分段350；主操作114×44；调整代码标签与底部间距；字段值14、标签13 | [明暗最终对照](docs/design/reviews/light-dark-final.png)与原始最终截图 |
| P2 · 主题状态 | 通用 ButtonStyle 覆盖会使 primary / tonal 或 IconButton 变体丢失自身色彩层级 | 只统一尺寸与形状，保留各 Material 变体的前景和背景解析 | [操作页](docs/screenshots/material-actions-dark.png)；真实 Material 渲染颜色断言 |
| P2 · 扩展面板 | 级联面板被父级紧约束拉满，列表层级过于松散 | Align 后限制 maxWidth 520，保持窄屏可收缩；步进按钮增加独立边框 | [扩展最终对照](docs/design/reviews/supplements-final.png)、[窄屏扩展](docs/screenshots/supplements-narrow.png) |
| P2 · 图标操作语义 | 加减按钮名称与按钮角色分散在不同语义节点；选择示例缺少关联名称 | Tooltip + MergeSemantics；复选、单选和开关关联标签；InputChip 支持选择 / 删除 / 恢复 | Web AX 中按钮名称为“增加 终端字号”等，禁用边界明确；[输入页](docs/screenshots/material-inputs-light.png)；语义与交互测试 |
| P2 · 放大字体布局 | 200% 字号下导航示例高度不足、开关标签横向溢出、Terminal 场景标签断词 | 导航容器随文字增长；标签 Flexible 换行；场景分段随字号增加宽度，空间不足时改为内容高度的纵向排列 | [480像素 / 200%](docs/screenshots/browser-480-text-200.png)；9个页面200%文字测试 |
| P1 · 取消与异步操作 | 保存后再编辑时，Form.reset 的默认值可能覆盖最近保存的快照 | 先重置 Form，再恢复保存快照；异步按钮防重复提交；路由取消不删除草稿 | save → edit → cancel 回到已保存内容，异常与重复提交测试、Escape保留草稿测试 |

以上问题均已修复并重新验证。最终对照没有发现新的实质布局、层级或状态缺陷。

## 必查设计面

| 面向 | 检查与结论 |
| --- | --- |
| 字体与排版 | 原生优先系统字体，Web 使用 Noto Sans SC，代码使用 Roboto Mono；标签13、输入值14、标题16/22。中文无缺字，主次层级与紧凑设计对应。200% 时允许行高和容器增长；抗锯齿因原生 / Web 渲染器存在差异，不宣称字形像素一致。 |
| 间距与布局 | 侧栏262，主区边距40，状态栏356，字段列与操作行对齐；圆角6、细分隔线和低层级表面统一。短窗口滚动主体，代码区折叠为可展开入口，避免覆盖永久操作；窄屏侧栏变抽屉。 |
| 色彩与令牌 | light / dark / system 共用组件。语义颜色来自 ColorScheme 与 IanvsTokens；文本、弱文本、选中、错误、onPrimary 的测试组合均达到4.5:1。自定义强调色会选择可读前景。禁用状态保持弱化；未把禁用色声称为4.5:1。主按钮与 tonal 颜色有实际渲染断言。 |
| 图像质量与资产 | 运行时没有照片或插图需求。图标使用 Material / Cupertino 字体资产，没有用截图充当界面、手工 SVG、表情、伪头像或代码绘图替代设计资产。设计生成图仅归档；字体授权文件随 example 保存。 |
| 内容 | 连接、工作区、表单、草稿与反馈文案可独立理解。必填错误与空字段一致。代码区展示可复制的真实 Dart API；补充组件的当前路径和结果会随操作改变。 |
| 图标与形状 | 导航、复制、主题、加减、错误及终端 / 文件夹来自同一图标体系；尺寸与基线统一。Material 语义对应优先于概念图中不明确的小图标。 |
| 交互与无障碍 | 焦点环、菜单、表单、禁用 / busy / success / error / empty 状态均有真实行为。键盘快捷键、选择器键盘操作、Escape退出、受控状态拒绝与恢复有测试。骨架隐藏内容的语义和交互，延迟出现并尊重减少动画；触控密度最小48。 |

## 实际运行验证

- Web：连接校验、保存忙碌反馈；主题切换；⌘K 搜索并筛选组件；级联切换与路径更新；数字步进增减；复制示例成功提示；日期选择器打开、当前主题与 Escape 关闭。
- 窄屏：480×800 打开导航抽屉、选中扩展组件、抽屉收起并恢复菜单按钮焦点；800×600 连接表单；480×800 / 200% 文字的纵向分段及可滚动表单。
- 原生 macOS：Release 启动、连接页渲染、主题菜单点击及 light / dark 窗口外观同步。见[原生深色](docs/screenshots/macos-dark.png)、[原生浅色](docs/screenshots/macos-light.png)。原生截图包含电脑控制工具的窗口标识条，不能当作产品标题栏像素比较。
- 浏览器控制台：最终预览页和组件检查页的 error / warn 日志均为空。

| 运行证据 | 截图 |
| --- | --- |
| 常见 Material 操作 | [按钮 / FAB / 分段](docs/screenshots/material-actions-dark.png) |
| 文本与选择 | [输入与选择](docs/screenshots/material-inputs-light.png) |
| 弹层主题 | [浅色日期弹层](docs/screenshots/material-date-light.png) |
| 窄屏表单与抽屉 | [480表单](docs/screenshots/browser-narrow-480.png)、[抽屉](docs/screenshots/browser-narrow-drawer.png) |
| 小桌面窗口 | [800×600](docs/screenshots/browser-800-light.png) |
| 放大文字 | [480×800 / 200%](docs/screenshots/browser-480-text-200.png) |

## 自动化与构建

环境：Flutter 3.44.2 / Dart 3.12.2。依赖已解析后，以下命令使用 `--no-pub`，避免同包并行解析依赖造成生成文件竞争。

| 检查 | 结果 |
| --- | --- |
| `flutter analyze --no-pub` | No issues found |
| 根目录 `flutter test --no-pub` | 62 项通过 |
| example `flutter test --no-pub` | 57 项通过 |
| example `flutter build web --release --no-web-resources-cdn --no-pub` | 通过 |
| example `flutter build macos --release --no-pub` | 通过 |

包测试涵盖主题扩展保留与插值、颜色对比度、真实主按钮 / tonal 颜色、异步按钮、防重复操作与异常、外部资源所有权、Select 受控 / Form / 键盘、图标语义、密度和文字缩放、确认取消、级联路径、步进编辑 / 边界 / 父级拒绝、骨架延迟 / 隐藏语义 / 减少动画。

展厅测试包含9页 × 明暗 × 1487×1058 / 480×800共36种布局，9页200%文字，Material家族真实控件覆盖，以及日期 / 范围 / 时间返回值、草稿保护、底部面板、菜单 / Banner、主题 / 密度 / 搜索、表单保存与取消、平台剪贴板调用及InputChip操作。原始执行摘要存放于 [verification](docs/verification/)。

## 已说明的差异与验证边界

1. 实现以32逻辑像素为紧凑最小高度；原图虽标注32，绘制框更高。保留原图整体结构与输入列位置，优先遵守可复用的逻辑尺寸规范。主操作使用44高，强调层级。
2. 原图渐变光晕、噪点纹理改为稳定的平面主题表面；选中分段使用语义选中色，焦点使用独立轮廓。浅色为与深色对应的令牌映射。
3. 为覆盖完整目录增加了扩展组件和设计规范入口。源图非空命令配必填错误的矛盾已修正。
4. TDesign补充只参考交互思路：Shell是当前浏览层，叶子无下钻箭头；整数步进使用独立命中区域；骨架呈现内容结构，完成态使用真实图标。不是TDesign全组件或API兼容实现，详见[适配说明](docs/design/tdesign-adaptation.md)。
5. 原生实测确认渲染和指针主题切换；未进行完整人工VoiceOver朗读审计。键盘和语义的结论限定于Flutter测试及实际Web语义树 / 操作，不宣称已穷尽每个系统辅助技术组合。
6. 复制示例的实际Web提示和Flutter平台`Clipboard.setData`契约已验证；电脑控制工具的虚拟剪贴板不能回读该系统通道，因此未声称已回读操作系统剪贴板。
7. 示范数据存于内存。库提供组件与回调，Terminal / ACP的业务存储、连接进程、窗口拖动和应用菜单由宿主拥有。没有修改或迁移同级应用。
8. 未发布到pub.dev或公网。当前交付是可通过path dependency使用的本地基础库，以及可运行的macOS / Web展厅。

## 交付检查清单

- [x] 用户选定稿、浅色稿和组件设计板归档
- [x] Material主流组件主题与桌面组合实现
- [x] TDesign三个补充交互按统一令牌适配
- [x] 明暗与窄屏 / 放大文字复验
- [x] 发现问题修复后重新截图、联合比较
- [x] 119项测试、静态分析和两平台Release构建
- [x] API、接入映射、设计差异和验证边界记录

后续可选细化：在真实下游应用集成后，以其长文本、业务表格和系统辅助技术环境继续验收；这属于宿主集成工作，不影响本次基础库交付。
