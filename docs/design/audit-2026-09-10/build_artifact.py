"""Create an offline audit index from real screenshots and ImageGen outputs."""
import hashlib
import html
import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parent
manifest = json.loads((ROOT / 'manifest.json').read_text())
groups = json.loads((ROOT / 'review-groups.json').read_text())
jobs = json.loads((ROOT / 'review-jobs.json').read_text())
titles = ['连接设置与全局控件','按钮','输入与菜单','选择控件与Chip','日期与时间','导航','反馈','扩展组件与代码面板','工作区','确认、对话框与底部面板','基础规范与搜索','窄屏与大字模式']
for folder in ('reviews','prompts'):
    (ROOT / folder).mkdir(exist_ok=True)
completed = []
for job in jobs:
    assert job['prompt'], job['id']
    (ROOT / 'prompts' / (job['id'] + '.txt')).write_text(job['prompt'])
    paths = re.findall(r'/[^\s]+\.png', job.get('output_hint') or '')
    if paths:
        src = Path(paths[-1])
        dst = ROOT / 'reviews' / (job['id'] + '.png')
        shutil.copy2(src,dst)
        completed.append(job['id'])
accepted = [s for s in manifest if s['verified']]
assigned = [s['name'] for g in groups for s in g['screenshots']]
assert len(assigned) == len(set(assigned)) == len(accepted)
assert set(assigned) == {s['name'] for s in accepted}
for item in manifest:
    path = ROOT / 'screenshots' / (item['name'] + '.png')
    item['sha256'] = hashlib.sha256(path.read_bytes()).hexdigest()
(ROOT / 'manifest.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
coverage = {'pages':9,'captured':len(manifest),'accepted':len(accepted),'excluded':len(manifest)-len(accepted),'imagegen_groups':len(groups),'imagegen_completed':len(completed),'groups':[{'id':g['id'],'title':titles[i],'screenshots':len(g['screenshots']),'review_complete':g['id'] in completed} for i,g in enumerate(groups)],'limits':['未穷举组件实例与主题、密度、输入值的全部组合','Tooltip悬停气泡未捕获','未完成屏幕阅读器、对比度数值和完整键盘遍历验证']}
(ROOT / 'coverage.json').write_text(json.dumps(coverage,ensure_ascii=False,indent=2))

def e(s): return html.escape(str(s),quote=True)
sections=[]
for i,g in enumerate(groups):
    cards=[]
    for s in g['screenshots']:
        cards.append(f'<figure class="shot" data-search="{e(s["name"]+" "+s["note"])}"><a href="screenshots/{e(s["name"])}.png" target="_blank"><img loading="lazy" src="screenshots/{e(s["name"])}.png" alt="{e(s["note"])}"></a><figcaption><strong>{e(s["name"])}</strong><p>{e(s["note"])}</p><small>{s["width"]} × {s["height"]} · 文字 {int(s["text_scale"]*100)}%</small></figcaption></figure>')
    review = f'<details class="review"><summary>查看本组 ImageGen 视觉建议</summary><p class="caution">以下为原始生成意见。局部可能重绘、误判或混用编号；现状以原图为准，采纳项见完整报告。</p><a href="reviews/{g["id"]}.png" target="_blank"><img loading="lazy" src="reviews/{g["id"]}.png" alt="{e(titles[i])} ImageGen评审板"></a><p><a href="prompts/{g["id"]}.txt">查看完整提示词</a></p></details>' if g['id'] in completed else '<p>本组评审图生成中。</p>'
    sections.append(f'<section id="{g["id"]}"><h2>{i+1:02d} · {e(titles[i])} <span>{len(g["screenshots"])} 张</span></h2>{review}<div class="grid">'+''.join(cards)+'</div></section>')
nav=''.join(f'<a href="#{g["id"]}">{i+1:02d} {e(titles[i])}</a>' for i,g in enumerate(groups))
excluded=''.join(f'<li><a href="screenshots/{e(s["name"])}.png">{e(s["name"])}</a>：{e(s["exclusion_reason"])}</li>' for s in manifest if not s['verified'])
doc='''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Ianvs Design · 状态截图与设计评审</title><style>
*{box-sizing:border-box}html{scroll-behavior:smooth;scroll-padding-top:90px}body{margin:0;background:#f6f7fa;color:#182434;font:15px/1.6 -apple-system,BlinkMacSystemFont,"PingFang SC",sans-serif}header,main{max-width:1440px;margin:auto;padding:32px}header{padding-top:44px}h1{font-size:32px;margin:4px 0 14px}h2{font-size:24px;margin:0 0 14px}h2 span{font-size:14px;font-weight:400;color:#657183}a{color:#0969da;text-underline-offset:3px}p{margin:10px 0}.eyebrow{letter-spacing:.08em;font-size:12px;color:#526076}.stats{display:flex;gap:12px;flex-wrap:wrap;margin:22px 0}.stats span{padding:8px 14px;background:white;border:1px solid #d8e0ea;border-radius:8px}.summary{padding:20px 24px;background:#e9f1fd;border-left:4px solid #0969da;border-radius:4px}.summary strong{font-size:17px}nav{position:sticky;top:0;background:#fffffff2;backdrop-filter:blur(14px);border-block:1px solid #d8e0ea;z-index:1;padding:12px 32px;display:flex;gap:10px;align-items:center}nav select,nav input{border:1px solid #b7c4d5;border-radius:6px;padding:9px;font:inherit;min-width:0}nav input{width:360px}nav select{max-width:280px}.directory{display:flex;flex-wrap:wrap;gap:8px 18px;margin:0 0 28px}.directory a{white-space:nowrap}section{margin:20px 0 48px}.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:20px}.shot{margin:0;border:1px solid #d8e0ea;border-radius:10px;overflow:hidden;background:white;box-shadow:0 2px 7px #18243407}.shot>a{display:block;height:270px;background:#e9edf2;border-bottom:1px solid #d8e0ea}.shot img{width:100%;height:100%;object-fit:contain;display:block}.shot figcaption{padding:14px 16px}.shot strong{font-size:13px;overflow-wrap:anywhere}.shot p{min-height:48px}.shot small{color:#637388}.review{background:white;border:1px solid #ccd8e6;border-radius:8px;margin:0 0 20px;padding:14px 20px}.review summary{cursor:pointer;font-weight:600}.review img{max-width:100%;height:auto;display:block}.caution{color:#72521c;background:#fff5df;padding:12px;border-radius:5px}.limits{background:white;padding:22px;border:1px solid #d8e0ea;border-radius:8px}.hidden{display:none!important}footer{padding:32px;color:#526076;text-align:center}a:focus-visible,summary:focus-visible{outline:3px solid #0969da;outline-offset:4px}@media(max-width:1050px){.grid{grid-template-columns:repeat(2,minmax(0,1fr))}}@media(max-width:650px){header,main{padding:20px}.grid{grid-template-columns:1fr}h1{font-size:26px}nav{padding:10px;flex-wrap:wrap}nav input{flex:1}nav select{width:170px}.shot>a{height:300px}.stats{gap:8px}}
</style><header><div class="eyebrow">IANVS DESIGN / VISUAL AUDIT / 2026-09-10</div><h1>页面与组件交互状态设计评审</h1><p>先操作并截图，再分组交给 ImageGen 评审；结论逐项回到原始截图核对。</p>'''
doc+=f'<div class="stats"><span><b>9</b> 个页面</span><span><b>{len(accepted)}</b> 张有效截图</span><span><b>{len(completed)} / 12</b> 组 ImageGen 评审</span><span>深浅主题 · 480px · 200%文字</span></div>'
doc+='<div class="summary"><strong>优先修复：导航选中背景错位、连接场景切换后的陈旧错误。</strong><p>随后处理日期拆字、搜索空结果位置、连接保存操作的可见性、初始未保存状态和时间选中色。</p><a href="report.md">阅读完整评审、组件覆盖表与证据限制</a></div><p><a href="manifest.json">截图清单</a> · <a href="coverage.json">覆盖统计</a> · <a href="review-jobs.json">ImageGen 提交记录</a></p></header>'
doc+='<nav aria-label="截图筛选"><label for="q">筛选</label><input id="q" type="search" placeholder="状态、组件名或截图编号"><label for="jump">分组</label><select id="jump"><option value="">跳转到分组</option>'+''.join(f'<option value="{g["id"]}">{e(titles[i])}</option>' for i,g in enumerate(groups))+'</select><output id="count"></output></nav><main><div class="directory">'+nav+'</div>'+''.join(sections)
doc+='<div class="limits"><h2>覆盖范围</h2><p>主要交互状态按组件族归档；不是所有实例、主题、密度和输入值的全组合。Tooltip悬停气泡、逐个组件按住瞬间、完整键盘和屏幕阅读器检查未覆盖。详细限制见报告。</p><details><summary>7 张排除截图及原因</summary><ul>'+excluded+'</ul></details></div></main><footer>原始截图与生成意见分开保存 · 本次未修改产品代码</footer><script>const q=document.getElementById("q"),shots=[...document.querySelectorAll(".shot")];q.addEventListener("input",()=>{let n=0;const term=q.value.trim().toLowerCase();for(const s of shots){const ok=s.dataset.search.toLowerCase().includes(term);s.classList.toggle("hidden",!ok);if(ok)n++;}for(const sec of document.querySelectorAll("section")){sec.classList.toggle("hidden",![...sec.querySelectorAll(".shot")].some(s=>!s.classList.contains("hidden")));}document.getElementById("count").textContent=n+" 张";});document.getElementById("jump").addEventListener("change",e=>{if(e.target.value){q.value="";q.dispatchEvent(new Event("input"));document.getElementById(e.target.value).scrollIntoView();}});document.getElementById("count").textContent=shots.length+" 张";</script></html>'
(ROOT / 'index.html').write_text(doc)
bad=[]
for link in re.findall(r'\]\(([^)]+)\)',(ROOT / 'report.md').read_text()):
    if link.startswith(('http','#')): continue
    target=re.sub(r':\d+$','',link)
    if not (ROOT / target).exists(): bad.append(link)
assert not bad,bad
print(json.dumps(coverage,ensure_ascii=False))
