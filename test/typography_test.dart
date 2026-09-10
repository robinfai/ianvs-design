import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

void main() {
  test(
    'platform defaults and explicit font overrides are independent of body',
    () {
      for (final entry in {
        TargetPlatform.macOS: 'Menlo',
        TargetPlatform.iOS: 'Menlo',
        TargetPlatform.windows: 'Consolas',
        TargetPlatform.linux: 'DejaVu Sans Mono',
        TargetPlatform.android: 'monospace',
        TargetPlatform.fuchsia: 'monospace',
      }.entries) {
        final theme = IanvsTheme.build(platform: entry.key);
        final code = theme.extension<IanvsTypography>()!.code;
        expect(code.fontFamily, entry.value);
        expect(code.fontSize, 13);
        expect(code.height, 1.5);
        expect(code.color, theme.colorScheme.onSurface);
      }
      final theme = IanvsTheme.build(
        fontFamily: 'Body',
        monoFontFamily: 'BundledMono',
        monoFontFamilyFallback: const ['FallbackMono'],
        codeTextStyle: const TextStyle(fontSize: 15, height: 1.7),
      );
      final code = theme.extension<IanvsTypography>()!.code;
      expect(theme.textTheme.bodyMedium!.fontFamily, 'Body');
      expect(code.fontFamily, 'BundledMono');
      expect(code.fontFamilyFallback, ['FallbackMono']);
      expect(code.fontSize, 15);
      expect(code.height, 1.7);
      expect(code.color, theme.colorScheme.onSurface);
    },
  );

  test(
    'density, dark rebuild and interpolation retain readable code colors',
    () {
      final light = IanvsTheme.light();
      final dark = IanvsTheme.build(
        base: light,
        brightness: Brightness.dark,
        density: IanvsDensity.touch,
      );
      final lightCode = light.extension<IanvsTypography>()!.code;
      final darkCode = dark.extension<IanvsTypography>()!.code;
      expect(darkCode.color, dark.colorScheme.onSurface);
      expect(darkCode.color, isNot(lightCode.color));
      expect(darkCode.fontSize, 16);
      final middle = ThemeData.lerp(light, dark, .5);
      final code = middle.extension<IanvsTypography>()!.code;
      expect(code.color, Color.lerp(lightCode.color, darkCode.color, .5));
      expect(code.fontSize, 14.5);
    },
  );

  testWidgets('context lookup follows themes and supports plain Material', (
    tester,
  ) async {
    late TextStyle code;
    Widget app(ThemeData theme) => MaterialApp(
      theme: theme,
      themeAnimationDuration: Duration.zero,
      home: Builder(
        builder: (context) {
          code = context.ianvsTypography.code;
          expect(code, IanvsTypography.of(context).code);
          return Text('path/to/file.dart', style: code);
        },
      ),
    );
    await tester.pumpWidget(app(IanvsTheme.light()));
    expect(code.color, IanvsTokens.light.text);
    await tester.pumpWidget(app(IanvsTheme.dark()));
    expect(code.color, IanvsTokens.dark.text);
    final plain = ThemeData(platform: TargetPlatform.windows);
    await tester.pumpWidget(app(plain));
    expect(code.fontFamily, 'Consolas');
    expect(code.color, plain.colorScheme.onSurface);
  });
}
