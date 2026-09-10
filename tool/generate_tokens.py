from pathlib import Path
fields = {
 'canvas':('Color','const Color(0xff202123)'), 'chrome':('Color','const Color(0xff1e1f21)'),
 'field':('Color','const Color(0xff292b2e)'), 'raised':('Color','const Color(0xff303236)'),
 'border':('Color','const Color(0xff45474d)'), 'separator':('Color','const Color(0xff37393e)'),
 'text':('Color','const Color(0xfff3f4f6)'), 'muted':('Color','const Color(0xffb9bcc4)'),
 'subtle':('Color','const Color(0xffa8adb7)'), 'accent':('Color','const Color(0xff0874df)'),
 'focus':('Color','const Color(0xff39a6ff)'), 'selected':('Color','const Color(0xff213d56)'),
 'onSelected':('Color','const Color(0xff8dceff)'), 'success':('Color','const Color(0xff75d3a7)'),
 'warning':('Color','const Color(0xffffc250)'), 'danger':('Color','const Color(0xffff8f8b)'),
 'controlHeight':('double','32'), 'controlRadius':('double','6'), 'panelRadius':('double','10'),
 'rowHeight':('double','40'), 'density':('IanvsDensity','IanvsDensity.compact'),
}
light={'canvas':'0xfffafafb','chrome':'0xfff3f3f5','field':'0xffffffff','raised':'0xffffffff','border':'0xffb9bcc3','separator':'0xffdedfe4','text':'0xff24262a','muted':'0xff60646c','subtle':'0xff676d76','accent':'0xff0969da','focus':'0xff0969da','selected':'0xffdeebfa','onSelected':'0xff0753a5','success':'0xff187047','warning':'0xff895700','danger':'0xffb52c2a'}
s='''import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// Explicit input density. Width alone never implies touch input.
enum IanvsDensity { compact, comfortable, touch }

/// Shared spacing in logical pixels. Prefer semantic layout over fixed heights.
abstract final class IanvsSpacing {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32, xxxl = 40;
}

abstract final class IanvsMotion {
  static const quick = Duration(milliseconds: 120);
  static const standard = Duration(milliseconds: 180);
  static Duration resolve(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : standard;
}

/// Additional semantic surfaces and desktop metrics. Standard widgets use ColorScheme.
@immutable
class IanvsTokens extends ThemeExtension<IanvsTokens> {
  const IanvsTokens({
'''
s+=''.join(f'    this.{k} = {v},\n' for k,(t,v) in fields.items())+'  });\n\n'
s+=''.join(f'  final {t} {k};\n' for k,(t,v) in fields.items())
s+='''
  static const dark = IanvsTokens();
  static const light = IanvsTokens(
'''+''.join(f'    {k}: Color({v}),\n' for k,v in light.items())+'  );\n'
s+='''
  static IanvsTokens of(BuildContext context) => Theme.of(context).extension<IanvsTokens>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  IanvsTokens withDensity(IanvsDensity value) => copyWith(
    density: value,
    controlHeight: switch (value) { IanvsDensity.compact => 32, IanvsDensity.comfortable => 40, IanvsDensity.touch => 48 },
    rowHeight: switch (value) { IanvsDensity.compact => 40, IanvsDensity.comfortable => 48, IanvsDensity.touch => 56 },
  );

  @override
  IanvsTokens copyWith({
'''+''.join(f'    {t}? {k},\n' for k,(t,v) in fields.items())+'  }) => IanvsTokens(\n'+''.join(f'    {k}: {k} ?? this.{k},\n' for k in fields)+'  );\n'
s+='''
  @override
  IanvsTokens lerp(covariant IanvsTokens? other, double t) {
    if (other == null) return this;
    return IanvsTokens(
'''
for k,(typ,v) in fields.items():
 expr=f'Color.lerp({k}, other.{k}, t)!' if typ=='Color' else (f'lerpDouble({k}, other.{k}, t)!' if typ=='double' else f't < .5 ? {k} : other.{k}')
 s+=f'      {k}: {expr},\n'
s+='    );\n  }\n}\n\nextension IanvsContext on BuildContext {\n  IanvsTokens get ianvs => IanvsTokens.of(this);\n}\n'
Path('lib/src/foundation/tokens.dart').write_text(s)
