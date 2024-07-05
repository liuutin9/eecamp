import 'package:flutter/material.dart';

class AnimatedHintRight extends StatefulWidget {
  const AnimatedHintRight({super.key});

  @override
  State<AnimatedHintRight> createState() => _AnimatedHintRightState();
}

class _AnimatedHintRightState extends State<AnimatedHintRight> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _animation,
      child: const Icon(
        Icons.navigation,
        size: 100,
      ),
    );
  }
}