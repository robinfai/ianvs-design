# Terminal 与 ACP 接入

Ianvs Design 提供同系列应用共享的主题和基础交互；连接、会话和 Agent 业务模型由宿主管理。可在一次接入中统一采用，无需为了迁移顺序保留第二套基础主题。

## 主题与依赖

在目标应用实际的 pubspec 中加入 `ianvs_design: ^0.2.1`。库与宿主联合开发时可临时使用指向本仓库的 path override，正式交付使用 pub.dev 版本。

```dart
ThemeData createTheme(Brightness brightness, ThemeData appBase) {
  return IanvsTheme.build(
    base: appBase,
    brightness: brightness,
    density: IanvsDensity.compact,
    platform: TargetPlatform.macOS,
  );
}
```

宿主保留 `ThemeMode.system` 和现有偏好存储。appBase 应启用 Material 3；其其他 ThemeExtension 会保留。终端 ANSI 颜色、代码语法色和 Agent 消息语义色属于业务主题，应保留在独立扩展中。

## 令牌与组件映射

| 现有模式 | Ianvs 对应 | 接入注意 |
| --- | --- | --- |
| Terminal `AppThemeTokens` 的中性表面/分隔线 | `IanvsTokens.canvas/chrome/field/raised/separator` | 不映射终端 ANSI palette |
| Terminal 紧凑按钮、配置字段 | `IanvsButton`、`IanvsTextField`、`IanvsSelect` | 复用原有 controller、FocusNode、validator 与保存回调 |
| ACP 系统字体与设置分组 | `IanvsTheme`、`IanvsFormSection`、`IanvsFieldRow` | 遵循最新 macOS 设置规范的13px标签，宽度不足改纵向 |
| 两个应用的侧栏/工具栏 | `IanvsSidebar`、`IanvsToolbar`、`IanvsWorkspace` | 窗口拖动区、交通灯和全屏仍由宿主原生代码负责 |
| 关闭/放弃草稿 | `showIanvsConfirmDialog` | 只有返回 true 才执行原有业务操作；取消和 Escape 保留草稿 |
| 本地/远程/Agent 多层配置 | `IanvsCascader` | 受控路径只是选择结果；连接配置对象由应用转换 |
| 字号、并发数、重试次数 | `IanvsNumberStepper` | 整数 min/max/step 按业务确定 |
| 工作区异步列表加载 | `IanvsSkeleton` | 给出稳定占位尺寸，完成后传入 loading:false |

## 状态与窗口行为

业务保存函数返回 Future 即可接入异步按钮，失败时通过 onError 展示应用已有的可恢复错误。取消操作应恢复最近一次保存快照，再重建受控字段；不要让表单默认 reset 覆盖已经恢复的 controller 值。

库提供窗口内部 UI。example 的 `MainFlutterWindow.swift` 演示了窗口最小尺寸和明暗 appearance 同步，不要求下游引入 window_manager 等额外窗口插件。已有标题栏和快捷键注册应继续由应用统一管理，避免与组件示例的 ⌘K 重复。

## 每个应用接入后检查

确认主题、真实业务表单保存/取消、菜单焦点返回、200%文字、窄窗和系统外观切换。这里的组件测试验证了公共 UI 契约；真实终端进程、ACP 请求与数据存储仍需目标应用自己的集成测试。

## 等宽文字与阅读字号

```dart
final theme = IanvsTheme.build(
  brightness: brightness,
  monoFontFamily: 'AppMono', // 宿主已在 pubspec 中声明的字体
  monoFontFamilyFallback: const ['Menlo', 'monospace'],
  codeTextStyle: const TextStyle(fontSize: 13, height: 1.5),
);

final code = context.ianvsTypography.code;
Text(filePath, style: code);
// 终端/代码渲染器可读取 code.fontFamily 与 code.fontFamilyFallback。
```

主题负责代码文字的默认前景，语法高亮与 ANSI palette 继续由宿主提供。ACP 的15px聊天阅读字号属于 ChatTheme，可独立保留。Web 或需要一致字体的原生应用应打包字体；库不附带字体资源。

## 受控多面板组合

```dart
// width 是宿主 State 持有的状态；外层提供有限高度。
Row(children: [
  SizedBox(width: width, child: sidebar),
  IanvsResizeHandle(
    value: width,
    min: 220,
    max: 320,
    resetValue: 260,
    semanticLabel: '侧栏宽度',
    semanticValueFormatter: (value) => '${value.round()} 逻辑像素',
    onChanged: (value) => setState(() => width = value),
  ),
  Expanded(child: body),
]);
```

右侧 Inspector 的手柄放在面板之前并传 `reverse: true`；底部终端使用 `axis: Axis.vertical, reverse: true` 并放在终端上方。宿主按窗口可用空间计算上下界，必要时隐藏面板或改布局；保持稳定 key/controller 防止草稿和会话被重建。现有 MacosWorkspaceLayout 可以复用手柄，继续管理快捷键、原生菜单、显示/隐藏和偏好存储。IanvsWorkspace 原 API 不变，不强制替换整个工作区。

## macOS 原生文本语义代理

ACP 的 `AccessibleTextField` 使用 AppKitView 和宿主注册的 MethodChannel 代理，包含语义开关、焦点与输入同步生命周期。它不是普通 `labelText` 的等价功能，应保留在宿主；Ianvs Design 不注册 ACP 的原生 view type 或 channel。

```dart
// AccessibleTextField 是宿主组件，不由 ianvs_design 导出。
AccessibleTextField(
  label: '搜索工作区',
  description: '按名称筛选工作区',
  controller: controller,
  onChanged: onChanged,
  enabled: enabled,
  builder: (focusNode) => IanvsTextField(
    controller: controller,
    focusNode: focusNode,
    onChanged: onChanged,
    enabled: enabled,
    hintText: '输入工作区名称',
  ),
);
```

两层必须共享 controller、FocusNode 和回调；enabled、多行属性与读写能力保持一致。代理的 native setText 路径更新 controller 后由代理显式触发业务回调，不能依赖程序设置 controller 自动触发 TextFormField.onChanged。原生平台 view 注册、代理代际清理、VoiceOver 名称及原生文本编辑仍由宿主的测试和真实 macOS 验证覆盖；本库测试只验证 Flutter 的 controller/focus/Form 契约，不能代替原生端验证。

## iPhone 字体、触达区域与表单

```dart
ThemeData mobileTheme(Brightness brightness) => IanvsTheme.build(
  platform: TargetPlatform.iOS,
  density: IanvsDensity.touch,
  brightness: brightness,
);
```

密度是明确的输入模式选择，不由窗口宽度自动推断；只传 platform 仍使用默认 compact。iOS + touch 下，`bodyLarge/bodyMedium/labelLarge` 为17点，`bodySmall/labelMedium` 为15点，`labelSmall` 和输入 helper/error 为13点。原生 iOS 按字号选择 Flutter Cupertino Text/Display 字体，显式 `fontFamily` 覆盖优先。这个映射是库的语义样式约定；系统 Dynamic Type 通过 Flutter 的 MediaQuery/TextScaler 继续缩放，宿主不应硬性覆盖或限制它。

Button、IconButton、输入和选择器采用48点最小尺寸，列表/菜单项采用56点最小行高；大文字和换行可使内容增长。现有触达区域已满足 [Apple 的44×44点设计建议](https://developer.apple.com/design/tips/)，不必再给每个控件套一层固定高度。Flutter 也建议验证 [触达区域与大比例缩放](https://docs.flutter.dev/ui/accessibility)。图标绘制尺寸与手指命中区域是不同概念。

`IanvsFieldRow` 在窄屏或大字号下改为标签在上。`IanvsFormSection` 的标题与 trailing 在内容宽度小于480或文字缩放超过1.5倍时分行；宽屏仍并排，操作最大宽度限制为标题区的一半。长操作文字可换行；提供多个操作时，宿主应使用 Wrap/OverflowBar，而非无约束的 Row。

页面16点留白和8–16点组内间距可直接使用 `IanvsSpacing.lg/sm/md`；库不强制所有页面使用同一外边距。以下为宿主控制键盘避让和滚动的最小组合：

```dart
Scaffold(
  resizeToAvoidBottomInset: true,
  body: SafeArea(
    child: ListView(
      padding: const EdgeInsets.all(IanvsSpacing.lg),
      children: [
        IanvsFormSection(title: const Text('同步设置'), children: fields),
        const SizedBox(height: IanvsSpacing.lg),
        IanvsButton(onPressed: save, child: const Text('保存并同步')),
      ],
    ),
  ),
);
```

需要固定主操作时由宿主组合可滚动正文和操作区，并验证键盘出现后的剩余空间；底部弹层可通过 `showModalBottomSheet(isScrollControlled: true, useSafeArea: true, ...)` 配合宿主的 `viewInsets` 内边距。不要在已经缩小正文的 Scaffold 内重复计算相同键盘 inset。库的 IanvsDialog 已使用可滚动 AlertDialog 和自适应操作排列，不承担 SSH、同步、业务路由或持久化。
