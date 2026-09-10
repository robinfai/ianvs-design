import json
from pathlib import Path
from PIL import Image
root = Path(__file__).resolve().parent
items = json.loads((root / 'manifest.json').read_text())
excluded = {
 '15-actions-async-result': '重复加载帧，完成态见16。',
 '20-inputs-saved': '当时点击未触发提交；实际成功见20b。',
 '21-inputs-search-open': '当时未打开搜索菜单；有效展开见21b。',
 '54-navigation-view-unchecked': '重复快捷菜单操作反馈，未证明复选菜单状态。',
 '64-feedback-tooltip-visible': '未捕获到Tooltip气泡，不作为悬停证据。',
 '82-skeleton-restored': '仍处于加载中；内容恢复见84。',
 '123-inputs-scale-200': '截图辅助函数仍指向原标签，属于普通基础规范重复截图；真实缩放见124。',
}
corrections = {
 '22-inputs-search-empty': '搜索zz-no-match，无匹配连接菜单。',
 '28-inputs-controls-default': '输入页下部：滑块、Chip、日期和代码。',
 '32-inputs-chips-selected': 'FilterChip多选本地和远程，ChoiceChip选择舒适。',
 '33-inputs-chip-deleted': '实际为InputChip选中；删除状态见38，文件名为采集时暂定名。',
 '53-navigation-view-menu': '实际为快捷菜单选择重命名后的反馈；复选菜单见57。',
 '58-navigation-checkbox-toggled': '点击复选菜单后菜单关闭；未捕获重开后的取消勾选态。',
 '63-feedback-tooltip-trigger': '提示按钮点击反馈；未捕获悬停气泡。',
 '81-skeleton-reloading': '模拟重新加载中，按钮带加载指示并禁用，预览切换为骨架。',
 '124-inputs-scale-200': '1280×720、200%文字缩放：输入页默认。',
 '126-connection-scale-200-lower': '200%文字：滚动后的连接表单字段。',
 '128-supplements-scale-200-lower': '200%文字：级联路径与数字步进。',
}
for item in items:
    name = item['name']
    if name in corrections: item['note'] = corrections[name]
    item['verified'] = name not in excluded
    if name in excluded: item['exclusion_reason'] = excluded[name]
    im = Image.open(root / 'screenshots' / (name + '.png'))
    item['width'], item['height'] = im.size
    item['text_scale'] = 2 if 124 <= int(name.split('-')[0].rstrip('b')) <= 131 else 1
(root / 'manifest.json').write_text(json.dumps(items, ensure_ascii=False, indent=2))
print({'captured':len(items), 'accepted':sum(x['verified'] for x in items), 'excluded':len(excluded)})
