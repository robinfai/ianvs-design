"""Build a local, evidence-linked calibration handoff; never alters source images."""
import difflib
import hashlib
import html
import json
import shutil
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent
PROJECT = ROOT.parents[2]
GENERATED = Path('/Users/robinfai/.codex/generated_images/01a08a30-73f1-7511-99d6-ba5332b9338a')
GROUPS = json.loads((ROOT / 'comparison-groups.json').read_text())
SHOTS = list({s['name']: s for s in json.loads((ROOT / 'screenshots.json').read_text())}.values())
SHOTS.sort(key=lambda s: s['name'])
for shot in SHOTS:
    path = Path(shot['path'])
    with Image.open(path) as im:
        shot.update(width=im.width, height=im.height, format=im.format)
    shot['sha256'] = hashlib.sha256(path.read_bytes()).hexdigest()
    shot.setdefault('accepted', True)
(ROOT / 'manifest.json').write_text(json.dumps(SHOTS, ensure_ascii=False, indent=2))

sources = {
    '01-connection': 'exec-6351f393-bdbc-48ee-a232-aae44c955cc2.png',
    '02-navigation': 'exec-3c172fd8-5dce-4bf1-b63b-c08bc5b793c4.png',
    '03-dates-time': 'exec-b297f529-a380-4303-860d-cab9e0a9a7a1.png',
    '04-catalog-workspace': 'exec-41957967-4420-469c-aa91-8e681107f596.png',
    '05-feedback-dialog': 'exec-81a7f4f7-8e10-4605-a7bc-1ee21413b5b5.png',
    '06-feedback-supplement': 'exec-65459626-2e8c-4b2a-8445-3a7dffa0a2cc.png',
}
if (ROOT / 'final-review.json').exists():
    sources.update(json.loads((ROOT / 'final-review.json').read_text())['sources'])
jobs = []
for group in GROUPS:
    ident = group['id']
    prompt = ROOT / (ident + '-prompt.txt')
    source = sources.get(ident)
    if source:
        shutil.copy2(GENERATED / source, ROOT / 'reviews' / (ident + '.png'))
    jobs.append(dict(id=ident, prompt=prompt.read_text(), references=[{
        'path': p, 'sha256': hashlib.sha256(Path(p).read_bytes()).hexdigest()
    } for p in group['references']], original=str(GENERATED / source) if source else None,
    output='reviews/' + ident + '.png' if source else None))
(ROOT / 'review-jobs.json').write_text(json.dumps(jobs, ensure_ascii=False, indent=2))

changes, patch = [], []
for before in sorted((ROOT / 'before-code').rglob('*.before')):
    rel = Path(str(before.relative_to(ROOT / 'before-code'))[:-7])
    old, new = before.read_text(), (PROJECT / rel).read_text()
    if old != new:
        changes.append(str(rel))
        patch.extend(difflib.unified_diff(old.splitlines(True), new.splitlines(True), fromfile='a/' + str(rel), tofile='b/' + str(rel)))
for rel in ['lib/src/foundation/calendar.dart', 'example/test/calibration_test.dart']:
    changes.append(rel)
    patch.extend(difflib.unified_diff([], (PROJECT / rel).read_text().splitlines(True), fromfile='/dev/null', tofile='b/' + rel))
rel = 'lib/ianvs_design.dart'
new = (PROJECT / rel).read_text()
old = new.replace("export 'src/foundation/calendar.dart';\n", '')
changes.append(rel)
patch.extend(difflib.unified_diff(old.splitlines(True), new.splitlines(True), fromfile='a/' + rel, tofile='b/' + rel))
(ROOT / 'changes.patch').write_text(''.join(patch))
(ROOT / 'changed-files.json').write_text(json.dumps(changes, indent=2))
for src, dest in [('ianvs-root-calibration-tests.log', 'root-tests.log'), ('ianvs-example-calibration-tests.log', 'gallery-tests.log'), ('ianvs-calibration-analyze.log', 'analyze.log'), ('ianvs-final-calibration-build.log', 'web-build.log'), ('ianvs-final-calibration-tests.log', 'targeted-tests.log')]:
    shutil.copy2(Path('/private/tmp') / src, ROOT / 'verification' / dest)

final = json.loads((ROOT / 'final-review.json').read_text()) if (ROOT / 'final-review.json').exists() else {'status':'等待最后一组 ImageGen 验收'}
accepted = sum(s['accepted'] for s in SHOTS)
def shot(n):
    s = next(s for s in SHOTS if s['name'].startswith(f'{n:02d}-'))
    return f"[{n:02d}](screenshots/{s['name']}.jpg)"

rows = [
    ('1', '按钮', '工具行与次要操作层级已校准', f'{shot(21)}、{shot(32)}'),
    ('2', '输入与选择', '日期单位、长日期、大字布局和时段选中色已校准', f'{shot(13)}–{shot(17)}、{shot(27)}、{shot(38)}、{shot(39)}'),
    ('3', '导航', '三个目的地、深浅主题及窄屏选中背景已校准', f'{shot(8)}–{shot(12)}'),
    ('4', '反馈', '操作文字与撤销可读性已校准', f'{shot(19)}、{shot(20)}'),
    ('5', '扩展组件', '数值范围说明与边界状态已校准', f'{shot(28)}、{shot(29)}、{shot(35)}、{shot(36)}'),
    ('6', '连接设置', '错误、保存状态和固定操作区已校准', f'{shot(1)}–{shot(7)}'),
    ('7', '工作区', '窄屏目的地可直接选择，当前值明确', f'{shot(22)}、{shot(23)}、{shot(33)}、{shot(34)}'),
    ('8', '确认与退出', '200% 标题留白、正文和安全焦点已复核', shot(26)),
    ('9', '设计规范与公共框架', '规范保持一致，目录空反馈位置已校准', f'{shot(30)}、{shot(31)}'),
]
page_table = '| 步骤 | 页面 | 本轮健康度 | 原始截图 |\n|---|---|---|---|\n' + '\n'.join('| ' + ' | '.join(row) + ' |' for row in rows)
report = f'''# Ianvs Design 校准与 ImageGen 验收

2026-09-10 · 本地 Flutter Web Gallery · {final['status']}

依据[原设计评审](../audit-2026-09-10/report.md)完成 7 项优先修复、3 项体验优化，并复核深色文字操作、菜单互斥与大字弹窗留白。本轮记录 {len(SHOTS)} 张截图，{accepted} 张作为当前可见证据；中间失败或被替代的 24、25、37 单独保留。全部 9 页都有本轮证据。ImageGen 收到 5 组主验收和 2 组补充证据。

[截图与验收索引](index.html) · [原始截图清单](manifest.json) · [完整 ImageGen 提示词与输入记录](review-jobs.json) · [代码差异](changes.patch)

## 按原评审逐项落实

| 原编号 | 原问题 | 完成的调整 | 复查证据 |
|---|---|---|---|
| F01 · P1 | Drawer 选中背景偏移 | 选中背景铺满目的地行；图标与标签使用一致的选中语义 | {shot(8)}–{shot(12)}；1440/480 宽下逐一测试三个目的地 |
| F02 · P1 | ACP 填值后保留必填错误 | 曾提交的表单在场景自动填值后重新验证 | {shot(2)}→{shot(3)}；保留真实错误样本 |
| F03 · P2 | 中文日期与星期被拆开 | Gregorian 日期格式保留中文语义单位；横向大字模式使用受约束的宽标题面板 | {shot(13)}、{shot(15)}、{shot(27)}、{shot(38)}、{shot(39)} |
| F04 · P2 | 全局搜索空反馈在底部 | 空结果放在列表起始位置，就近提供清空并恢复搜索焦点 | {shot(18)}、{shot(31)} |
| F05 · P2 | 保存操作不易发现 | 表单底部固定操作区；连接页代码说明折叠；窄屏状态样本折叠 | {shot(1)}、{shot(6)}、{shot(7)} |
| F06 · P2 | 初始未修改却提示未保存 | 从草稿与保存值比较得到 dirty；初始已保存，保存/取消禁用 | {shot(1)}、{shot(4)}、{shot(5)} |
| F07 · P2 | 时间上午选中出现紫色 | 上午/下午使用 Ianvs 蓝色选中背景、文字和边界 | {shot(16)}、{shot(17)} |
| P3 工具层级 | 复制与密度各占一行 | 合并工具行，复制示例降为文字次要操作 | {shot(21)}、{shot(32)} |
| P3 数字纠正 | 99 自动变成 32 缺乏解释 | 明确“范围 8–32；超出范围会调整到最近边界” | {shot(35)}→{shot(36)} |
| P3 工作区 | 循环切换缺少目的地预告 | 带当前值的概览/文件/设置菜单，可直接选择 | {shot(33)}→{shot(34)} |

## 待验证意见的处理

- 深色文字操作：TextButton 与 Snackbar 行动文字通过保留色相的明度校准，在内置 canvas/chrome/field/raised/selected 五种表面上达到至少 4.5:1 的计算对比度；浅深主题及黄色、紫色、黑、白自定义 accent 均有测试。此结论只涵盖测试中的前景/背景组合。截图 {shot(19)}、{shot(20)}；ImageGen 主验收 05 与补充 06。
- 菜单互斥：用连续 pointer 点击快捷菜单再点文件菜单，自动化回归确认旧菜单关闭。没有将上一轮的自动化焦点现象当成已确认产品缺陷，未修改菜单实现。
- 大字确认留白：标题 padding 顶部调整到 28，正文和两个操作完整；继续编辑保留默认安全焦点。截图 {shot(26)}，补充验收 06 确认蓝色焦点轮廓可见。
- 额外发现：辅助功能模式可能持续显示带操作的 Snackbar。切换目录页面时清空队列并立即移除当前提示，避免旧页面操作残留；新增对应回归测试。

## 页面步骤与健康度

{page_table}

## ImageGen 验收记录与采纳边界

| 组 | 原始输出 | 复核后的状态 |
|---|---|---|
| 01 连接设置 | [验收板](reviews/01-connection.png) | 通过 |
| 02 导航 | [验收板](reviews/02-navigation.png) | 通过 |
| 03 日期时间 | [验收板](reviews/03-dates-time.png) | 常规、范围、时间、错误态通过；最终长日期布局见 07 |
| 04 目录与工作区 | [验收板](reviews/04-catalog-workspace.png) | 目录、工具栏、菜单和规范通过；数值证据转交 07 补验 |
| 05 反馈与确认 | [验收板](reviews/05-feedback-dialog.png) | 可读性和留白通过；两项证据不足转交 06 |
| 06 反馈补充 | [验收板](reviews/06-feedback-supplement.png) | 查看项目与继续编辑焦点轮廓通过 |
| 07 数值与长日期补充 | [验收板](reviews/07-boundaries-long-dates.png) | {final['status']} |

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
'''
(ROOT / 'report.md').write_text(report)

def card(path, label, note='', badge=''):
    e = html.escape
    return f'<article><a href="{e(path)}" target="_blank"><img loading="lazy" src="{e(path)}" alt="{e(label)}"></a><div><b>{e(label)}</b> <span>{e(badge)}</span><p>{e(note)}</p><a href="{e(path)}" target="_blank">打开原图</a></div></article>'

cards = '\n'.join(card('screenshots/' + s['name'] + '.jpg', s['name'], s['note'], '当前证据' if s['accepted'] else '中间版本 · 不用于最终结论') for s in SHOTS)
reviews = '\n'.join(card(j['output'], j['id'], 'ImageGen 原始输出；结论须结合原始截图和补充验收阅读。') for j in jobs if j['output'])
comparisons = '\n'.join(card(str(p.relative_to(ROOT)), p.stem, '仅在截图之外增加编号与间隔；截图像素未缩放或修饰。') for p in sorted((ROOT / 'comparisons').glob('*.png')))
health_rows = '\n'.join('<tr>' + ''.join(f'<td>{html.escape(c)}</td>' for c in row[:3]) + '</tr>' for row in rows)
page = f'''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Ianvs Design · 校准验收</title>
<style>:root{{color-scheme:light dark}}*{{box-sizing:border-box}}body{{margin:0;background:#f6f7f9;color:#202734;font:15px/1.65 system-ui,sans-serif}}main{{max-width:1480px;margin:auto;padding:36px 28px}}h1{{font-size:32px;line-height:1.25;margin:0 0 12px}}h2{{margin:42px 0 16px;font-size:23px}}a{{color:#145eb5}}nav{{display:flex;gap:20px;flex-wrap:wrap;margin:20px 0}}.summary{{padding:18px 22px;background:#e8f4ed;border:1px solid #abd2b9;border-radius:10px}}.muted{{color:#5e6978}}.grid{{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:18px}}article{{border:1px solid #d8dde4;background:white;border-radius:10px;overflow:hidden}}article img{{display:block;width:100%;height:250px;object-fit:contain;background:#e9edf2}}article>div{{padding:14px}}article p{{font-size:13px;margin:8px 0}}article b{{overflow-wrap:anywhere}}article span{{font-size:11px;color:#526477}}table{{width:100%;border-collapse:collapse;background:white}}td,th{{padding:10px 14px;border:1px solid #d8dde4;text-align:left}}details{{margin:20px 0}}summary{{cursor:pointer;font-weight:600}}@media(max-width:600px){{main{{padding:22px 14px}}h1{{font-size:26px}}td,th{{padding:8px}}}}@media(prefers-color-scheme:dark){{body{{background:#181c23;color:#e7ecf4}}article,table{{background:#242a34}}a{{color:#84bbff}}article,td,th{{border-color:#414955}}article img{{background:#171b22}}.summary{{background:#183b2a;border-color:#356b4b}}.muted,article span{{color:#b1bdcf}}}}</style>
<main><p class="muted">IANVS DESIGN / 2026-09-10</p><h1>校准与 ImageGen 验收</h1><div class="summary"><strong>{html.escape(final['status'])}</strong><br>7 项优先修复 · 3 项体验优化 · 9 页复核 · 130 项测试通过 · {len(SHOTS)} 张截图 / {accepted} 张当前证据</div>
<nav><a href="http://127.0.0.1:4173/?theme=dark&page=connection&revision=final">打开校准后的应用</a><a href="report.md">完整报告</a><a href="manifest.json">截图清单</a><a href="review-jobs.json">ImageGen 生成记录</a><a href="changes.patch">代码差异</a></nav>
<p class="muted">原始截图是产品证据。ImageGen 评审板可能重绘细节或混用编号，需结合报告和补充验收阅读；中间失败与被替代版本均完整保留。</p>
<h2>页面复核</h2><table><thead><tr><th>步骤</th><th>页面</th><th>本轮健康度</th></tr></thead><tbody>{health_rows}</tbody></table>
<h2>ImageGen 原始验收板</h2><div class="grid">{reviews}</div><h2>前后对照</h2><div class="grid">{comparisons}</div><h2>逐张原始截图</h2><div class="grid">{cards}</div></main></html>'''
(ROOT / 'index.html').write_text(page)
print(json.dumps({'screenshots':len(SHOTS),'current_evidence':accepted,'reviews':len(sources),'changed_files':len(changes),'status':final['status']},ensure_ascii=False))
