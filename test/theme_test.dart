import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

class ExtraTheme extends ThemeExtension<ExtraTheme> {
  const ExtraTheme();
  @override
  ExtraTheme copyWith() => this;
  @override
  ExtraTheme lerp(covariant ExtraTheme? other, double t) => this;
}

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
}

void main() {
  test('preserves host extensions and interpolates custom Ianvs tokens', () {
    final theme = IanvsTheme.build(
      base: ThemeData(extensions: const [ExtraTheme()]),
    );
    expect(theme.extension<ExtraTheme>(), isNotNull);
    expect(theme.extension<IanvsTokens>(), isNotNull);
    final middle = ThemeData.lerp(IanvsTheme.light(), IanvsTheme.dark(), .5);
    expect(middle.extension<IanvsTokens>()!.controlHeight, 32);
    expect(
      middle.extension<IanvsTokens>()!.canvas,
      isNot(IanvsTokens.light.canvas),
    );
  });
  for (final brightness in Brightness.values) {
    testWidgets(
      'filled and tonal buttons resolve distinct intended colors $brightness',
      (tester) async {
        final theme = IanvsTheme.build(brightness: brightness);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Column(
                children: [
                  FilledButton(
                    key: const ValueKey('primary'),
                    onPressed: () {},
                    child: const Text('Primary'),
                  ),
                  FilledButton.tonal(
                    key: const ValueKey('tonal'),
                    onPressed: () {},
                    child: const Text('Tonal'),
                  ),
                ],
              ),
            ),
          ),
        );
        for (final entry in {
          'primary': theme.colorScheme.primary,
          'tonal': theme.colorScheme.secondaryContainer,
        }.entries) {
          final material = tester.widget<Material>(
            find
                .descendant(
                  of: find.byKey(ValueKey(entry.key)),
                  matching: find.byType(Material),
                )
                .first,
          );
          expect(material.color, entry.value);
        }
      },
    );
    test('text and action contrast $brightness', () {
      final theme = IanvsTheme.build(brightness: brightness);
      final t = theme.extension<IanvsTokens>()!;
      for (final pair in [
        (t.text, t.canvas),
        (t.muted, t.canvas),
        (t.subtle, t.field),
        (t.onSelected, t.selected),
        (theme.colorScheme.onPrimary, theme.colorScheme.primary),
        (t.danger, t.field),
        for (final surface in [
          t.canvas,
          t.chrome,
          t.field,
          t.raised,
          t.selected,
        ])
          (theme.textButtonTheme.style!.foregroundColor!.resolve({})!, surface),
      ]) {
        expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
      }
    });
    test('custom accent foreground remains readable $brightness', () {
      for (final accent in [
        Colors.yellow,
        Colors.deepPurple,
        Colors.white,
        Colors.black,
      ]) {
        final scheme = IanvsTheme.build(
          brightness: brightness,
          accent: accent,
        ).colorScheme;
        expect(
          contrast(scheme.primary, scheme.onPrimary),
          greaterThanOrEqualTo(4.5),
        );
        final custom = IanvsTheme.build(brightness: brightness, accent: accent);
        final tokens = custom.extension<IanvsTokens>()!;
        for (final surface in [tokens.canvas, tokens.raised, tokens.selected]) {
          expect(
            contrast(
              custom.textButtonTheme.style!.foregroundColor!.resolve({})!,
              surface,
            ),
            greaterThanOrEqualTo(4.5),
          );
        }
      }
    });
  }
}
