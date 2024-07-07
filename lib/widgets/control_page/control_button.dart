import 'package:eecamp/widgets/control_page/control_panel.dart';
import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  const ControlButton({
    super.key,
    required this.type,
    required this.state,
    required this.setMoveState
  });
  final ControlButtonTypes type;
  final MoveStates state;
  final void Function(MoveStates) setMoveState;

  Widget getButtonIcon(ControlButtonTypes type) {
    switch (type) {
      case ControlButtonTypes.forward:
        return const Icon(Icons.arrow_upward);
      case ControlButtonTypes.backward:
        return const Icon(Icons.arrow_downward);
      case ControlButtonTypes.left:
        return const Icon(Icons.rotate_left);
      case ControlButtonTypes.right:
        return const Icon(Icons.rotate_right);
    }
  }

  MoveStates matchStateFromType(ControlButtonTypes type) {
    switch (type) {
      case ControlButtonTypes.forward:
        return MoveStates.forward;
      case ControlButtonTypes.backward:
        return MoveStates.backward;
      case ControlButtonTypes.left:
        return MoveStates.left;
      case ControlButtonTypes.right:
        return MoveStates.right;
    }
  }

  bool isThisMove(ControlButtonTypes type, MoveStates state) {
    return state == matchStateFromType(type);
  }

  bool isStop(MoveStates state) {
    return state == MoveStates.stop;
  }

  bool isNotOtherMove(ControlButtonTypes type, MoveStates state) {
    return isThisMove(type, state) || isStop(state);
  }

  void move (ControlButtonTypes type) {
    setMoveState(matchStateFromType(type));
  }

  void stop () {
    setMoveState(MoveStates.stop);
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressDown: isStop(state)
          ? (details) => move(type) : null,
      onLongPressCancel: isThisMove(type, state)
          ? () => stop() : null,
      onLongPressEnd: isThisMove(type, state)
          ? (details) => stop() : null,
      child: Opacity(
        opacity: isNotOtherMove(type, state) ? 1 : 0.3,
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: state == MoveStates.backward
                ? Theme.of(context).colorScheme.surfaceContainerLowest
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: getButtonIcon(type),
        ),
      ),
    );
  }
}