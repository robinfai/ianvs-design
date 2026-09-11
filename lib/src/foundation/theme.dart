import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'tokens.dart';
import 'menu_style.dart';
import 'typography.dart';

/// Builds both Ianvs and standard Material 3 widget themes.
///
/// All Material APIs remain available. Pass [base] to preserve unrelated theme
/// extensions, and [accent] to customize the brand without hardcoded foregrounds.
/// `touchVisualDensity` changes visual metrics only when density is touch;
/// Material tap padding and the input mode remain unchanged.
abstract final class IanvsTheme {
  static ThemeData light({
    IanvsDensity density = IanvsDensity.compact,
    IanvsTouchVisualDensity touchVisualDensity =
        IanvsTouchVisualDensity.standard,
  }) => build(
    brightness: Brightness.light,
    density: density,
    touchVisualDensity: touchVisualDensity,
  );
  static ThemeData dark({
    IanvsDensity density = IanvsDensity.compact,
    IanvsTouchVisualDensity touchVisualDensity =
        IanvsTouchVisualDensity.standard,
  }) => build(
    brightness: Brightness.dark,
    density: density,
    touchVisualDensity: touchVisualDensity,
  );

  static ThemeData build({
    Brightness brightness = Brightness.light,
    IanvsDensity density = IanvsDensity.compact,
    IanvsTouchVisualDensity touchVisualDensity =
        IanvsTouchVisualDensity.standard,
    Color? accent,
    TargetPlatform? platform,
    ThemeData? base,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? monoFontFamily,
    List<String>? monoFontFamilyFallback,
    TextStyle? codeTextStyle,
  }) {
    var t =
        (brightness == Brightness.dark ? IanvsTokens.dark : IanvsTokens.light)
            .withDensity(density, touchVisualDensity: touchVisualDensity);
    if (accent != null) t = t.copyWith(accent: accent);
    final touch = density == IanvsDensity.touch;
    final compactTouch = t.isCompactTouch;
    final target = platform ?? defaultTargetPlatform;
    final iosTouch = touch && target == TargetPlatform.iOS;
    final nativeIos = target == TargetPlatform.iOS && !kIsWeb;
    final apple =
        target == TargetPlatform.macOS || target == TargetPlatform.iOS;
    final onAccent = foregroundFor(t.accent);
    final actionColor = _readableActionColor(accent ?? t.focus, [
      t.canvas,
      t.chrome,
      t.field,
      t.raised,
      t.selected,
    ]);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: t.accent,
          brightness: brightness,
        ).copyWith(
          primary: t.accent,
          onPrimary: onAccent,
          primaryContainer: t.selected,
          onPrimaryContainer: t.onSelected,
          secondary: t.accent,
          onSecondary: onAccent,
          secondaryContainer: t.selected,
          onSecondaryContainer: t.onSelected,
          tertiary: t.accent,
          onTertiary: onAccent,
          surface: t.canvas,
          onSurface: t.text,
          onSurfaceVariant: t.muted,
          surfaceContainerLowest: t.field,
          surfaceContainerLow: t.chrome,
          surfaceContainer: t.field,
          surfaceContainerHigh: t.raised,
          surfaceContainerHighest: t.raised,
          outline: t.border,
          outlineVariant: t.separator,
          error: t.danger,
          onError: foregroundFor(t.danger),
          errorContainer: Color.alphaBlend(
            t.danger.withValues(alpha: .12),
            t.canvas,
          ),
          onErrorContainer: t.danger,
          surfaceTint: Colors.transparent,
          inverseSurface: t.text,
          onInverseSurface: t.canvas,
        );
    final family =
        fontFamily ??
        (nativeIos
            ? Typography.blackCupertino.bodyMedium!.fontFamily
            : apple && !kIsWeb
            ? '.AppleSystemUIFont'
            : 'Arial');
    final fallbacks =
        fontFamilyFallback ??
        const ['PingFang SC', 'Noto Sans SC', 'Helvetica Neue', 'sans-serif'];
    final bodySize = compactTouch
        ? 16.0
        : (iosTouch ? 17.0 : (touch ? 16.0 : 13.0));
    TextStyle text(
      double size, [
      FontWeight weight = FontWeight.w400,
      Color? color,
    ]) => TextStyle(
      fontFamily: fontFamily == null && nativeIos && size >= 20
          ? Typography.blackCupertino.titleLarge!.fontFamily
          : family,
      fontFamilyFallback: fallbacks,
      fontSize: size,
      height: 1.4,
      fontWeight: weight,
      color: color ?? t.text,
      letterSpacing: 0,
    );
    final typography = TextTheme(
      displayLarge: text(40, FontWeight.w600),
      displayMedium: text(34, FontWeight.w600),
      displaySmall: text(28, FontWeight.w600),
      headlineLarge: text(26, FontWeight.w600),
      headlineMedium: text(24, FontWeight.w600),
      headlineSmall: text(22, FontWeight.w600),
      titleLarge: text(
        compactTouch ? 18 : (iosTouch ? 22 : 20),
        FontWeight.w600,
      ),
      titleMedium: text(
        compactTouch || iosTouch ? 17 : (touch ? 18 : 16),
        FontWeight.w600,
      ),
      titleSmall: text(
        compactTouch ? 15 : (iosTouch ? 17 : 14),
        FontWeight.w600,
      ),
      bodyLarge: text(compactTouch ? 16 : (touch ? 17 : 14)),
      bodyMedium: text(bodySize),
      bodySmall: text(
        compactTouch ? 13 : (iosTouch ? 15 : (touch ? 14 : 12)),
        FontWeight.w400,
        t.muted,
      ),
      labelLarge: text(bodySize, FontWeight.w500),
      labelMedium: text(
        compactTouch ? 13 : (iosTouch ? 15 : (touch ? 14 : 12)),
      ),
      labelSmall: text(
        compactTouch || iosTouch ? 13 : (touch ? 12 : 11),
        FontWeight.w400,
        t.muted,
      ),
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.controlRadius),
    );
    final panelShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(t.panelRadius),
      side: BorderSide(color: t.border),
    );
    final tap = touch
        ? MaterialTapTargetSize.padded
        : MaterialTapTargetSize.shrinkWrap;
    const densityValue = VisualDensity.standard;
    final outline = OutlineInputBorder(
      borderRadius: BorderRadius.circular(t.controlRadius),
      borderSide: BorderSide(color: t.border),
    );
    final input = InputDecorationThemeData(
      filled: true,
      fillColor: t.field,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: compactTouch
            ? 10
            : (touch ? 13 : (density == IanvsDensity.comfortable ? 10 : 6)),
      ),
      border: outline,
      enabledBorder: outline,
      focusedBorder: outline.copyWith(
        borderSide: BorderSide(color: t.focus, width: 2),
      ),
      errorBorder: outline.copyWith(borderSide: BorderSide(color: t.danger)),
      focusedErrorBorder: outline.copyWith(
        borderSide: BorderSide(color: t.danger, width: 2),
      ),
      disabledBorder: outline.copyWith(
        borderSide: BorderSide(color: t.separator),
      ),
      hintStyle: text(bodySize, FontWeight.w400, t.subtle),
      labelStyle: text(bodySize, FontWeight.w400, t.muted),
      helperStyle: text(
        compactTouch || iosTouch ? 13 : (touch ? 14 : 12),
        FontWeight.w400,
        t.muted,
      ),
      errorStyle: text(
        compactTouch || iosTouch ? 13 : (touch ? 14 : 12),
        FontWeight.w400,
        t.danger,
      ),
      errorMaxLines: 3,
      helperMaxLines: 3,
      prefixIconColor: t.muted,
      suffixIconColor: t.muted,
      prefixIconConstraints: BoxConstraints(
        minWidth: t.controlHeight,
        minHeight: t.controlHeight,
      ),
      suffixIconConstraints: BoxConstraints(
        minWidth: t.controlHeight,
        minHeight: t.controlHeight,
      ),
    );
    WidgetStateProperty<Color?> overlay(Color color) =>
        WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? color.withValues(alpha: .14)
              : states.contains(WidgetState.hovered)
              ? color.withValues(alpha: .08)
              : states.contains(WidgetState.focused)
              ? color.withValues(alpha: .12)
              : Colors.transparent,
        );
    ButtonStyle button({
      Color? fill,
      Color? foreground,
      bool outlined = false,
    }) => ButtonStyle(
      iconSize: compactTouch ? const WidgetStatePropertyAll(20) : null,
      minimumSize: WidgetStatePropertyAll(
        Size(t.controlHeight, t.controlHeight),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      shape: WidgetStatePropertyAll(shape),
      textStyle: WidgetStatePropertyAll(typography.labelLarge),
      tapTargetSize: tap,
      visualDensity: VisualDensity.standard,
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled)
            ? (fill == null ? Colors.transparent : t.raised)
            : fill,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) =>
            s.contains(WidgetState.disabled) ? t.subtle : foreground ?? t.text,
      ),
      overlayColor: overlay(foreground ?? t.text),
      side: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.focused)
            ? BorderSide(color: t.focus, width: 2)
            : outlined
            ? BorderSide(color: t.border)
            : BorderSide.none,
      ),
    );
    final menuStyle = MenuStyle(
      backgroundColor: WidgetStatePropertyAll(t.raised),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
      elevation: const WidgetStatePropertyAll(4),
      shape: WidgetStatePropertyAll(
        shape.copyWith(side: BorderSide(color: t.border)),
      ),
      padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
    );
    final seed = base ?? ThemeData(useMaterial3: true);
    return seed.copyWith(
      brightness: brightness,
      platform: target,
      colorScheme: scheme,
      scaffoldBackgroundColor: t.canvas,
      canvasColor: t.canvas,
      cardColor: t.field,
      textTheme: typography,
      primaryTextTheme: typography.apply(
        bodyColor: onAccent,
        displayColor: onAccent,
      ),
      extensions: [
        ...seed.extensions.values.where(
          (e) => e is! IanvsTokens && e is! IanvsTypography,
        ),
        t,
        IanvsTypography.defaults(
          platform: target,
          color: t.text,
          density: density,
          monoFontFamily: monoFontFamily,
          monoFontFamilyFallback: monoFontFamilyFallback,
          codeTextStyle: codeTextStyle,
        ),
      ],
      visualDensity: densityValue,
      materialTapTargetSize: tap,
      splashFactory: NoSplash.splashFactory,
      hoverColor: t.text.withValues(alpha: .06),
      focusColor: t.focus.withValues(alpha: .15),
      highlightColor: t.text.withValues(alpha: .10),
      disabledColor: t.subtle,
      dividerColor: t.separator,
      iconTheme: IconThemeData(
        color: t.muted,
        size: compactTouch ? 20 : (touch ? 22 : 18),
      ),
      inputDecorationTheme: input,
      filledButtonTheme: FilledButtonThemeData(
        style: button().copyWith(
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? t.subtle : null,
          ),
          overlayColor: WidgetStateProperty.resolveWith((s) => null),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: button(fill: t.raised, foreground: t.text, outlined: true),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: button(fill: t.field, outlined: true),
      ),
      textButtonTheme: TextButtonThemeData(
        style: button(foreground: actionColor),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: button().copyWith(
          padding: const WidgetStatePropertyAll(EdgeInsets.all(6)),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? t.subtle : null,
          ),
          overlayColor: WidgetStateProperty.resolveWith((s) => null),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: t.accent,
        foregroundColor: onAccent,
        elevation: 2,
        focusElevation: 3,
        hoverElevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: button(outlined: true).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? t.selected : t.field,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled)
                ? t.subtle
                : s.contains(WidgetState.selected)
                ? t.onSelected
                : t.muted,
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        side: BorderSide(color: t.muted),
        checkColor: WidgetStatePropertyAll(onAccent),
        materialTapTargetSize: tap,
      ),
      radioTheme: RadioThemeData(materialTapTargetSize: tap),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? t.subtle
              : s.contains(WidgetState.selected)
              ? onAccent
              : t.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.disabled)
              ? t.raised
              : s.contains(WidgetState.selected)
              ? t.accent
              : t.field,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (s) =>
              s.contains(WidgetState.selected) ? Colors.transparent : t.border,
        ),
        materialTapTargetSize: tap,
        padding: const EdgeInsets.all(2),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: t.accent,
        inactiveTrackColor: t.border,
        thumbColor: t.accent,
        overlayColor: t.focus.withValues(alpha: .15),
        trackHeight: 4,
        valueIndicatorColor: t.raised,
        valueIndicatorTextStyle: typography.labelMedium,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: 7,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: t.field,
        selectedColor: t.selected,
        disabledColor: t.raised,
        labelStyle: typography.labelLarge,
        secondaryLabelStyle: typography.labelLarge?.copyWith(
          color: t.onSelected,
        ),
        side: BorderSide(color: t.border),
        shape: shape,
        padding: const EdgeInsets.all(4),
        checkmarkColor: t.onSelected,
        deleteIconColor: t.muted,
        showCheckmark: true,
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: t.chrome,
        foregroundColor: t.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 52,
        titleTextStyle: typography.titleMedium,
        iconTheme: IconThemeData(color: t.muted, size: 20),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: t.chrome,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: t.chrome,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: t.selected,
        indicatorShape: shape,
        labelTextStyle: WidgetStatePropertyAll(typography.labelMedium),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: t.chrome,
        indicatorColor: t.selected,
        indicatorShape: shape,
        selectedIconTheme: IconThemeData(color: t.onSelected),
        unselectedIconTheme: IconThemeData(color: t.muted),
        selectedLabelTextStyle: typography.labelMedium,
        unselectedLabelTextStyle: typography.labelMedium,
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: t.chrome,
        surfaceTintColor: Colors.transparent,
        indicatorColor: t.selected,
        indicatorShape: shape,
        tileHeight: touch ? 56 : 44,
        indicatorSize: Size(double.infinity, touch ? 48 : 36),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? t.onSelected
                : t.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => typography.labelLarge?.copyWith(
            color: states.contains(WidgetState.selected)
                ? t.onSelected
                : t.text,
          ),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: t.chrome,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: t.focus,
        unselectedLabelColor: t.muted,
        labelStyle: typography.labelLarge,
        unselectedLabelStyle: typography.labelLarge,
        indicatorColor: t.focus,
        dividerColor: t.separator,
        indicatorSize: TabBarIndicatorSize.label,
        overlayColor: overlay(t.focus),
      ),
      cardTheme: CardThemeData(
        color: t.field,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: panelShape,
      ),
      dividerTheme: DividerThemeData(
        color: t.separator,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        textColor: t.text,
        iconColor: t.muted,
        selectedColor: t.onSelected,
        selectedTileColor: t.selected,
        shape: shape,
        minTileHeight: t.rowHeight,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compactTouch ? 0 : 4,
        ),
        dense: !touch,
      ),
      expansionTileTheme: ExpansionTileThemeData(
        textColor: t.text,
        collapsedTextColor: t.text,
        iconColor: t.muted,
        collapsedIconColor: t.muted,
        shape: Border(bottom: BorderSide(color: t.separator)),
        collapsedShape: Border(bottom: BorderSide(color: t.separator)),
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: typography.labelLarge,
        dataTextStyle: typography.bodyMedium,
        headingRowColor: WidgetStatePropertyAll(t.chrome),
        dataRowColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.selected : null,
        ),
        dividerThickness: 1,
        horizontalMargin: 16,
        columnSpacing: 24,
        dataRowMinHeight: t.rowHeight,
        dataRowMaxHeight: double.infinity,
        headingRowHeight: 44,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.raised,
        surfaceTintColor: Colors.transparent,
        shape: panelShape,
        titleTextStyle: typography.titleLarge,
        contentTextStyle: typography.bodyLarge,
        elevation: 12,
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.raised,
        modalBackgroundColor: t.raised,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(t.panelRadius),
          ),
        ),
        showDragHandle: true,
        dragHandleColor: t.muted,
      ),
      menuTheme: MenuThemeData(style: menuStyle),
      menuBarTheme: MenuBarThemeData(
        style: menuStyle.copyWith(
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(t.chrome),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: IanvsMenuStyle.item(
          t,
        ).copyWith(textStyle: WidgetStatePropertyAll(typography.bodyLarge)),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.raised,
        surfaceTintColor: Colors.transparent,
        shape: shape.copyWith(side: BorderSide(color: t.border)),
        menuPadding: const EdgeInsets.all(4),
        textStyle: typography.bodyLarge,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => typography.bodyLarge?.copyWith(
            color: states.contains(WidgetState.disabled) ? t.subtle : t.text,
          ),
        ),
        elevation: 4,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: input.copyWith(
          suffixIconConstraints: BoxConstraints(
            minWidth: 50,
            maxWidth: 50,
            minHeight: t.controlHeight,
            maxHeight: t.controlHeight,
          ),
        ),
        textStyle: typography.bodyLarge,
        menuStyle: menuStyle.copyWith(
          alignment: AlignmentDirectional.bottomStart,
          maximumSize: const WidgetStatePropertyAll(Size(360, 320)),
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(t.field),
        elevation: const WidgetStatePropertyAll(0),
        shape: WidgetStatePropertyAll(shape),
        side: WidgetStatePropertyAll(BorderSide(color: t.border)),
        textStyle: WidgetStatePropertyAll(typography.bodyMedium),
        hintStyle: WidgetStatePropertyAll(
          typography.bodyMedium?.copyWith(color: t.subtle),
        ),
        constraints: BoxConstraints(minHeight: t.controlHeight, maxWidth: 720),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
      searchViewTheme: SearchViewThemeData(
        backgroundColor: t.field,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: shape.copyWith(side: BorderSide(color: t.border)),
        shrinkWrap: true,
        constraints: const BoxConstraints(
          minWidth: 240,
          maxWidth: 480,
          maxHeight: 320,
        ),
        barPadding: const EdgeInsets.symmetric(horizontal: 8),
        headerTextStyle: typography.bodyLarge,
        headerHintStyle: typography.bodyLarge?.copyWith(color: t.subtle),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: t.raised,
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: typography.bodySmall?.copyWith(color: t.text),
        waitDuration: const Duration(milliseconds: 450),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: t.raised,
        contentTextStyle: typography.bodyMedium,
        actionTextColor: actionColor,
        behavior: SnackBarBehavior.floating,
        shape: panelShape,
        elevation: 8,
        closeIconColor: t.muted,
      ),
      bannerTheme: MaterialBannerThemeData(
        backgroundColor: t.selected,
        contentTextStyle: typography.bodyMedium,
        padding: const EdgeInsets.all(16),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: t.danger,
        textColor: foregroundFor(t.danger),
        textStyle: typography.labelSmall,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: t.focus,
        linearTrackColor: t.border,
        circularTrackColor: t.border,
        linearMinHeight: 4,
        borderRadius: BorderRadius.circular(4),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: t.raised,
        surfaceTintColor: Colors.transparent,
        shape: panelShape,
        headerBackgroundColor: t.chrome,
        headerForegroundColor: t.text,
        dividerColor: t.separator,
        todayBorder: BorderSide(color: t.focus),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: t.raised,
        shape: panelShape,
        hourMinuteShape: shape,
        dayPeriodShape: shape,
        dayPeriodColor: WidgetStateColor.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? t.selected : t.field,
        ),
        dayPeriodTextColor: WidgetStateColor.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? t.onSelected : t.text,
        ),
        dayPeriodBorderSide: BorderSide(color: t.border),
        dialBackgroundColor: t.field,
        dialHandColor: t.accent,
        dialTextColor: t.text,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: t.focus,
        selectionColor: t.focus.withValues(alpha: .30),
        selectionHandleColor: t.focus,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thickness: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered) ? 8 : 6,
        ),
        radius: const Radius.circular(4),
        thumbColor: WidgetStatePropertyAll(t.muted.withValues(alpha: .45)),
      ),
    );
  }

  /// Retains the action hue while meeting contrast on supported surfaces.
  static Color _readableActionColor(Color candidate, List<Color> surfaces) {
    final target = foregroundFor(surfaces.first);
    for (var step = 0; step <= 100; step++) {
      final color = Color.lerp(candidate, target, step / 100)!;
      final luminance = color.computeLuminance();
      if (surfaces.every((surface) {
        final other = surface.computeLuminance();
        return (luminance > other
                ? (luminance + .05) / (other + .05)
                : (other + .05) / (luminance + .05)) >=
            4.5;
      })) {
        return color;
      }
    }
    return target;
  }

  /// Chooses the higher-contrast foreground for a supplied accent/surface.
  static Color foregroundFor(Color background) =>
      background.computeLuminance() > .179 ? Colors.black : Colors.white;
}
