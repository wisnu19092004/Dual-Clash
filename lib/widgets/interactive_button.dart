import 'package:flutter/material.dart';
import 'package:game_papan/services/sound_effects.dart';

/// Ultra-responsive, Lightweight Interactive Button
/// Uses hardware accelerated scaling with 0ms touch-down delay and minimal rebuilds.
class InteractiveButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double scaleDown;
  final bool enableSound;

  const InteractiveButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.scaleDown = 0.95,
    this.enableSound = true,
  });

  @override
  State<InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<InteractiveButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
      reverseDuration: const Duration(milliseconds: 80),
      value: 0.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleDown).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeOutQuad),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
      if (widget.enableSound) {
        SoundEffects.playButtonClick();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = widget.borderRadius ?? BorderRadius.circular(12);

    return MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (!_isHovered) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (_isHovered) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.gradient == null && widget.backgroundColor != null
                  ? (_isHovered && widget.onPressed != null
                      ? widget.backgroundColor!.withValues(alpha: 0.88)
                      : widget.backgroundColor)
                  : null,
              gradient: widget.gradient,
              borderRadius: effectiveRadius,
              border: widget.border,
              boxShadow: _isHovered && widget.boxShadow != null
                  ? widget.boxShadow!.map((s) => BoxShadow(
                      color: s.color.withValues(alpha: 0.5),
                      blurRadius: s.blurRadius + 3,
                      offset: s.offset,
                    )).toList()
                  : widget.boxShadow,
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: widget.foregroundColor ?? Colors.white,
              ),
              child: IconTheme(
                data: IconThemeData(
                  color: widget.foregroundColor ?? Colors.white,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
