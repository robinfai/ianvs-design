# Ianvs Design

面向 Ianvs 应用家族的 Flutter 基础 UI 库。以 Material 3 的组件与交互为基础，采用 macOS 的紧凑排版、系统字体、分层表面和键盘操作习惯。

深色、浅色与跟随系统使用同一套组件。项目包含可运行的 macOS / Web 组件展厅、设计规范、组件示例与测试。

## 开始使用

要求 Flutter **3.44+**、Dart **3.12+**。在应用的 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  ianvs_design: ^0.3.1
```

```dart
import 'package:ianvs_design/ianvs_design.dart';

MaterialApp(
  theme: IanvsTheme.light(),
  darkTheme: IanvsTheme.dark(),
  themeMode: ThemeMode.system,
  home: const Scaffold(body: Center(child: Text('Ianvs'))),
);
```

标准 `FilledButton`、`TextFormField`、`NavigationRail`、`DataTable`、`showDatePicker` 等直接继承主题，保留 Flutter 官方 API。库同时导出 Material，无需引入一套同义控件名称。

## 覆盖范围

| 家族 | 组件 |
| --- | --- |
| 操作 | Filled / tonal / elevated / outlined / text button、四类 IconButton、FAB / extended FAB、单选与多选 SegmentedButton |
| 输入 | TextField / TextFormField、SearchBar / SearchAnchor、Autocomplete、DropdownMenu、受控 Select、密码 / 多行 / 校验 |
| 选择 | Checkbox / 三态、RadioGroup、Switch、Slider / RangeSlider、Action / Choice / Filter / Input Chip |
| 导航 | AppBar / BottomAppBar、NavigationBar / Rail / Drawer、TabBar / TabBarView、MenuAnchor / MenuBar / PopupMenu |
| 容器与反馈 | Card、ListTile 与选择行、Divider、ExpansionTile、DataTable、Badge、Tooltip、SnackBar、MaterialBanner、线性与圆形进度 |
| 弹层与时间 | AlertDialog / SimpleDialog、模态底部面板、日期 / 日期范围 / 时间选择器、确认弹窗 |
| 桌面组合 | Sidebar、Toolbar、Workspace、ResizeHandle、FormSection、FieldRow、SettingsRow、Banner、EmptyState |
| 补充交互 | Cascader 级联路径、NumberStepper 整数步进、Skeleton 骨架屏；参考 TDesign Flutter 后统一适配 |

详细说明见 [组件 API 与交互契约](https://github.com/robinfai/ianvs-design/blob/main/docs/components.md)、[设计规范](https://github.com/robinfai/ianvs-design/blob/main/docs/design/plan.md) 和 [Terminal / ACP 接入指南](https://github.com/robinfai/ianvs-design/blob/main/docs/integration.md)。

## 组合组件

以下 `IanvsChoiceTile` 和设置行留白改进属于尚未发布的0.4.0，当前请通过固定提交SHA的Git依赖接入；pub.dev安装示例仍使用已发布的0.3.1。

整行单选列表使用 `RadioGroup<T>` 配合 `IanvsChoiceTile<T>(value: ..., title: ..., subtitle: ...)`：组级状态与原生键盘语义保留，默认用右侧小勾标记选择。[接入规范](docs/integration.md)

```dart
IanvsFormSection(
  title: const Text('连接设置'),
  children: [
    IanvsFieldRow(
      label: '名称',
      child: IanvsTextField(
        controller: nameController,
        validator: (value) =>
            value == null || value.trim().isEmpty ? '请输入名称' : null,
      ),
    ),
    IanvsButton(
      onPressed: () async {
        if (formKey.currentState!.validate()) await saveConnection();
      },
      child: const Text('保存更改'),
    ),
  ],
);
```

上例需放入应用持有的 `Form(key: formKey, ...)`，并由应用提供 controller 和存储回调。异步按钮自动显示忙碌状态并阻止重复提交；库不管理业务数据。

## 密度、强调色与字体

```dart
final theme = IanvsTheme.build(
  brightness: Brightness.dark,
  density: IanvsDensity.compact,
  accent: const Color(0xff0874df),
);
```

| 规范 | 紧凑 compact | 舒适 comfortable | 触控 touch |
| --- | --- | --- | --- |
| 控件最小高度 | 32 | 40 | 48 |
| 列表行最小高度 | 40 | 48 | 56 |
| 正文字号 | 13 | 13 | 16 |
| 控件圆角 | 6 | 6 | 6 |

高度是下限，内容和文字缩放可以使组件增长。通过 `IanvsTheme.build(density: ...)` 切换整个主题；不要叠加 `VisualDensity.compact` 再压缩尺寸。窗口宽度控制多栏折叠，输入密度由应用显式选择。

macOS / iOS 默认系统字体。Web 字体需由宿主提供并传入 `fontFamily` / `fontFamilyFallback`；展厅内附的 Noto Sans SC 和 Roboto Mono 仅属于 example，不会打包进库使用者的应用。

iPhone 请显式使用 `IanvsTheme.build(platform: TargetPlatform.iOS, density: IanvsDensity.touch)`：正文及主操作17点、次要文字15点、注释和输入帮助文字13点。原生 iOS 使用 Flutter Cupertino Text/Display 字体入口，保留系统 TextScaler。控件48点、列表行56点是最小值；页面边距、SafeArea、键盘与主操作布局由宿主管理。

需要更紧凑的触控界面时，再传 `touchVisualDensity: IanvsTouchVisualDensity.compact`。输入/正文16点、面板标题18/17点、辅助与堆叠字段标签13点；普通字段和列表最小48点，按钮外观最小44点而 padded 交互布局仍至少48点。字号放大后自然增高，`density` 仍为 touch。默认 `standard` 保留原有行为；该选项在非 touch 模式不生效。原生 Flutter DropdownMenu 带额外箭头边距，默认56点；需要与普通字段同高时可用 IanvsSelect。[接入细节](docs/integration.md#紧凑触控视觉)

基础颜色通过 `ColorScheme` 获取，额外表面、状态色与尺寸通过 `Theme.of(context).extension<IanvsTokens>()!` 或 `context.ianvs` 获取。`IanvsTheme.build(base: ...)` 可保留宿主的其他 ThemeExtension；请提供 Material 3 的 base。覆盖 token 后若还需改变标准 Material 控件，应同步覆盖对应的 ThemeData 样式。

代码、路径和工具输出使用 `context.ianvsTypography.code`。默认等宽字号为13（触控16）、行高1.5，颜色随明暗主题变化；`IanvsTheme.build` 可通过 `monoFontFamily`、`monoFontFamilyFallback` 和 `codeTextStyle` 覆盖。字体文件由宿主提供，聊天阅读字号、代码语法色与终端 ANSI 颜色由宿主业务主题管理。

`IanvsResizeHandle` 可嵌入现有 Row / Column，提供受控面板尺寸调整、键盘和无障碍操作。它不管理会话状态、面板显隐或原生窗口，详见[接入示例](https://github.com/robinfai/ianvs-design/blob/main/docs/integration.md)。

## 运行组件展厅

```sh
cd example
flutter pub get
flutter run -d macos
# 或
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 4173
```

展厅提供组件搜索（⌘K / Ctrl+K）、外观与密度切换、可操作的状态示例和代码复制。连接设置的保存只更新本次示例内存，重新启动会恢复演示数据。

Web 可通过 `?theme=light`、`?theme=dark&page=supplements` 选择初始页面；`?scale=2` 用于检验文字放大。页面名：`connection`、`actions`、`inputs`、`navigation`、`feedback`、`supplements`、`workspace`、`overlays`、`foundations`。

## 验证与设计证据

```sh
flutter analyze
flutter test
cd example
flutter test
flutter build macos --release
flutter build web --release --no-web-resources-cdn
```

[设计验收报告](https://github.com/robinfai/ianvs-design/blob/main/design-qa.md) 记录同视口对照、实际操作、修复与适用边界。[设计资料](https://github.com/robinfai/ianvs-design/blob/main/docs/design/README.md) 包含用户选定稿、ImageGen 设计板、差异标注和原始截图。

macOS 系统窗口行为由宿主负责；example 演示了标题栏明暗同步。这个库不提供 Terminal 或 ACP 的运行时连接、进程管理和配置持久化。

## 许可证

Ianvs Design 原创代码使用 [MIT License](LICENSE)。Flutter Material 使用 BSD-3-Clause，TDesign Flutter 交互参考使用 MIT；示例字体保留 SIL Open Font License 1.1。上游代码和资源适用各自许可证，详见 [第三方来源与许可](THIRD_PARTY_NOTICES.md)。
