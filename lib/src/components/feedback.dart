import 'package:flutter/material.dart';
import '../foundation/tokens.dart';

enum IanvsTone { info, success, warning, danger }

class IanvsBanner extends StatelessWidget {
  const IanvsBanner({
    super.key,
    required this.message,
    this.tone = IanvsTone.info,
    this.actions = const [],
    this.liveRegion = false,
  });
  final String message;
  final IanvsTone tone;
  final List<Widget> actions;
  final bool liveRegion;
  @override
  Widget build(BuildContext context) {
    final t = context.ianvs;
    final (color, icon) = switch (tone) {
      IanvsTone.info => (t.focus, Icons.info_outline),
      IanvsTone.success => (t.success, Icons.check_circle_outline),
      IanvsTone.warning => (t.warning, Icons.warning_amber_rounded),
      IanvsTone.danger => (t.danger, Icons.error_outline),
    };
    return Semantics(
      liveRegion: liveRegion,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color.alphaBlend(color.withValues(alpha: .07), t.canvas),
          border: Border.all(color: color.withValues(alpha: .45)),
          borderRadius: BorderRadius.circular(t.controlRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(message)),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class IanvsEmptyState extends StatelessWidget {
  const IanvsEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.action,
  });
  final String title;
  final String? description;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 36, color: context.ianvs.muted),
        const SizedBox(height: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
          textAlign: TextAlign.center,
        ),
        if (description != null) ...[
          const SizedBox(height: 6),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
        if (action != null) ...[const SizedBox(height: 16), action!],
      ],
    ),
  );
}
