# Changelog

## 0.4.0 — 2026-09-12

- `Dialog` / `AlertDialog` / `IanvsDialog` 外层独立采用16点圆角、0.75点 separator 边线和轻阴影；新增 `IanvsTokens.dialogRadius`，保留内容卡片、输入边界与键盘焦点样式。
- 菜单项悬停、按压和键盘焦点改用柔和中性背景，与选中底色区分；移除菜单项焦点描边，修复鼠标展开子菜单后出现粗蓝框的问题。
- 修复 `IanvsResizeHandle` 鼠标拖动、取消和双击重置后残留蓝色粗线；鼠标操作结束恢复中性分隔线，保留实际焦点，Tab 或方向键操作仍显示键盘焦点。
- 新增 `IanvsChoiceTile<T>`：接入 Flutter RadioGroup/RawRadio，整行单选，右侧小勾和固定占位，中性悬停反馈与键盘焦点描边；保留互斥语义、方向键/Tab/Space、禁用与减少动画。
- 单选行默认使用 bodyMedium/bodySmall，桌面 compact 单行最小32点、compact touch最小48点，长标题/说明自然换行增高；展厅替换存储单选列表示例。
- `IanvsSettingsRow` 增加密度对应的最小行高与内部纵向留白，可通过 `contentPadding` 覆盖；保留可选择文字和原生 Switch 行为。
- 补充单选受控状态、RTL、键盘、语义、深浅色、1–3倍文字和设置行/表单1–2倍文字布局回归。macOS全局文字层级保持兼容。

## 0.3.1 — 2026-09-11

- 修复紧凑触控下普通 Material 输入、静态图标、交互图标和 Ianvs 封装输入高度不一致的问题；统一输入主题与前后图标区域48点最小尺寸。
- 帮助/错误文字不再侵占48点输入表面；保留16点正文、13点堆叠标签及4点标签间距，大字号与多行继续增高，显式 decoration 约束仍优先。
- 原生 Flutter DropdownMenu 为自带箭头边距保留空间，默认56点，避免裁剪内部48点按钮；IanvsSelect 保持48点表单节奏。
- 新增真实 RenderBox 装饰组合和输入表面测量，覆盖深浅色、1–3倍文字、图标点击、多行与宿主约束覆盖。

## 0.3.0 — 2026-09-11

- 新增可选 `IanvsTouchVisualDensity.compact`，通过 `IanvsTheme.build/light/dark` 的 `touchVisualDensity` 参数启用；输入模式仍为 touch，默认 standard 和原平台行为保持兼容。
- 紧凑触控采用44点控件外观、48点列表最小高度、16点正文/输入、18/17点标题、13点辅助文字和20点普通图标；Material 按钮保留 padded 触达布局，大字号可自然撑高。
- `IanvsFieldRow` 在紧凑触控堆叠布局中使用13点标签与4点标签间距；整数步进器为按钮触达布局留足宽度，并提供44点输入最小高度。
- 补充窄屏、横屏、键盘区域、深浅色、1–3倍文字、控件实际尺寸和语义触达回归。

## 0.2.1 — 2026-09-11

- 修复 `IanvsFormSection` 长标题与 trailing 操作在窄屏或大字号下的横向溢出：窄屏分行，宽屏限制操作最大宽度，保持现有 API。
- iOS 原生字体改用 Flutter 的 Cupertino Text/Display 字体入口；宿主自定义字体继续优先。
- iOS + touch 模式采用17点正文/操作、15点次要文字和13点注释/输入帮助文字；保留 TextScaler、48点控件和56点列表行，桌面 compact 及 Android 排版不变。
- 新增 iOS 深浅色、1–3倍文字、长中英文标签、触达区域和键盘遮挡下对话框操作的离屏验证。

## 0.2.0 — 2026-09-10

- 新增 `IanvsTypography` 主题扩展与 `context.ianvsTypography.code`，统一代码、路径和工具输出的等宽排版；支持平台字体默认值、宿主字体覆盖、明暗插值及触控密度。
- `IanvsTheme.build` 新增 `monoFontFamily`、`monoFontFamilyFallback`、`codeTextStyle`，不改变普通正文与宿主业务主题。
- 新增受控 `IanvsResizeHandle`，支持宽度/高度、右侧/底部面板、拖动边界、键盘与语义增减、双击/Enter 重置；布局、显隐与持久化由宿主持有。
- 展厅增加可调整侧栏和底部面板，并使用共享等宽主题；补充尺寸调整与草稿保留回归测试。
- 明确 ACP 原生输入代理的集成边界，并验证 `IanvsTextField` 共享 controller、FocusNode、回调及 Form 契约。

## 0.1.0 — 2026-09-10

- 首次发布到 pub.dev，补齐 MIT 许可证、第三方来源说明、仓库地址和安装文档。

- 增加 IanvsControlLabel，统一选择控件的文字点击操作；拖选、双击选词、长按选择和复制不切换状态，保留原生键盘及无障碍行为。
- 完成设计评审后的日期布局、导航、表单反馈和主题对比度校准，保存真实截图与 ImageGen 视觉验收记录。
- 组件库与示例应用共 140 项回归测试通过，静态检查及 Web release 构建通过。

- 增加 IanvsSearchField，搜索连接改为原位输入加锚定建议，修复点击后搜索框缩窄、返回箭头替换及整体搜索视图切换。
- 保留搜索字段及邻近控件的布局，支持键盘筛选、空结果、重开、外部点击关闭与鼠标选择时的焦点保持。

- 修复 Select 悬停色溢出字段轮廓，在辅助文字区露出底部色带的问题。
- 统一 Select、Material DropdownMenu、自动补全和操作菜单的高亮、菜单项字体、圆角及边距。
- 增加 IanvsMenuButton，供外观、密度和快捷菜单复用，并保留键盘选择与返回焦点。
- 对齐两类下拉控件的字段列、高度、文字及箭头位置，窄屏统一切换为标签在上。

- 修复 SearchBar 和展开搜索视图中文字偏上：将输入最小高度限定到 IanvsTextField。
- Select 改用主题化 MenuAnchor，统一菜单圆角、行高、选中勾、禁用颜色、弹出间距及宽度。
- 增加 IanvsAutocompleteOptions，修复默认自动补全全宽、缺少边界的浮层样式。
- 增加明暗、密度、垂直对齐和菜单键盘操作的回归测试。

- 建立明暗 Material 3 主题、语义颜色、三档密度与 macOS 排版规范。
- 提供桌面表单、导航、异步操作、确认流程等可复用组合组件。
- 展厅覆盖主流 Material 组件及实际状态与弹层交互。
- 增加参考 TDesign Flutter 的级联选择、整数步进与骨架屏。
- 提供 macOS / Web 示例、设计证据、接入文档及回归测试。
