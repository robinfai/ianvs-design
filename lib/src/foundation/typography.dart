import 'package:flutter/material.dart';
import 'tokens.dart';

/// Shared code and path typography. Fonts are resolved by the host platform;
/// applications that need a guaranteed font must bundle and configure one.
@immutable
class IanvsTypography extends ThemeExtension<IanvsTypography> {
  const IanvsTypography({required this.code});

  /// Monospaced text with a theme-aware foreground. Syntax and ANSI palettes
  /// remain the responsibility of the code renderer or terminal.
  final TextStyle code;

  static IanvsTypography defaults({
    required TargetPlatform platform,
    required Color color,
    IanvsDensity density = IanvsDensity.compact,
    String? monoFontFamily,
    List<String>? monoFontFamilyFallback,
    TextStyle? codeTextStyle,
  }) {
    final (family, fallbacks) = switch (platform) {
      TargetPlatform.macOS ||
      TargetPlatform.iOS => ('Menlo', const ['SF Mono', 'Monaco', 'monospace']),
      TargetPlatform.windows => (
        'Consolas',
        const ['Cascadia Mono', 'Courier New', 'monospace'],
      ),
      TargetPlatform.linux => (
        'DejaVu Sans Mono',
        const ['Liberation Mono', 'monospace'],
      ),
      TargetPlatform.android ||
      TargetPlatform.fuchsia => ('monospace', const <String>[]),
    };
    return IanvsTypography(
      code: TextStyle(
        fontFamily: monoFontFamily ?? family,
        fontFamilyFallback: monoFontFamilyFallback ?? fallbacks,
        fontSize: density == IanvsDensity.touch ? 16 : 13,
        height: 1.5,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: color,
      ).merge(codeTextStyle),
    );
  }

  /// Also works under a plain Material theme without an Ianvs extension.
  static IanvsTypography of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<IanvsTypography>() ??
        defaults(
          platform: theme.platform,
          color: theme.colorScheme.onSurface,
          density: IanvsTokens.of(context).density,
        );
  }

  @override
  IanvsTypography copyWith({TextStyle? code}) =>
      IanvsTypography(code: code ?? this.code);

  @override
  IanvsTypography lerp(covariant IanvsTypography? other, double t) =>
      other == null
      ? this
      : IanvsTypography(code: TextStyle.lerp(code, other.code, t)!);
}

extension IanvsTypographyContext on BuildContext {
  IanvsTypography get ianvsTypography => IanvsTypography.of(this);
}
