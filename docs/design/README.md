# 设计资料

本任务使用 Product Design index 规划、ImageGen 设计/走查、image-to-code 实施流程。用户明确要求 Flutter，因此基础库和展厅使用 Flutter package + example，没有切换到 Web 模板。

| 阶段 | 产物 | 说明 |
| --- | --- | --- |
| 规划 | [plan.md](plan.md) | 同级 Ianvs 应用证据、组件范围、令牌与分层 |
| 用户选择 | [graphite-dark.png](references/graphite-dark.png) | 用户提供的1487×1058视觉真值 |
| 浅色对应稿 | [graphite-light.png](references/graphite-light.png) | 同布局浅色；[提示词](selectedLight-prompt.txt) |
| 基础控件设计 | [controls-board.png](references/controls-board.png) | 按钮、输入、选择；[提示词](controlsBoard-prompt.txt) |
| 容器与反馈设计 | [surfaces-board.png](references/surfaces-board.png) | 导航、容器、弹层、反馈；[提示词](surfacesBoard-prompt.txt) |
| 补充控件设计 | [supplements-board.png](references/supplements-board.png) | 级联、步进、骨架；[提示词](supplementsBoard-prompt.txt) |
| 走查第一轮 | [dark-pass-1.png](reviews/dark-pass-1.png) | 同时输入原稿与真实截图生成差异标注；[提示词](darkQa-prompt.txt) |
| 明暗复验 | [light-dark-final.png](reviews/light-dark-final.png) | 修复后同视口联合比较；[提示词](finalQa-prompt.txt) |
| 扩展复验 | [supplements-final.png](reviews/supplements-final.png) | 设计板与明暗实拍对照；[提示词](supplementsQa-prompt.txt) |
| 搜索与菜单修复 | [search-menu-fix.png](reviews/search-menu-fix.png) | 用户反馈与修复实拍联合比较；[提示词](menu-fix-qa-prompt.txt) |
| 最终证据 | [design-qa.md](../../design-qa.md) | 实际截图、验证结果、修复与已说明的差异 |

以上生成任务均使用内置 `image_gen` 工具，没有使用 CLI 或外部图像 API。完整提示词按阶段独立保存；生成文件已复制进仓库，运行时不依赖 Codex 私有目录。

ImageGen 的对照板是**设计师标注插图**，可能重新采样界面、改变文字或生成错误日期，不作为逐像素测量证据。原始截图保存在 `../screenshots/`；验收结论由真实截图、代码和实际交互共同确定。

第一轮标注中的“错误字段恢复 /bin/invalid”建议不采纳：空值与“请输入启动命令”的实际必填校验相符。标注板所示日期也不作为验收时间。分段选择宽度、主操作尺寸、代码标签位置与输入文字大小的差异已落实到代码。

设计稿中的纹理和柔光是概念图效果；实际 UI 使用稳定的主题表面。图标来自 Material / Cupertino 字体库。骨架几何只表示加载结构，未用代码图形代替照片、头像或品牌资产。

字体来源：Google Fonts 官方 [Noto Sans SC](https://github.com/google/fonts/tree/main/ofl/notosanssc) 与 [Roboto Mono](https://github.com/google/fonts/tree/main/ofl/robotomono)，授权文本见 `example/assets/fonts/*-OFL.txt`。原生优先系统字，Web 展厅显式提供中文和等宽字体，避免缺字与代码对齐偏差。
