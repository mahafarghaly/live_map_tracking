import 'dart:math';
import 'package:flutter/material.dart';

class CustomDotProgressIndicator extends StatefulWidget {
  const CustomDotProgressIndicator({
    super.key,
    this.size = 50.0,
    this.dotCount = 8,
    this.duration = const Duration(milliseconds: 1200),

    /// NEW: Base color of dots
    this.baseColor = Colors.black,

    /// Optional preset for gold theme
    this.isGold = false,
  });

  final double size;
  final int dotCount;
  final Duration duration;

  /// If provided → used to generate opacity shades
  final Color baseColor;

  /// Quick flag to switch to gold
  final bool isGold;

  @override
  State<CustomDotProgressIndicator> createState() =>
      _CustomDotProgressIndicatorState();
}

class _CustomDotProgressIndicatorState extends State<CustomDotProgressIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<Color> _dotColors;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();

    /// Decide color source
    final Color effectiveBaseColor = widget.isGold
        ? const Color(0xFFFFD700) // Gold
        : widget.baseColor;

    /// Generate opacity shades
    _dotColors = List.generate(widget.dotCount, (index) {
      final opacity = 0.2 + 0.8 * (index / (widget.dotCount - 1));
      return effectiveBaseColor.withOpacity(opacity);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(int index) {
    final dotRadius = widget.size * 0.08;
    final radius = widget.size * 0.4;

    final progress = (_controller.value + index / widget.dotCount) % 1.0;
    final scale = 0.5 + 0.5 * sin(progress * 2 * pi);
    final color = _dotColors[index];

    return Transform.translate(
      offset: Offset(
        radius * sin(2 * pi * index / widget.dotCount),
        radius * cos(2 * pi * index / widget.dotCount),
      ),
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: dotRadius * 2,
          height: dotRadius * 2,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, _) {
          return Center(
            child: Stack(children: List.generate(widget.dotCount, _buildDot)),
          );
        },
      ),
    );
  }
}
