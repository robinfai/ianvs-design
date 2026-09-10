# Ianvs Design · 实施规范

状态：视觉目标已由用户选定；主题、组件和扩展控件已实现，最终验收见根目录 design-qa.md。

## 目标与范围

构建可直接依赖的 Flutter package `ianvs_design`，以 Material 3 的组件、语义、焦点和路由行为为基础，统一为 macOS 紧凑工作台风格。支持 light / dark / system、可配置强调色、紧凑 / 标准 / 触控密度。独立于 Terminal、ACP 的运行时、网络与配置存储。提供 macOS / Web 可运行组件目录。

## 视觉真值

- 用户选定 `references/graphite-dark.png`，1487×1058。系统字、石墨表面、蓝色焦点、小圆角，侧栏 / 主预览 / 状态区 / 代码区。
- ImageGen 生成对应浅色稿及补充组件设计板；浅色只改变颜色，保留同一组件和布局。
- 原图只作设计证据，运行时使用 Flutter 真实控件和 Material 图标。没有需要生成的运行时照片、插图或自定义图标。
- 参考中的字段内容与校验文案矛盾（非空命令却提示请输入）；实现校验状态使用空字段对应必填错误，并在验收说明这一修正。

## 参考来源与继承

1. `../ianvs-terminal/example/lib/ui/foundation/app_theme_tokens.dart`：语义色、ThemeExtension，28/32/36 控件、触控48、4/6/8/12/16/20间距。
2. `../ianvs-terminal/example/lib/ui/components/`：按钮、配置字段、锚定菜单、弹窗、工具栏、空态。
3. `../ianvs-acp/packages/ianvs_agent_chat/lib/ui/theme/`：系统字体/PingFang、Material3紧凑主题、14区块标题/13标签/12元信息。
4. `../ianvs-acp/docs/macos-settings-refinement-2026-09-09/README.md`：采用最新紧凑规范，旧大字号稿不再适用。
5. `../ianvs-markdown/app/lib/src/desktop_theme.dart` 与 `../ianvs-omnivore/apps/client/lib/src/design/macos_theme.dart`：6圆角、13字号、明暗桌面控件；下游可通过 token 映射逐步接入。

## 分层与约定

- Foundation：`IanvsTheme`、`IanvsTokens`、`IanvsDensity`、spacing/radius/motion/typography。标准颜色走 ColorScheme；额外表面、语义色和尺寸走 ThemeExtension；copyWith/lerp 完整；保留第三方扩展。
- Material：直接导出 Flutter Material，主流组件由 ThemeData 统一风格，保留官方 API、语义与键盘交互，不创建机械别名。
- Components：IanvsButton/IconButton、TextField/Select、Banner/EmptyState、FormSection/FieldRow/SettingsRow、Sidebar/Toolbar/Workspace、Dialog。
- 外部状态由调用方管理；通过 controller、value、onChanged、onPressed、validator、onSaved 对接；不内置业务持久化。
- 外部 FocusNode/controller 不由库销毁；内部创建的资源生命周期完整；异步按钮加载时禁用重复操作且保留标签语义。
- 控件高度是最小值，支持文字放大；通过父约束折叠多栏；桌面密度与触控命中区域分开。
- 明暗所有状态的对比度都检查，尤其 primary 的 hover/focus、disabled、error；不照搬已有按钮的白字浅蓝悬停状态。

## 主流 Material 覆盖清单

| 家族 | 组件 |
| --- | --- |
| 操作 | Filled / tonal / elevated / outlined / text button；icon button；FAB / extended FAB；segmented button |
| 输入 | TextField / TextFormField；search bar / search anchor；dropdown / autocomplete；表单校验、密码、多行 |
| 选择 | Checkbox / tri-state；RadioGroup；Switch；Slider / RangeSlider；Action / Choice / Filter / Input chip |
| 导航 | AppBar；BottomAppBar；NavigationBar；NavigationRail；NavigationDrawer；TabBar |
| 容器 | Card；ListTile / selection tiles；Divider；ExpansionTile；DataTable |
| 反馈 | Badge；Tooltip；SnackBar；MaterialBanner；Linear / Circular progress；empty / error state |
| 叠层 | AlertDialog / SimpleDialog；modal bottom sheet；MenuAnchor / MenuBar / PopupMenu |
| 时间 | Date picker；date range picker；Time picker |
| TDesign 补充 | Cascader 级联路径；NumberStepper 整数步进；Skeleton 骨架屏 |
| 桌面组合 | Sidebar / Toolbar / Workspace；Connection form；Settings sections；Confirmation / draft exit |

目录中每个家族具有实际交互，按钮、表单、菜单、导航、覆盖层与选择器不能只有静态示意。明暗切换作用于所有故事和 overlay。

## 实现顺序

1. 主题/基础变量、原生 Material 主题覆盖。
2. 公共组件与桌面组合。
3. 原图工作台，连接表单与主流组件目录、规范/代码、搜索、主题与密度切换。
4. 文档与迁移示例；有意义的状态/键盘/语义/适配测试。
5. 原生与浏览器实际预览；同视口对照、ImageGen走查标注、修复P0/P1/P2后复验；根目录design-qa.md。

## 验收

- `flutter analyze`，包测试、示例测试、构建。
- 所有 Material 家族在明暗两套主题中可呈现且无异常；关键状态和操作有测试。
- 键盘 Tab/Enter/Escape、菜单选取、表单校验/保存/取消、主题与密度切换、文字缩放与窄窗口无溢出。
- 主参考以1487×1058 / DPR1 比较；额外检查800×600、窄窗及文字放大。真实原生系统字号和无障碍能力据实报告。
- 视觉证据与功能测试分别记录；不以构建成功代替视觉验收。

## 官方依据

TDesign Flutter 参考固定在 `031b1a06b98d928345fac33c0ddc89f03844ed09`（2026-09-10 检出）。查看了组件源码与官方交互示例，采用受控路径、边界与提交、延迟加载这些交互思路，使用 Ianvs 令牌和 Material 实现，不引入其整套运行时。详见 [TDesign 适配说明](tdesign-adaptation.md)。

- [Material component catalog](https://docs.flutter.dev/ui/widgets/material)：Actions / Communication / Containment / Navigation / Selection / Text inputs。
- [Flutter input & accessibility](https://docs.flutter.dev/ui/adaptive-responsive/input)：focus、keyboard、mouse与密度适配。
- [ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html)：自定义主题数据。
- [Apple typography](https://developer.apple.com/design/human-interface-guidelines/typography?changes=_5)：macOS默认13pt、系统字；不是把最小字作为常用字。
- [Designing for macOS](https://developer.apple.com/design/human-interface-guidelines/designing-for-macos/)：桌面输入、窗口与熟悉的操作层级。

Flutter要求优先于Product Design通用Web模板说明：使用原生Flutter package与example，不初始化Vite/Sites。
