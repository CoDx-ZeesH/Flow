// lib/widgets/skeleton_loader.dart
//
// Fix: SkeletonBox now accepts double borderRadius (not BorderRadius object)
// so dashboard_screen.dart's call site compiles without casting.

import 'package:flutter/material.dart';

// ─── Shimmer box ──────────────────────────────────────────────────────────────

class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;   // always a double — simple to call everywhere

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base   = isDark ? const Color(0xFF2A342C) : const Color(0xFFE2E6E2);
    final hi     = isDark ? const Color(0xFF3A4A3E) : const Color(0xFFF0F4F1);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width:  widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin:  const Alignment(-1.5, 0),
            end:    const Alignment(1.5, 0),
            colors: [base, hi, base],
            stops:  [
              (_ctrl.value - 0.3).clamp(0.0, 1.0),
              _ctrl.value.clamp(0.0, 1.0),
              (_ctrl.value + 0.3).clamp(0.0, 1.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Preset composites ────────────────────────────────────────────────────────

/// Mimics a stat card block — label + big number + subtext.
class SkeletonStatCard extends StatelessWidget {
  const SkeletonStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SkeletonBox(width: 80,  height: 10),
          SizedBox(height: 12),
          SkeletonBox(width: 120, height: 40, borderRadius: 8),
          SizedBox(height: 8),
          SkeletonBox(width: 60,  height: 10),
        ],
      ),
    );
  }
}