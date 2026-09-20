import 'package:flutter/material.dart';

/// Wraps [child] with a subtle fade + upward-slide entrance animation.
/// [index] staggers the start time so list items animate in sequence
/// rather than all popping in at once. Give this widget a stable key
/// (based on the underlying item's id) so Flutter doesn't replay the
/// animation on every rebuild when the list is re-sorted.
class FadeSlideIn extends StatefulWidget {
  final int index;
  final Widget child;

  const FadeSlideIn({super.key, required this.index, required this.child});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(_fade);

    // Cap the stagger so items far down a long list don't wait absurdly
    // long — only the first "screenful" needs a visible cascade.
    final delay = Duration(milliseconds: 40 * (widget.index % 10));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
