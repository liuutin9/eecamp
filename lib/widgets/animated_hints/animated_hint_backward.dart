import 'package:flutter/material.dart';

class AnimatedHintBackward extends StatefulWidget {
  const AnimatedHintBackward({super.key});

  @override
  State<AnimatedHintBackward> createState() => _AnimatedHintBackwardState();
}

class _AnimatedHintBackwardState extends State<AnimatedHintBackward> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    _animation = Tween(begin: const Offset(0, 0), end: const Offset(0, 1)).animate(CurvedAnimation(
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
    return SlideTransition(
      position: _animation,
      child: const Icon(
        Icons.navigation,
        size: 100,
      ),
    );
  }
}