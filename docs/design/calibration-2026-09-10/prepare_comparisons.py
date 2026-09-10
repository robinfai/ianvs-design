"""Place original screenshot pixels side by side without resizing or retouching."""
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
BASE = ROOT.parent / 'audit-2026-09-10/screenshots'
OUT = ROOT / 'comparisons'
OUT.mkdir(exist_ok=True)
font = ImageFont.truetype('/System/Library/Fonts/Supplemental/Arial.ttf', 23)

def sheet(name, items):
    images = [Image.open(path).convert('RGB') for label, path in items]
    width = max(im.width for im in images)
    height = max(im.height for im in images)
    canvas = Image.new('RGB', (width*2+48, (height+56)*((len(images)+1)//2)+16), '#e3e6eb')
    draw = ImageDraw.Draw(canvas)
    for index, (im, (label, path)) in enumerate(zip(images, items)):
        x, y = 16+(index%2)*(width+16), 16+(index//2)*(height+56)
        draw.text((x,y), label, font=font, fill='#182434')
        canvas.paste(im,(x,y+40))
    output=OUT/(name+'.png')
    canvas.save(output)
    return str(output)

def pair(name, before, after):
    return sheet(name,[('BEFORE / '+before, BASE/(before+'.png')),('AFTER / '+after, ROOT/'screenshots'/(after+'.jpg'))])

groups=[]
groups.append({'id':'01-connection','references':[
    pair('01-layout','02-connection-dark-default','01-connection-dark-initial'),
    pair('02-validation','07-connection-acp','03-connection-acp-valid'),
    pair('03-narrow','110-connection-narrow','06-connection-narrow-light'),
    pair('04-scroll','111-connection-narrow-save','07-connection-narrow-touch-scroll'),
    sheet('05-connection-states',[(n,ROOT/'screenshots'/(n+'.jpg')) for n in ['02-connection-empty-error','04-connection-saving','05-connection-saved']]),
]})
groups.append({'id':'02-navigation','references':[
    pair('06-navigation-project','48-navigation-lower-default','09-navigation-project'),
    pair('07-navigation-dark','55-navigation-dark-lower','11-navigation-dark'),
    pair('08-navigation-narrow','115-navigation-narrow-lower','12-navigation-narrow'),
    sheet('09-navigation-destinations',[(n,ROOT/'screenshots'/(n+'.jpg')) for n in ['08-navigation-home','10-navigation-settings']]),
]})
(ROOT/'comparison-groups.json').write_text(json.dumps(groups,ensure_ascii=False,indent=2))
print(json.dumps(groups,ensure_ascii=False))
groups.append({'id':'03-dates-time','references':[
 pair('10-date-entry','36-inputs-date-entry','13-date-entry-dark'),
 pair('11-range-entry','40-inputs-range-entry','15-range-entry-dark'),
 pair('12-time-clock','41-inputs-time-clock','16-time-clock-am'),
 pair('13-time-input','42-inputs-time-entry','17-time-entry-pm'),
 sheet('14-date-large-text',[(n,ROOT/'screenshots'/(n+'.jpg')) for n in ['24-date-entry-scale200','25-range-entry-scale200','27-range-entry-scale200-fixed','14-date-invalid']]),
]})
groups.append({'id':'05-feedback-dialog','references':[
 pair('19-feedback-actions','59-feedback-dark-top','19-feedback-dark-actions'),
 pair('20-feedback-snackbar','60-feedback-snackbar','20-feedback-snackbar'),
 pair('21-confirm-large-text','131-confirm-scale-200','26-confirm-scale200'),
]})
(ROOT/'comparison-groups.json').write_text(json.dumps(groups,ensure_ascii=False,indent=2))
groups.append({'id':'04-catalog-workspace','references':[
 pair('15-search-empty','106-global-search-empty','31-search-empty-light'),
 pair('16-toolbar-narrow','112-actions-narrow','32-actions-narrow-light'),
 sheet('17-workspace-direct-menu',[('BEFORE / 107-workspace-narrow',BASE/'107-workspace-narrow.png'),('AFTER / 33-workspace-menu-light',ROOT/'screenshots/33-workspace-menu-light.jpg'),('AFTER / 34-workspace-selected-light',ROOT/'screenshots/34-workspace-selected-light.jpg')]),
 sheet('18-stepper-boundaries',[('BEFORE / 76-stepper-edit-out-of-range',BASE/'76-stepper-edit-out-of-range.png'),('AFTER / 35-stepper-out-of-range-light',ROOT/'screenshots/35-stepper-out-of-range-light.jpg'),('BEFORE / 77-stepper-clamped',BASE/'77-stepper-clamped.png'),('AFTER / 36-stepper-clamped-light',ROOT/'screenshots/36-stepper-clamped-light.jpg')]),
 pair('22-foundations','101-foundations-dark-top','30-foundations-dark'),
]})
groups.sort(key=lambda g:g['id'])
(ROOT/'comparison-groups.json').write_text(json.dumps(groups,ensure_ascii=False,indent=2))
groups.append({'id':'06-feedback-supplement','references':[str(ROOT/'screenshots/19-feedback-dark-actions.jpg'),str(ROOT/'screenshots/26-confirm-scale200.jpg')]})
groups.append({'id':'07-boundaries-long-dates','references':[
 str(ROOT/'screenshots/35-stepper-out-of-range-light.jpg'),
 str(ROOT/'screenshots/36-stepper-clamped-light.jpg'),
 sheet('23-long-date-refinement',[('BEFORE / 37-long-date-scale200',ROOT/'screenshots/37-long-date-scale200.jpg'),('AFTER / 38-long-date-scale200-fixed',ROOT/'screenshots/38-long-date-scale200-fixed.jpg')]),
 sheet('24-date-refinement',[('BEFORE / 24-date-entry-scale200',ROOT/'screenshots/24-date-entry-scale200.jpg'),('AFTER / 39-date-scale200-final',ROOT/'screenshots/39-date-scale200-final.jpg')]),
]})
(ROOT/'comparison-groups.json').write_text(json.dumps(groups,ensure_ascii=False,indent=2))
