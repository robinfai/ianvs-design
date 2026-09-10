# TDesign 补充交互适配

用户要求从 [Tencent/tdesign-flutter](https://github.com/Tencent/tdesign-flutter) 选择可补充 Material 主流组件的交互。本轮读取固定 commit `031b1a06b98d928345fac33c0ddc89f03844ed09` 的源码，同时查看官方示例。源码与线上示例可能属于不同发布阶段，因此以固定源码说明交互契约，以 Ianvs 用户选定图稿决定视觉。

| 参考 | 采用的交互 | Ianvs 适配 |
| --- | --- | --- |
| [Cascader 源码](https://github.com/Tencent/tdesign-flutter/blob/031b1a06b98d928345fac33c0ddc89f03844ed09/tdesign-component/lib/src/components/cascader/t_cascader.dart) | 受控完整路径，分支发出候选路径，路径可回溯，禁用选项 | `IanvsCascader<T>`：桌面内嵌面板、面包屑、Material 焦点与按钮；适配两套主题；清晰区分叶子与分支 |
| [Stepper 源码](https://github.com/Tencent/tdesign-flutter/blob/031b1a06b98d928345fac33c0ddc89f03844ed09/tdesign-component/lib/src/components/stepper/t_stepper.dart) | 受控数值、输入提交、min/max 边界、父拒绝请求后还原 | `IanvsNumberStepper`：面向字号/数量的整数 API，增加 ↑↓、Esc、无障碍名称、统一密度 |
| [Skeleton 源码](https://github.com/Tencent/tdesign-flutter/blob/031b1a06b98d928345fac33c0ddc89f03844ed09/tdesign-component/lib/src/components/skeleton/t_skeleton.dart) | 结构占位与延迟显示，减少短请求闪烁 | `IanvsSkeleton`：直接保留 child 尺寸，加载时隐藏子内容语义与交互，暂停隐藏内容 ticker，尊重减少动画 |

实现使用 Ianvs 的 API 和 Material 原语，未引入 `tdesign_flutter` 依赖。主题、图标、布局尺寸均来自 Ianvs；没有并存第二套主题管理。

参考页面：[级联选择](https://tdesign.tencent.com/flutter/components/cascader)、[步进器](https://tdesign.tencent.com/flutter/components/stepper)。截图保存在 `references/tdesign-*-source.png`。TDesign Flutter 原仓库使用 MIT 许可；这里是交互参考及独立实现，未复制源码文件。

补充设计由内置 ImageGen 生成，见 [设计板](references/supplements-board.png) 和 [完整提示词](supplementsBoard-prompt.txt)。设计板中“交互 Shell / 受限 Shell”旁的箭头属于生成稿误差：它们是叶子，实际组件不会显示分支箭头；面包屑高亮实际所在层级。

范围保持聚焦：未同时引入上传、轮播、评分等与当前桌面基础场景关联较弱的组件。Material 标准组件仍为主；补充控件遵循相同无障碍、状态所有权与适配规范。
