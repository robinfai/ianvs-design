# Changelog

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
