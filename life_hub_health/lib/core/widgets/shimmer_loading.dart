import 'package:flutter/material.dart';

/// 骨架屏 shimmer 效果组件
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({super.key, required this.child});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + 2 * _controller.value, 0),
              end: Alignment(1 + 2 * _controller.value, 0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// 骨架占位块
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// 首页骨架屏
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome card skeleton
            ShimmerBox(height: 80),
            SizedBox(height: 14),
            // Today summary skeleton
            ShimmerBox(height: 120),
            SizedBox(height: 14),
            // Quick actions skeleton
            Row(
              children: List.generate(5, (_) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: ShimmerBox(height: 70, borderRadius: 12),
                ),
              )),
            ),
            SizedBox(height: 14),
            // Mood card skeleton
            ShimmerBox(height: 100),
            SizedBox(height: 14),
            // Checkin card skeleton
            ShimmerBox(height: 90),
            SizedBox(height: 14),
            // Trend chart skeleton
            ShimmerBox(height: 160),
            SizedBox(height: 14),
            // AI advice skeleton
            ShimmerBox(height: 140),
          ],
        ),
      ),
    );
  }
}

/// 列表骨架屏
class ListSkeleton extends StatelessWidget {
  final int itemCount;

  const ListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              ShimmerBox(width: 48, height: 48, borderRadius: 24),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(height: 14, width: 160),
                    SizedBox(height: 8),
                    ShimmerBox(height: 12, width: 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
