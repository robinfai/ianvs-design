import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// Explicit input density. Width alone never implies touch input.
enum IanvsDensity { compact, comfortable, touch }

/// Visual spacing for touch input; never changes the input mode or tap padding.
enum IanvsTouchVisualDensity { standard, compact }

/// Shared spacing in logical pixels. Prefer semantic layout over fixed heights.
abstract final class IanvsSpacing {
  static const double xs = 4,
      sm = 8,
      md = 12,
      lg = 16,
      xl = 24,
      xxl = 32,
      xxxl = 40;
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
    this.canvas = const Color(0xff202123),
    this.chrome = const Color(0xff1e1f21),
    this.field = const Color(0xff292b2e),
    this.raised = const Color(0xff303236),
    this.border = const Color(0xff45474d),
    this.separator = const Color(0xff37393e),
    this.text = const Color(0xfff3f4f6),
    this.muted = const Color(0xffb9bcc4),
    this.subtle = const Color(0xffa8adb7),
    this.accent = const Color(0xff0874df),
    this.focus = const Color(0xff39a6ff),
    this.selected = const Color(0xff213d56),
    this.onSelected = const Color(0xff8dceff),
    this.success = const Color(0xff75d3a7),
    this.warning = const Color(0xffffc250),
    this.danger = const Color(0xffff8f8b),
    this.controlHeight = 32,
    this.controlRadius = 6,
    this.panelRadius = 10,
    this.rowHeight = 40,
    this.density = IanvsDensity.compact,
    this.touchVisualDensity = IanvsTouchVisualDensity.standard,
  });

  final Color canvas;
  final Color chrome;
  final Color field;
  final Color raised;
  final Color border;
  final Color separator;
  final Color text;
  final Color muted;
  final Color subtle;
  final Color accent;
  final Color focus;
  final Color selected;
  final Color onSelected;
  final Color success;
  final Color warning;
  final Color danger;

  /// Minimum visual height. Padded Material buttons may occupy more hit space.
  final double controlHeight;
  final double controlRadius;
  final double panelRadius;
  final double rowHeight;
  final IanvsDensity density;
  final IanvsTouchVisualDensity touchVisualDensity;

  bool get isCompactTouch =>
      density == IanvsDensity.touch &&
      touchVisualDensity == IanvsTouchVisualDensity.compact;

  static const dark = IanvsTokens();
  static const light = IanvsTokens(
    canvas: Color(0xfffafafb),
    chrome: Color(0xfff3f3f5),
    field: Color(0xffffffff),
    raised: Color(0xffffffff),
    border: Color(0xffb9bcc3),
    separator: Color(0xffdedfe4),
    text: Color(0xff24262a),
    muted: Color(0xff60646c),
    subtle: Color(0xff676d76),
    accent: Color(0xff0969da),
    focus: Color(0xff0969da),
    selected: Color(0xffdeebfa),
    onSelected: Color(0xff0753a5),
    success: Color(0xff187047),
    warning: Color(0xff895700),
    danger: Color(0xffb52c2a),
  );

  static IanvsTokens of(BuildContext context) =>
      Theme.of(context).extension<IanvsTokens>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  IanvsTokens withDensity(
    IanvsDensity value, {
    IanvsTouchVisualDensity touchVisualDensity =
        IanvsTouchVisualDensity.standard,
  }) => copyWith(
    density: value,
    touchVisualDensity: touchVisualDensity,
    controlHeight: switch (value) {
      IanvsDensity.compact => 32,
      IanvsDensity.comfortable => 40,
      IanvsDensity.touch =>
        touchVisualDensity == IanvsTouchVisualDensity.compact ? 44 : 48,
    },
    rowHeight: switch (value) {
      IanvsDensity.compact => 40,
      IanvsDensity.comfortable => 48,
      IanvsDensity.touch =>
        touchVisualDensity == IanvsTouchVisualDensity.compact ? 48 : 56,
    },
  );

  @override
  IanvsTokens copyWith({
    Color? canvas,
    Color? chrome,
    Color? field,
    Color? raised,
    Color? border,
    Color? separator,
    Color? text,
    Color? muted,
    Color? subtle,
    Color? accent,
    Color? focus,
    Color? selected,
    Color? onSelected,
    Color? success,
    Color? warning,
    Color? danger,
    double? controlHeight,
    double? controlRadius,
    double? panelRadius,
    double? rowHeight,
    IanvsDensity? density,
    IanvsTouchVisualDensity? touchVisualDensity,
  }) => IanvsTokens(
    canvas: canvas ?? this.canvas,
    chrome: chrome ?? this.chrome,
    field: field ?? this.field,
    raised: raised ?? this.raised,
    border: border ?? this.border,
    separator: separator ?? this.separator,
    text: text ?? this.text,
    muted: muted ?? this.muted,
    subtle: subtle ?? this.subtle,
    accent: accent ?? this.accent,
    focus: focus ?? this.focus,
    selected: selected ?? this.selected,
    onSelected: onSelected ?? this.onSelected,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    danger: danger ?? this.danger,
    controlHeight: controlHeight ?? this.controlHeight,
    controlRadius: controlRadius ?? this.controlRadius,
    panelRadius: panelRadius ?? this.panelRadius,
    rowHeight: rowHeight ?? this.rowHeight,
    density: density ?? this.density,
    touchVisualDensity: touchVisualDensity ?? this.touchVisualDensity,
  );

  @override
  IanvsTokens lerp(covariant IanvsTokens? other, double t) {
    if (other == null) return this;
    return IanvsTokens(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      chrome: Color.lerp(chrome, other.chrome, t)!,
      field: Color.lerp(field, other.field, t)!,
      raised: Color.lerp(raised, other.raised, t)!,
      border: Color.lerp(border, other.border, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      subtle: Color.lerp(subtle, other.subtle, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      focus: Color.lerp(focus, other.focus, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      onSelected: Color.lerp(onSelected, other.onSelected, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      controlHeight: lerpDouble(controlHeight, other.controlHeight, t)!,
      controlRadius: lerpDouble(controlRadius, other.controlRadius, t)!,
      panelRadius: lerpDouble(panelRadius, other.panelRadius, t)!,
      rowHeight: lerpDouble(rowHeight, other.rowHeight, t)!,
      density: t < .5 ? density : other.density,
      touchVisualDensity: t < .5
          ? touchVisualDensity
          : other.touchVisualDensity,
    );
  }
}

extension IanvsContext on BuildContext {
  IanvsTokens get ianvs => IanvsTokens.of(this);
}
