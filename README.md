# Ianvs Design

面向 Ianvs 应用家族的 Flutter 基础 UI 库。以 Material 3 的组件与交互为基础，采用 macOS 的紧凑排版、系统字体、分层表面和键盘操作习惯。

深色、浅色与跟随系统使用同一套组件。项目包含可运行的 macOS / Web 组件展厅、设计规范、组件示例与测试。

## 开始使用

要求 Flutter **3.44+**、Dart **3.12+**。在应用的 `pubspec.yaml` 中添加本地依赖，按实际目录调整路径：

```yaml
dependencies:
  ianvs_design:
    path: ../ianvs-design
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
| 桌面组合 | Sidebar、Toolbar、Workspace、FormSection、FieldRow、SettingsRow、Banner、EmptyState |
| 补充交互 | Cascader 级联路径、NumberStepper 整数步进、Skeleton 骨架屏；参考 TDesign Flutter 后统一适配 |

详细说明见 [组件 API 与交互契约](docs/components.md)、[设计规范](docs/design/plan.md) 和 [Terminal / ACP 接入指南](docs/integration.md)。

## 组合组件

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

基础颜色通过 `ColorScheme` 获取，额外表面、状态色与尺寸通过 `Theme.of(context).extension<IanvsTokens>()!` 或 `context.ianvs` 获取。`IanvsTheme.build(base: ...)` 可保留宿主的其他 ThemeExtension；请提供 Material 3 的 base。覆盖 token 后若还需改变标准 Material 控件，应同步覆盖对应的 ThemeData 样式。

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

[设计验收报告](design-qa.md) 记录同视口对照、实际操作、修复与适用边界。[设计资料](docs/design/README.md) 包含用户选定稿、ImageGen 设计板、差异标注和原始截图。

本包当前为本地复用版本（`publish_to: none`），尚未发布到 pub.dev。macOS 系统窗口行为由宿主负责；example 演示了标题栏明暗同步。这个库不提供 Terminal 或 ACP 的运行时连接、进程管理和配置持久化。
