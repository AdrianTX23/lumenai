import 'package:core_ui/src/theme/lds_theme.dart';
import 'package:core_ui/src/tokens/lds_motion.dart';
import 'package:core_ui/src/tokens/lds_spacing.dart';
import 'package:flutter/widgets.dart';

/// Shimmering placeholder block matching the shape of the loading content.
///
/// Renders a static block when `MediaQuery.disableAnimations` is set
/// (reduced-motion parity, docs/03 §5).
class LdsSkeleton extends StatefulWidget {
  /// Creates a skeleton placeholder of the given dimensions.
  const LdsSkeleton({
    this.width = double.infinity,
    this.height = 16,
    this.radius = LdsRadius.sm,
    super.key,
  });

  /// Placeholder width.
  final double width;

  /// Placeholder height.
  final double height;

  /// Corner radius.
  final double radius;

  @override
  State<LdsSkeleton> createState() => _LdsSkeletonState();
}

class _LdsSkeletonState extends State<LdsSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: LdsMotion.celebratory * 2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.lds.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * (1 - t) * 2, 0),
              end: Alignment(1 + 2 * t * 2, 0),
              colors: [
                c.surfaceHigh,
                c.borderStrong,
                c.surfaceHigh,
              ],
            ),
          ),
        );
      },
    );
  }
}
