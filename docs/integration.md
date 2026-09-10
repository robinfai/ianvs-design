# Terminal 与 ACP 接入

本轮产物是独立组件库；同级应用作为只读参考。接入采用逐步替换，不改变连接、会话和 Agent 业务模型。

## 先接主题

在目标应用实际的 pubspec 中加入 path 依赖。示例：从 `ianvs-terminal/example` 指向 `../../ianvs-design`；从更深的 ACP package 目录应按实际层级调整。

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
