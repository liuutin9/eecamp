import 'package:flutter/material.dart';

class AnimatedHintLeft extends StatefulWidget {
  const AnimatedHintLeft({super.key});

  @override
  State<AnimatedHintLeft> createState() => _AnimatedHintLeftState();
}

class _AnimatedHintLeftState extends State<AnimatedHintLeft> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _animation = Tween(begin: 0.0, end: -1.0).animate(CurvedAnimation(
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