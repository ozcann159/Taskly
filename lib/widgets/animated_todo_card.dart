import 'package:flutter/material.dart';
import 'package:new_todo_app/widgets/todo_card.dart';

class AnimatedTodoCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onDismissed;

  const AnimatedTodoCard({Key? key, required this.child, this.onDismissed})
    : super(key: key);

  @override
  State<AnimatedTodoCard> createState() => _AnimatedTodoCardState();
}

class _AnimatedTodoCardState extends State<AnimatedTodoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          if (widget.onDismissed != null) {
            widget.onDismissed!();
          }
        },
        child: widget.child,
      ),
    );
  }
}
