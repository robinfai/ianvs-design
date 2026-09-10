# Third-party sources and licenses

The MIT license in `LICENSE` covers Ianvs Design's original code. It does not
replace the licenses of dependencies, referenced projects, or bundled assets.

## Flutter Material — BSD-3-Clause

Ianvs imports and re-exports `package:flutter/material.dart` and builds its
components with Flutter's Material APIs. Flutter is an SDK dependency and is
not vendored in this package.

- Project: https://github.com/flutter/flutter
- License: https://github.com/flutter/flutter/blob/master/LICENSE
- Local release verified with Flutter 3.44.2, revision `c9a6c48423`.
- The upstream copyright notice, redistribution conditions, and disclaimer
  remain applicable to Flutter source and binary distributions.

## TDesign Flutter — MIT

The Cascader, NumberStepper, and Skeleton use interaction ideas studied from
TDesign Flutter. They are implemented with Ianvs APIs and Material primitives;
`tdesign_flutter` is not a runtime dependency and its source files are not
vendored here.

- Project: https://github.com/Tencent/tdesign-flutter
- Reference revision: `031b1a06b98d928345fac33c0ddc89f03844ed09`
- License: https://github.com/Tencent/tdesign-flutter/blob/develop/LICENSE
- Copyright: (c) 2023-present TDesign, tdesign@tencent.com
- Adaptation notes: https://github.com/robinfai/ianvs-design/blob/main/docs/design/tdesign-adaptation.md

TDesign's MIT copyright and permission notice must remain with any copies or
substantial portions of its software.

## Cupertino Icons — MIT

`cupertino_icons` is a hosted package dependency. Its license remains in that
package: https://pub.dev/packages/cupertino_icons/license.

## Example fonts — SIL Open Font License 1.1

The gallery bundles Noto Sans SC and Roboto Mono under their own font licenses.
The font files belong to the example application, not the library's assets.
The full copyright and license notices are included alongside the fonts:

- `example/assets/fonts/NotoSansSC-OFL.txt`
- `example/assets/fonts/RobotoMono-OFL.txt`

The example registers these notices with Flutter's `LicenseRegistry`.
