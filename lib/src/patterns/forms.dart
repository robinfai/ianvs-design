import 'package:flutter/material.dart';
import '../foundation/tokens.dart';
import '../components/control_label.dart';

/// Responsive, accessible label/control pairing used throughout Ianvs settings.
class IanvsFieldRow extends StatelessWidget {
  const IanvsFieldRow({
    super.key,
    required this.label,
    required this.child,
    this.helper,
    this.labelWidth = 170,
    this.breakpoint = 480,
  });
  final String label;
  final Widget child;
  final String? helper;
  final double labelWidth, breakpoint;
  @override
  Widget build(BuildContext context) {
    final labelWidget = ExcludeSemantics(child: Text(label));
    final control = Semantics(label: label, child: child);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        control,
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper!, style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack =
            constraints.maxWidth < breakpoint ||
            MediaQuery.textScalerOf(context).scale(13) > 19.5;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [labelWidget, const SizedBox(height: 8), content],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: labelWidth,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 7, end: 12),
                child: labelWidget,
              ),
            ),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}

class IanvsFormSection extends StatelessWidget {
  const IanvsFormSection({
    super.key,
    required this.title,
    required this.children,
    this.description,
    this.spacing = 16,
    this.trailing,
  });
  final Widget title;
  final String? description;
  final List<Widget> children;
  final double spacing;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => FocusTraversalGroup(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final heading = DefaultTextStyle(
              style: Theme.of(context).textTheme.titleMedium!,
              child: title,
            );
            if (trailing == null) return heading;
            final stack =
                constraints.maxWidth < 480 ||
                MediaQuery.textScalerOf(context).scale(13) > 19.5;
            if (stack) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  heading,
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: trailing,
                  ),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: heading),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth / 2,
                  ),
                  child: trailing,
                ),
              ],
            );
          },
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(description!, style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: 20),
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          children[i],
        ],
      ],
    ),
  );
}

/// Switch and supporting copy stay together under scaling and narrow constraints.
class IanvsSettingsRow extends StatelessWidget {
  const IanvsSettingsRow({
    super.key,
    required this.title,
    this.description,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;
  @override
  Widget build(BuildContext context) => IanvsControlLabel(
    label: title,
    description: description,
    trailing: true,
    onTap: onChanged == null ? null : () => onChanged!(!value),
    controlBuilder: (focusNode) => Switch.adaptive(
      value: value,
      focusNode: focusNode,
      onChanged: onChanged,
      activeTrackColor: context.ianvs.accent,
    ),
  );
}
