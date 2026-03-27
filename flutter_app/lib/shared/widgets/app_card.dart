import 'package:flutter/material.dart';

/// Modern Card Widget with Enhanced Styling
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.borderRadius,
    this.gradient,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? borderColor;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = theme.cardTheme.color ?? theme.colorScheme.surface;

    final Widget card = Container(
      margin: widget.margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        gradient: widget.gradient,
        color: widget.gradient == null ? cardColor : null,
        borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
        border: widget.borderColor != null
            ? Border.all(color: widget.borderColor!, width: 1)
            : null,
        boxShadow: [
          if (widget.elevation != null && widget.elevation! > 0)
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: widget.elevation! * 4,
              offset: Offset(0, widget.elevation! * 2),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: widget.onTap != null
              ? (_) {
                  _controller.forward();
                }
              : null,
          onTapUp: widget.onTap != null
              ? (_) {
                  _controller.reverse();
                }
              : null,
          onTapCancel: widget.onTap != null
              ? () {
                  _controller.reverse();
                }
              : null,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(20),
            child: widget.child,
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: card,
          );
        },
      );
    }

    return card;
  }
}
