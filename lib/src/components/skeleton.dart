import 'dart:async';
import 'package:flutter/material.dart';
import '../foundation/tokens.dart';

/// A delayed loading skeleton that retains the child's layout footprint.
/// Underlying content is neither interactive nor announced while loading.
/// Pulse animation respects reduced motion and pauses with the widget's ticker.
class IanvsSkeleton extends StatefulWidget {
  const IanvsSkeleton({
    super.key,
    required this.child,
    this.loading = true,
    this.lines = 3,
    this.delay = const Duration(milliseconds: 200),
    this.animate = true,
    this.label = '正在加载',
  }) : assert(lines > 0);
  final Widget child;
  final bool loading, animate;
  final int lines;
  final Duration delay;
  final String label;
  @override
  State<IanvsSkeleton> createState() => _IanvsSkeletonState();
}

class _IanvsSkeletonState extends State<IanvsSkeleton>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
    lowerBound: .55,
    upperBound: 1,
  );
  Timer? _timer;
  bool _visible = false;
  @override
  void initState() {
    super.initState();
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    _visible = widget.loading && widget.delay == Duration.zero;
    if (widget.loading && !_visible) {
      _timer = Timer(widget.delay, () {
        if (mounted) {
          setState(() {
            _visible = true;
            _animate();
          });
        }
      });
    }
  }

  void _animate() {
    final shouldAnimate =
        widget.loading &&
        _visible &&
        widget.animate &&
        !MediaQuery.disableAnimationsOf(context);
    if (shouldAnimate && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!shouldAnimate) {
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate();
  }

  @override
  void didUpdateWidget(covariant IanvsSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loading != widget.loading ||
        oldWidget.delay != widget.delay) {
      _schedule();
    }
    _animate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Visibility(
        visible: !widget.loading,
        maintainState: true,
        maintainAnimation: true,
        maintainSize: true,
        child: TickerMode(enabled: !widget.loading, child: widget.child),
      ),
      if (widget.loading)
        Positioned.fill(
          child: Semantics(
            label: widget.label,
            liveRegion: true,
            child: ExcludeSemantics(
              child: !_visible
                  ? const SizedBox.expand()
                  : FadeTransition(
                      opacity: _pulse,
                      child: ClipRect(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (var i = 0; i < widget.lines; i++)
                                Flexible(
                                  child: FractionallySizedBox(
                                    widthFactor: i == widget.lines - 1
                                        ? .55
                                        : i == 0
                                        ? .7
                                        : 1,
                                    child: Container(
                                      height: i == 0 ? 14 : 10,
                                      decoration: BoxDecoration(
                                        color: context.ianvs.muted.withValues(
                                          alpha: .25,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
    ],
  );
}
