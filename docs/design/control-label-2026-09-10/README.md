# 选择控件文字交互校准

验收日期：2026-09-10。范围为用户截图中的复选框、三态选择、单选、设置开关及 Material Switch。

单击文字与点击控件执行同一状态变化；拖选、双击选词、长按选择和复制不切换状态。禁用标签不触发操作。设置标题和说明都可点击。复选框、设置开关和 Material Switch 保留示例原有的共享状态。

实现位于 `lib/src/components/control_label.dart`，由 `IanvsSettingsRow` 和示例的选择控件复用。标签等待 Flutter 双击识别窗口（300 ms）后提交一次单击；文字选区展开时取消提交，控件本体仍即时响应。无障碍标签合并到原生控件，Tab 不增加文字停留点，提交后焦点回到原生控件。

## 验证结果

- 组件库 71 项测试通过，其中新增 9 项覆盖真实鼠标、触摸、文字复制、禁用、取消待处理动作、无障碍与键盘。
- 示例应用 69 项测试通过，新增页面回归验证标签与原生三态循环、单选、复选和开关一致。
- `flutter analyze` 无问题；Web release 构建成功。
- 浏览器实测：点击复选框文字从选中切换为关闭；拖选文字和双击 Material 单词时保持关闭，显示文字选中高亮。
- ImageGen 内置工具独立视觉验收：**通过**。未报告本次范围内的可见阻断项。

## 真实截图

| 截图 | 状态 |
| --- | --- |
| [深色初始](screenshots/dark-initial.jpg) | 复选已选、三态混合、禁用、本地单选、开关开启 |
| [点击文字](screenshots/dark-label-click.jpg) | 复选框与共享开关关闭，焦点交给控件 |
| [拖选文字](screenshots/dark-drag-selection.jpg) | 复选框文字高亮，状态保持关闭 |
| [双击选词](screenshots/dark-double-click-selection.jpg) | Material 单词高亮，开关保持关闭 |
| [浅色状态](screenshots/light-controls.jpg) | 浅色对齐、间距和禁用样式 |

[ImageGen 验收批注板](reviews/imagegen-acceptance.png) · [完整提示词](reviews/prompt.txt) · [测试及构建日志](verification/)

生成批注板用于承载视觉审查意见，不是原始像素证据；板中自动生成的日期占位及重绘局部不作为项目事实，验收日期以本记录为准，UI 状态以以上真实截图为准。手势、时序和键盘行为由实际测试验证。

预览：<http://127.0.0.1:4173/?theme=dark&page=inputs&revision=control-label>
