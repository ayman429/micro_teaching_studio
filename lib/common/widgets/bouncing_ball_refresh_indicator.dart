import 'package:micro_teaching_studio/common/resources/color_manager.dart';
import 'package:flutter/material.dart';

class BouncingBallRefreshIndicator extends StatefulWidget {
  final double progress;
  final bool isRefreshing;

  const BouncingBallRefreshIndicator({
    super.key,
    required this.progress,
    required this.isRefreshing,
  });

  @override
  _BouncingBallRefreshIndicatorState createState() =>
      _BouncingBallRefreshIndicatorState();
}

class _BouncingBallRefreshIndicatorState
    extends State<BouncingBallRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _innerBallController;
  late Animation<double> _innerBallAnimation;

  @override
  void initState() {
    super.initState();

    _innerBallController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 300), // Faster bounce for inner ball
    );

    // Define the inner ball's bouncing animation
    _innerBallAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _innerBallController,
        curve: Curves.easeInOut,
      ),
    );
    _innerBallController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _innerBallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween:
          Tween(begin: 0.0, end: widget.isRefreshing ? 1.0 : widget.progress),
      duration: const Duration(milliseconds: 600), // Outer ball smoother bounce
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        final outerBounceOffset = -value * 35; // Outer ball moves up smoothly

        return Transform.translate(
          offset: Offset(0, outerBounceOffset), // Outer ball global bounce
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Ball
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: ColorManager.primary,
                  shape: BoxShape.circle,
                ),
              ),
              // Inner Ball with continuous bouncing
              AnimatedBuilder(
                animation: _innerBallAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                        0,
                        _innerBallAnimation
                            .value), // Inner ball bounces vertically
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
