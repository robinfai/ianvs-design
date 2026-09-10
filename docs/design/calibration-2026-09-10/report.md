# Ianvs Design 校准与 ImageGen 验收

2026-09-10 · 本地 Flutter Web Gallery · ImageGen 已通过本轮视觉验收（无可见阻断项）

依据[原设计评审](../audit-2026-09-10/report.md)完成 7 项优先修复、3 项体验优化，并复核深色文字操作、菜单互斥与大字弹窗留白。本轮记录 39 张截图，36 张作为当前可见证据；中间失败或被替代的 24、25、37 单独保留。全部 9 页都有本轮证据。ImageGen 收到 5 组主验收和 2 组补充证据。

[截图与验收索引](index.html) · [原始截图清单](manifest.json) · [完整 ImageGen 提示词与输入记录](review-jobs.json) · [代码差异](changes.patch)

## 按原评审逐项落实

| 原编号 | 原问题 | 完成的调整 | 复查证据 |
|---|---|---|---|
| F01 · P1 | Drawer 选中背景偏移 | 选中背景铺满目的地行；图标与标签使用一致的选中语义 | [08](screenshots/08-navigation-home.jpg)–[12](screenshots/12-navigation-narrow.jpg)；1440/480 宽下逐一测试三个目的地 |
| F02 · P1 | ACP 填值后保留必填错误 | 曾提交的表单在场景自动填值后重新验证 | [02](screenshots/02-connection-empty-error.jpg)→[03](screenshots/03-connection-acp-valid.jpg)；保留真实错误样本 |
| F03 · P2 | 中文日期与星期被拆开 | Gregorian 日期格式保留中文语义单位；横向大字模式使用受约束的宽标题面板 | [13](screenshots/13-date-entry-dark.jpg)、[15](screenshots/15-range-entry-dark.jpg)、[27](screenshots/27-range-entry-scale200-fixed.jpg)、[38](screenshots/38-long-date-scale200-fixed.jpg)、[39](screenshots/39-date-scale200-final.jpg) |
| F04 · P2 | 全局搜索空反馈在底部 | 空结果放在列表起始位置，就近提供清空并恢复搜索焦点 | [18](screenshots/18-search-empty.jpg)、[31](screenshots/31-search-empty-light.jpg) |
| F05 · P2 | 保存操作不易发现 | 表单底部固定操作区；连接页代码说明折叠；窄屏状态样本折叠 | [01](screenshots/01-connection-dark-initial.jpg)、[06](screenshots/06-connection-narrow-light.jpg)、[07](screenshots/07-connection-narrow-touch-scroll.jpg) |
| F06 · P2 | 初始未修改却提示未保存 | 从草稿与保存值比较得到 dirty；初始已保存，保存/取消禁用 | [01](screenshots/01-connection-dark-initial.jpg)、[04](screenshots/04-connection-saving.jpg)、[05](screenshots/05-connection-saved.jpg) |
| F07 · P2 | 时间上午选中出现紫色 | 上午/下午使用 Ianvs 蓝色选中背景、文字和边界 | [16](screenshots/16-time-clock-am.jpg)、[17](screenshots/17-time-entry-pm.jpg) |
| P3 工具层级 | 复制与密度各占一行 | 合并工具行，复制示例降为文字次要操作 | [21](screenshots/21-actions-narrow.jpg)、[32](screenshots/32-actions-narrow-light.jpg) |
| P3 数字纠正 | 99 自动变成 32 缺乏解释 | 明确“范围 8–32；超出范围会调整到最近边界” | [35](screenshots/35-stepper-out-of-range-light.jpg)→[36](screenshots/36-stepper-clamped-light.jpg) |
| P3 工作区 | 循环切换缺少目的地预告 | 带当前值的概览/文件/设置菜单，可直接选择 | [33](screenshots/33-workspace-menu-light.jpg)→[34](screenshots/34-workspace-selected-light.jpg) |

## 待验证意见的处理

- 深色文字操作：TextButton 与 Snackbar 行动文字通过保留色相的明度校准，在内置 canvas/chrome/field/raised/selected 五种表面上达到至少 4.5:1 的计算对比度；浅深主题及黄色、紫色、黑、白自定义 accent 均有测试。此结论只涵盖测试中的前景/背景组合。截图 [19](screenshots/19-feedback-dark-actions.jpg)、[20](screenshots/20-feedback-snackbar.jpg)；ImageGen 主验收 05 与补充 06。
- 菜单互斥：用连续 pointer 点击快捷菜单再点文件菜单，自动化回归确认旧菜单关闭。没有将上一轮的自动化焦点现象当成已确认产品缺陷，未修改菜单实现。
- 大字确认留白：标题 padding 顶部调整到 28，正文和两个操作完整；继续编辑保留默认安全焦点。截图 [26](screenshots/26-confirm-scale200.jpg)，补充验收 06 确认蓝色焦点轮廓可见。
- 额外发现：辅助功能模式可能持续显示带操作的 Snackbar。切换目录页面时清空队列并立即移除当前提示，避免旧页面操作残留；新增对应回归测试。

## 页面步骤与健康度

| 步骤 | 页面 | 本轮健康度 | 原始截图 |
|---|---|---|---|
| 1 | 按钮 | 工具行与次要操作层级已校准 | [21](screenshots/21-actions-narrow.jpg)、[32](screenshots/32-actions-narrow-light.jpg) |
| 2 | 输入与选择 | 日期单位、长日期、大字布局和时段选中色已校准 | [13](screenshots/13-date-entry-dark.jpg)–[17](screenshots/17-time-entry-pm.jpg)、[27](screenshots/27-range-entry-scale200-fixed.jpg)、[38](screenshots/38-long-date-scale200-fixed.jpg)、[39](screenshots/39-date-scale200-final.jpg) |
| 3 | 导航 | 三个目的地、深浅主题及窄屏选中背景已校准 | [08](screenshots/08-navigation-home.jpg)–[12](screenshots/12-navigation-narrow.jpg) |
| 4 | 反馈 | 操作文字与撤销可读性已校准 | [19](screenshots/19-feedback-dark-actions.jpg)、[20](screenshots/20-feedback-snackbar.jpg) |
| 5 | 扩展组件 | 数值范围说明与边界状态已校准 | [28](screenshots/28-stepper-out-of-range.jpg)、[29](screenshots/29-stepper-clamped.jpg)、[35](screenshots/35-stepper-out-of-range-light.jpg)、[36](screenshots/36-stepper-clamped-light.jpg) |
| 6 | 连接设置 | 错误、保存状态和固定操作区已校准 | [01](screenshots/01-connection-dark-initial.jpg)–[07](screenshots/07-connection-narrow-touch-scroll.jpg) |
| 7 | 工作区 | 窄屏目的地可直接选择，当前值明确 | [22](screenshots/22-workspace-narrow-menu.jpg)、[23](screenshots/23-workspace-narrow-selected.jpg)、[33](screenshots/33-workspace-menu-light.jpg)、[34](screenshots/34-workspace-selected-light.jpg) |
| 8 | 确认与退出 | 200% 标题留白、正文和安全焦点已复核 | [26](screenshots/26-confirm-scale200.jpg) |
| 9 | 设计规范与公共框架 | 规范保持一致，目录空反馈位置已校准 | [30](screenshots/30-foundations-dark.jpg)、[31](screenshots/31-search-empty-light.jpg) |

## ImageGen 验收记录与采纳边界

| 组 | 原始输出 | 复核后的状态 |
|---|---|---|
| 01 连接设置 | [验收板](reviews/01-connection.png) | 通过 |
| 02 导航 | [验收板](reviews/02-navigation.png) | 通过 |
| 03 日期时间 | [验收板](reviews/03-dates-time.png) | 常规、范围、时间、错误态通过；最终长日期布局见 07 |
| 04 目录与工作区 | [验收板](reviews/04-catalog-workspace.png) | 目录、工具栏、菜单和规范通过；数值证据转交 07 补验 |
| 05 反馈与确认 | [验收板](reviews/05-feedback-dialog.png) | 可读性和留白通过；两项证据不足转交 06 |
| 06 反馈补充 | [验收板](reviews/06-feedback-supplement.png) | 查看项目与继续编辑焦点轮廓通过 |
| 07 数值与长日期补充 | [验收板](reviews/07-boundaries-long-dates.png) | ImageGen 已通过本轮视觉验收（无可见阻断项） |

评审板是 ImageGen 的视觉意见，**原始截图才是产品现状证据**。生成板中存在局部重绘、错误日期与混用 F 编号，编号以本报告原评审映射为准。03 将下午输入截图重绘成上午表盘，04 将实际左侧 99/32 控件误绘成旁边固定边界 8；这些绘制内容不被采纳。05 的“查看项目/焦点不在图中”已通过原尺寸证据提交 06 复验。全部中间评审板和提示词原样保存，没有删去不通过结论。

范围中间版 25 出现省略后重新调整，最终 27 完整显示；长日期中间版 37 拆开“日”后扩展单日期宽标题布局，最终 38 完整显示。旧常规日期 24 被最终 39 替代。

## 功能与代码验证

- [基础组件测试](verification/root-tests.log)：62 项通过。
- [Gallery 全量测试](verification/gallery-tests.log)：68 项通过，合计 130 项。覆盖导航选中背景包住图标和文字、ACP 错误刷新、初始保存状态、固定操作区、搜索清空、目的地选择、跨页 Snackbar 清理，以及 200% 日期范围与 12 月 31 日完整标题。
- [静态分析](verification/analyze.log)：No issues found。
- [Web release 构建](verification/web-build.log)：成功。校准目标为当前本地浏览器中的 Flutter Web 应用。

新增 [IanvsGregorianCalendarDelegate](../../../lib/src/foundation/calendar.dart) 并公开导出；它只影响日期展示中的中文分行单位，解析与日历计算仍使用 Material。Gallery 的大字日期面板布局位于 [stories.dart](../../../example/lib/gallery/stories.dart)，宿主应用采用该能力时需要同时考虑自身弹窗容器。

## 覆盖范围与剩余限制

本轮围绕原评审修改项及共享主题回归，结合原评审 126 张有效截图；没有重新穷举每个组件实例与全部输入组合。桌面 1440×1000、窄屏 480×900，大字样本 1280×720，`scale=2` 为应用文字缩放。部分已提交导航前后图的当前目的地或窄屏主题不同，相关状态已分别检查，不能用于像素级同态差分。

ImageGen 负责可见设计验收；130 项代码测试提供独立交互证据。截图与当前测试不构成完整无障碍认证，仍未穷举 hover/按住瞬间、所有键盘路径、全部语言/日期值、极小窗口和原生 macOS 宿主行为。大字单日期保留较宽纵向留白；精简该留白属于后续非阻断优化，不能降低文字可读性。
